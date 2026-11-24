import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/fechas.dart';
import '../../data/repositories/capturas_repository.dart';
import '../../data/repositories/categorias_repository.dart';
import '../../data/repositories/configuracion_repository.dart';
import '../../data/repositories/cuentas_repository.dart';
import '../../data/repositories/etiquetas_repository.dart';
import '../../domain/entities/captura.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/cuenta.dart';
import '../../domain/entities/etiqueta.dart';
import '../../domain/entities/subcategoria.dart';
import '../../domain/entities/transaccion.dart';
import '../../domain/parsers/parser_recibo.dart';
import '../../domain/parsers/parser_texto.dart';
import '../ocr/servicio_ocr.dart';
import 'almacen_adjuntos.dart';
import 'token_seguro.dart';

/// Servidor HTTP local de capturas (API v2, contrato en docs/API_CONTRACT.md).
///
/// Escucha solo en `127.0.0.1`; arranca con la app y se detiene al cerrarla
/// (sin servicio en primer plano todavía, ADR-036).
class ServidorCapturas {
  ServidorCapturas({
    required this.configuracion,
    required this.capturas,
    required this.categorias,
    required this.etiquetas,
    required this.cuentas,
    required this.almacen,
    this.ocr,
  });

  static const int limiteBytes = 8 * 1024 * 1024;
  static const int limiteTexto = 4000;

  final ConfiguracionRepository configuracion;
  final CapturasRepository capturas;
  final CategoriasRepository categorias;
  final EtiquetasRepository etiquetas;
  final CuentasRepository cuentas;
  final AlmacenAdjuntos almacen;
  final ServicioOcr? ocr;

  HttpServer? _servidor;
  String? ultimoError;

  bool get activo => _servidor != null;
  int? get puerto => _servidor?.port;

  Future<void> iniciar() async {
    if (_servidor != null) {
      return;
    }
    try {
      final int puertoConfigurado = await configuracion.obtenerPuerto();
      final shelf.Handler handler = const shelf.Pipeline()
          .addMiddleware(_manejarErrores())
          .addHandler(_router().call);
      _servidor = await shelf_io.serve(
        handler,
        InternetAddress.loopbackIPv4,
        puertoConfigurado,
      );
      ultimoError = null;
    } on Object catch (error) {
      ultimoError = 'No se pudo abrir el puerto: $error';
      rethrow;
    }
  }

  Future<void> detener() async {
    final HttpServer? servidor = _servidor;
    _servidor = null;
    await servidor?.close(force: true);
  }

  Future<void> reiniciar() async {
    await detener();
    await iniciar();
  }

  Router _router() {
    return Router(
      notFoundHandler: (shelf.Request request) =>
          _error(404, 'NO_ENCONTRADO', 'La ruta no existe.'),
    )
      ..get(
        '/api/salud',
        (shelf.Request request) => _json(200, <String, Object?>{
          'ok': true,
          'version': AppConfig.appVersion,
        }),
      )
      ..get(
        '/api/pendientes',
        (shelf.Request request) => _conToken(request, () => _pendientes()),
      )
      ..get(
        '/api/cuentas',
        (shelf.Request request) => _conToken(request, () => _cuentas()),
      )
      ..post(
        '/api/capturas/<id>/confirmar',
        (shelf.Request request, String id) => _conToken(
          request,
          () => _confirmarCaptura(request, int.tryParse(id)),
        ),
      )
      ..post(
        '/api/capturas/texto',
        (shelf.Request request) => _conToken(request, () => _texto(request)),
      )
      ..post(
        '/api/capturas/foto',
        (shelf.Request request) => _conToken(
          request,
          () => _archivo(request, esAudio: false),
        ),
      )
      ..post(
        '/api/audio',
        (shelf.Request request) => _conToken(
          request,
          () => _archivo(request, esAudio: true),
        ),
      );
  }

  shelf.Middleware _manejarErrores() {
    return (shelf.Handler inner) {
      return (shelf.Request request) async {
        try {
          return await inner(request);
        } on _ErrorHttp catch (error) {
          return _error(
            error.estado,
            error.codigo,
            error.mensaje,
            campo: error.campo,
            extra: error.extra,
          );
        } on Object catch (error) {
          developer.log('Error en servidor de capturas: $error');
          return _error(
            500,
            'ERROR_INTERNO',
            'Fallo inesperado del servidor.',
          );
        }
      };
    };
  }

  Future<shelf.Response> _conToken(
    shelf.Request request,
    Future<shelf.Response> Function() accion,
  ) async {
    final String esperado = await configuracion.obtenerOCrearToken();
    if (!tokensIguales(request.headers['x-bot-token'], esperado)) {
      return _error(401, 'NO_AUTORIZADO', 'Falta el token o no coincide.');
    }
    return accion();
  }

  Future<shelf.Response> _pendientes() async {
    final int pendientes = await capturas.contarPorEstado(
      EstadoCaptura.pendiente,
    );
    final int listos = await capturas.contarPorEstado(EstadoCaptura.listo);
    return _json(200, <String, Object?>{
      'pendientes': pendientes,
      'listos': listos,
      'total': pendientes + listos,
    });
  }

  Future<shelf.Response> _cuentas() async {
    final List<Cuenta> activas = (await cuentas.obtenerTodas())
        .where((Cuenta cuenta) => cuenta.activa)
        .toList();
    return _json(200, <String, Object?>{
      'cuentas': <Map<String, Object?>>[
        for (final Cuenta cuenta in activas)
          <String, Object?>{
            'id': cuenta.id,
            'nombre': cuenta.nombre,
            'moneda': cuenta.moneda,
          },
      ],
    });
  }

  List<String> _faltantesDe(
    PropuestaCaptura propuesta, {
    int? cuentaId,
    int? montoCentavos,
    TipoTransaccion? tipo,
  }) {
    return <String>[
      if ((tipo ?? propuesta.tipo) == null) 'tipo',
      if ((montoCentavos ?? propuesta.montoCentavos) == null) 'monto',
      if ((cuentaId ?? propuesta.cuentaId) == null) 'cuenta',
    ];
  }

  Future<_ResultadoAuto?> _autoConfirmar(
    int capturaId,
    PropuestaCaptura propuesta, {
    int? cuentaId,
    int? montoCentavos,
    TipoTransaccion? tipo,
  }) async {
    final TipoTransaccion? tipoFinal = tipo ?? propuesta.tipo;
    final int? montoFinal = montoCentavos ?? propuesta.montoCentavos;
    if (tipoFinal == null || montoFinal == null) {
      return null;
    }
    final CapturaEntrante? captura = await capturas.obtener(capturaId);
    if (captura == null) {
      return null;
    }

    int? cuentaFinal = cuentaId ?? propuesta.cuentaId;
    bool cuentaPorDefecto = false;
    if (cuentaFinal == null) {
      final int? preferida = await configuracion.obtenerCapturaCuentaId();
      final List<Cuenta> activas = (await cuentas.obtenerTodas())
          .where((Cuenta c) => c.activa)
          .toList();
      Cuenta? elegida;
      for (final Cuenta cuenta in activas) {
        if (cuenta.id == preferida) elegida = cuenta;
      }
      elegida ??= activas.isEmpty ? null : activas.first;
      cuentaFinal = elegida?.id;
      cuentaPorDefecto = elegida != null && elegida.id != preferida;
    }
    if (cuentaFinal == null) {
      return null;
    }

    int? categoriaId = propuesta.categoriaId;
    categoriaId ??= await _categoriaOtros(tipoFinal);

    final bool incompleta = propuesta.faltantes.isNotEmpty || cuentaPorDefecto;
    final DateTime ahora = DateTime.now();
    final int transaccionId = await capturas.confirmar(
      capturaId: capturaId,
      tipo: tipoFinal,
      montoCentavos: montoFinal,
      moneda: propuesta.moneda,
      cuentaId: cuentaFinal,
      fecha: fechaIso(ahora),
      fechaHora: ahora.millisecondsSinceEpoch,
      categoriaId: categoriaId,
      subcategoriaId: propuesta.subcategoriaId,
      etiquetaIds: propuesta.etiquetaIds,
      nota: captura.textoCrudo?.trim(),
      incompleta: incompleta,
    );
    return _ResultadoAuto(
      transaccionId: transaccionId,
      incompleta: incompleta,
    );
  }

  Future<int?> _categoriaOtros(TipoTransaccion tipo) async {
    final NaturalezaCategoria naturaleza =
        tipo == TipoTransaccion.ingreso
            ? NaturalezaCategoria.ingreso
            : NaturalezaCategoria.gasto;
    for (final Categoria categoria in await categorias.obtenerCategorias()) {
      if (!categoria.archivada &&
          categoria.naturaleza == naturaleza &&
          categoria.nombre.toLowerCase() == 'otros') {
        return categoria.id;
      }
    }
    return null;
  }

  Future<shelf.Response> _confirmarCaptura(
    shelf.Request request,
    int? capturaId,
  ) async {
    if (capturaId == null) {
      throw const _ErrorHttp(404, 'NO_ENCONTRADO', 'La captura no existe.');
    }
    final Map<String, Object?> json = await _leerJson(request);
    final int? cuentaId = _entero(json['cuenta_id']);
    final int? montoCentavos = _entero(json['monto_centavos']);
    final TipoTransaccion? tipo = switch (json['tipo']) {
      'gasto' => TipoTransaccion.gasto,
      'ingreso' => TipoTransaccion.ingreso,
      'transferencia' => TipoTransaccion.transferencia,
      _ => null,
    };
    final CapturaEntrante? captura = await capturas.obtener(capturaId);
    if (captura == null) {
      throw const _ErrorHttp(404, 'NO_ENCONTRADO', 'La captura no existe.');
    }
    final PropuestaCaptura propuesta = captura.propuesta ??
        const PropuestaCaptura(
          moneda: 'COP',
          confianza: ConfianzaPropuesta.baja,
        );
    final _ResultadoAuto? resultado;
    try {
      resultado = await _autoConfirmar(
        capturaId,
        propuesta,
        cuentaId: cuentaId,
        montoCentavos: montoCentavos,
        tipo: tipo,
      );
    } on StateError {
      throw _ErrorHttp(
        409,
        'CONFLICTO',
        'La captura ya fue confirmada.',
        extra: <String, Object?>{'captura_id': capturaId},
      );
    }
    if (resultado == null) {
      throw _ErrorHttp(
        400,
        'FALTAN_DATOS',
        'Faltan datos para registrar el movimiento.',
        extra: <String, Object?>{
          'faltantes': _faltantesDe(
            propuesta,
            cuentaId: cuentaId,
            montoCentavos: montoCentavos,
            tipo: tipo,
          ),
        },
      );
    }
    return _json(200, <String, Object?>{
      'captura_id': capturaId,
      'estado': EstadoCaptura.confirmado.valorDb,
      'transaccion_id': resultado.transaccionId,
      'resumen': propuesta.resumen,
      'incompleta': resultado.incompleta,
    });
  }

  Future<shelf.Response> _texto(shelf.Request request) async {
    final Map<String, Object?> json = await _leerJson(request);
    final String? messageId = _textoObligatorio(json, 'message_id');
    final String? texto = _textoObligatorio(json, 'texto');
    final String canal = (json['canal'] as String?) ?? 'texto';
    final int? timestamp = _entero(json['timestamp']);

    if (messageId == null) {
      throw const _ErrorHttp(400, 'PAYLOAD_INVALIDO', 'Falta message_id.');
    }
    if (texto == null) {
      throw const _ErrorHttp(400, 'PAYLOAD_INVALIDO', 'Falta texto.');
    }
    if (texto.length > limiteTexto) {
      throw const _ErrorHttp(
        400,
        'PAYLOAD_INVALIDO',
        'El texto supera 4.000 caracteres.',
      );
    }
    if (canal != 'texto' && canal != 'audio') {
      throw const _ErrorHttp(
        400,
        'PAYLOAD_INVALIDO',
        "El campo 'canal' debe ser 'texto' o 'audio'.",
        campo: 'canal',
      );
    }
    if (timestamp == null) {
      throw const _ErrorHttp(400, 'PAYLOAD_INVALIDO', 'Falta timestamp.');
    }

    final CapturaEntrante? existente =
        await capturas.buscarPorMessageId(messageId);
    if (existente != null) {
      throw _ErrorHttp(
        409,
        'CONFLICTO',
        'El message_id ya fue procesado.',
        extra: <String, Object?>{'captura_id': existente.id},
      );
    }

    final PropuestaCaptura propuesta = await _proponer(texto);
    final int id = await capturas.crearDesdeCanal(
      messageId: messageId,
      canal: canal == 'audio' ? CanalCaptura.audio : CanalCaptura.texto,
      estado: EstadoCaptura.listo,
      origen: _origenDe(request),
      timestamp: timestamp,
      texto: texto,
      propuesta: propuesta,
    );
    final _ResultadoAuto? resultado =
        (propuesta.tipo != null && propuesta.montoCentavos != null)
            ? await _autoConfirmar(id, propuesta)
            : null;
    return _json(201, <String, Object?>{
      'captura_id': id,
      'estado': resultado == null
          ? EstadoCaptura.listo.valorDb
          : EstadoCaptura.confirmado.valorDb,
      'transaccion_id': ?resultado?.transaccionId,
      'resumen': propuesta.resumen,
      'faltantes': resultado == null ? _faltantesDe(propuesta) : <String>[],
      'incompleta': resultado?.incompleta ?? false,
      'cuenta_nombre': ?propuesta.cuentaNombre,
    });
  }

  Future<shelf.Response> _archivo(
    shelf.Request request, {
    required bool esAudio,
  }) async {
    final int? largo = request.contentLength;
    if (largo != null && largo > limiteBytes) {
      throw const _ErrorHttp(
        413,
        'DEMASIADO_GRANDE',
        'El archivo supera 8 MB.',
      );
    }
    final _Formulario formulario = await _leerMultipart(request);
    final String? messageId = formulario.campos['message_id'];
    final int? timestamp = int.tryParse(formulario.campos['timestamp'] ?? '');
    if (messageId == null || messageId.isEmpty) {
      throw const _ErrorHttp(400, 'PAYLOAD_INVALIDO', 'Falta message_id.');
    }
    if (timestamp == null) {
      throw const _ErrorHttp(400, 'PAYLOAD_INVALIDO', 'Falta timestamp.');
    }
    if (formulario.archivo == null || formulario.archivo!.isEmpty) {
      throw const _ErrorHttp(400, 'PAYLOAD_INVALIDO', 'Falta el archivo.');
    }
    if (formulario.archivo!.length > limiteBytes) {
      throw const _ErrorHttp(
        413,
        'DEMASIADO_GRANDE',
        'El archivo supera 8 MB.',
      );
    }

    final CapturaEntrante? existente =
        await capturas.buscarPorMessageId(messageId);
    if (existente != null) {
      throw _ErrorHttp(
        409,
        'CONFLICTO',
        'El message_id ya fue procesado.',
        extra: <String, Object?>{'captura_id': existente.id},
      );
    }

    final String extension = almacen.extensionDesdeMime(
      formulario.mime,
      formulario.nombreArchivo,
    );
    final String ruta = await almacen.guardar(
      formulario.archivo!,
      messageId: messageId,
      extension: extension,
    );
    final CanalCaptura canal =
        esAudio ? CanalCaptura.audio : CanalCaptura.foto;
    if (esAudio) {
      final int id = await capturas.crearDesdeCanal(
        messageId: messageId,
        canal: canal,
        estado: EstadoCaptura.pendiente,
        origen: _origenDe(request),
        timestamp: timestamp,
        adjuntoPath: ruta,
      );
      return _json(201, <String, Object?>{
        'captura_id': id,
        'estado': EstadoCaptura.pendiente.valorDb,
      });
    }

    final int id = await capturas.crearDesdeCanal(
      messageId: messageId,
      canal: CanalCaptura.foto,
      estado: EstadoCaptura.procesando,
      origen: _origenDe(request),
      timestamp: timestamp,
      adjuntoPath: ruta,
    );
    final String monedaBase = await configuracion.obtenerMonedaBase();
    PropuestaCaptura propuesta;
    try {
      final String textoOcr;
      if (ocr == null) {
        textoOcr = '';
      } else {
        final File archivo = await almacen.resolver(ruta);
        textoOcr = await ocr!.reconocerTexto(archivo.path);
      }
      final PropuestaRecibo recibo = parsearRecibo(
        textoOcr,
        fechaRecepcion: DateTime.fromMillisecondsSinceEpoch(timestamp),
        categorias: await categorias.obtenerCategorias(),
      );
      propuesta = recibo.aPropuestaCaptura(moneda: monedaBase);
      await capturas.actualizarPropuesta(id, propuesta);
      final _ResultadoAuto? resultado =
          (propuesta.tipo != null && propuesta.montoCentavos != null)
              ? await _autoConfirmar(id, propuesta)
              : null;
      final List<String> faltantes =
          resultado == null ? _faltantesDe(propuesta) : <String>[];
      return _json(201, <String, Object?>{
        'captura_id': id,
        'estado': resultado == null
            ? EstadoCaptura.listo.valorDb
            : EstadoCaptura.confirmado.valorDb,
        'transaccion_id': ?resultado?.transaccionId,
        'monto_centavos': ?propuesta.montoCentavos,
        'comercio': recibo.comercio,
        'resumen': recibo.resumen,
        'faltantes': faltantes,
        'incompleta': resultado?.incompleta ?? false,
      });
    } on Object catch (error) {
      developer.log('OCR falló para $messageId: $error');
      propuesta = PropuestaCaptura(
        tipo: TipoTransaccion.gasto,
        moneda: monedaBase,
        confianza: ConfianzaPropuesta.baja,
        faltantes: const <String>['monto'],
        resumen: 'Recibo sin monto legible',
      );
      await capturas.actualizarPropuesta(id, propuesta);
      await capturas.marcarError(id, 'No se pudo leer el recibo: $error');
      return _json(201, <String, Object?>{
        'captura_id': id,
        'estado': EstadoCaptura.error.valorDb,
        'resumen': propuesta.resumen,
        'faltantes': <String>['monto'],
        'incompleta': true,
      });
    }
  }

  OrigenCaptura _origenDe(shelf.Request request) {
    return request.headers['x-bot-simulado'] == '1'
        ? OrigenCaptura.mock
        : OrigenCaptura.bot;
  }

  Future<PropuestaCaptura> _proponer(String texto) async {
    final List<Categoria> categoriasActuales =
        await categorias.obtenerCategorias();
    final List<Subcategoria> subcategorias =
        await categorias.obtenerSubcategorias();
    final List<Etiqueta> etiquetasActuales = await etiquetas.obtenerTodas();
    final List<Cuenta> cuentasActuales = await cuentas.obtenerTodas();
    final int? cuentaPorDefecto =
        await configuracion.obtenerCapturaCuentaId();
    final String monedaBase = await configuracion.obtenerMonedaBase();
    return parsearTexto(
      texto,
      ContextoParser(
        categorias: categoriasActuales,
        subcategorias: subcategorias,
        etiquetas: etiquetasActuales,
        cuentas: cuentasActuales,
        monedaBase: monedaBase,
        cuentaPorDefectoId: cuentaPorDefecto,
      ),
    );
  }

  Future<Map<String, Object?>> _leerJson(shelf.Request request) async {
    final String cuerpo = await request.readAsString();
    if (cuerpo.isEmpty) {
      throw const _ErrorHttp(400, 'PAYLOAD_INVALIDO', 'Cuerpo vacío.');
    }
    try {
      final Object? decodificado = jsonDecode(cuerpo);
      if (decodificado is Map) {
        return decodificado.map(
          (Object? clave, Object? valor) => MapEntry<String, Object?>(
            '$clave',
            valor,
          ),
        );
      }
    } on FormatException {
      throw const _ErrorHttp(400, 'PAYLOAD_INVALIDO', 'JSON mal formado.');
    }
    throw const _ErrorHttp(400, 'PAYLOAD_INVALIDO', 'Se esperaba un objeto JSON.');
  }

  Future<_Formulario> _leerMultipart(shelf.Request request) async {
    final String? tipo = request.headers['content-type'];
    if (tipo == null || !tipo.startsWith('multipart/form-data')) {
      throw const _ErrorHttp(
        400,
        'PAYLOAD_INVALIDO',
        'Se esperaba multipart/form-data.',
      );
    }
    final MediaType mediaType = MediaType.parse(tipo);
    final String? boundary = mediaType.parameters['boundary'];
    if (boundary == null) {
      throw const _ErrorHttp(
        400,
        'PAYLOAD_INVALIDO',
        'Falta el boundary del formulario.',
      );
    }

    final Map<String, String> campos = <String, String>{};
    Uint8List? archivo;
    String? nombreArchivo;
    String? mime;
    int total = 0;

    await for (final MimeMultipart part in request
        .read()
        .cast<List<int>>()
        .transform(MimeMultipartTransformer(boundary))) {
      final String disposicion = part.headers['content-disposition'] ?? '';
      final String? nombre = _parametroDisposicion(disposicion, 'name');
      final String? nombreDeArchivo =
          _parametroDisposicion(disposicion, 'filename');
      final Uint8List bytes = await part.fold<Uint8List>(
        Uint8List(0),
        (Uint8List anterior, List<int> nuevo) {
          final Uint8List resultado =
              Uint8List(anterior.length + nuevo.length);
          resultado.setRange(0, anterior.length, anterior);
          resultado.setRange(anterior.length, resultado.length, nuevo);
          return resultado;
        },
      );
      total += bytes.length;
      if (total > limiteBytes) {
        throw const _ErrorHttp(
          413,
          'DEMASIADO_GRANDE',
          'El archivo supera 8 MB.',
        );
      }
      if (nombreDeArchivo != null) {
        archivo = bytes;
        nombreArchivo = nombreDeArchivo;
        mime = part.headers['content-type'];
      } else if (nombre != null) {
        campos[nombre] = utf8.decode(bytes, allowMalformed: true);
      }
    }
    return _Formulario(
      campos: campos,
      archivo: archivo,
      nombreArchivo: nombreArchivo,
      mime: mime,
    );
  }

  String? _parametroDisposicion(String disposicion, String clave) {
    final RegExp patron = RegExp('$clave="([^"]*)"');
    final Match? coincidencia = patron.firstMatch(disposicion);
    return coincidencia?.group(1);
  }

  String? _textoObligatorio(Map<String, Object?> json, String clave) {
    final Object? valor = json[clave];
    if (valor is String && valor.isNotEmpty) {
      return valor;
    }
    return null;
  }

  int? _entero(Object? valor) {
    if (valor is int) {
      return valor;
    }
    if (valor is num) {
      return valor.toInt();
    }
    if (valor is String) {
      return int.tryParse(valor);
    }
    return null;
  }
}

shelf.Response _json(int estado, Map<String, Object?> cuerpo) {
  return shelf.Response(
    estado,
    body: jsonEncode(cuerpo),
    headers: const <String, String>{
      'content-type': 'application/json; charset=utf-8',
    },
  );
}

shelf.Response _error(
  int estado,
  String codigo,
  String mensaje, {
  String? campo,
  Map<String, Object?>? extra,
}) {
  return _json(estado, <String, Object?>{
    'error': <String, Object?>{
      'codigo': codigo,
      'mensaje': mensaje,
      'campo': ?campo,
    },
    ...?extra,
  });
}

class _ErrorHttp implements Exception {
  const _ErrorHttp(
    this.estado,
    this.codigo,
    this.mensaje, {
    this.campo,
    this.extra,
  });

  final int estado;
  final String codigo;
  final String mensaje;
  final String? campo;
  final Map<String, Object?>? extra;
}

class _ResultadoAuto {
  const _ResultadoAuto({
    required this.transaccionId,
    required this.incompleta,
  });

  final int transaccionId;
  final bool incompleta;
}

class _Formulario {
  const _Formulario({
    required this.campos,
    this.archivo,
    this.nombreArchivo,
    this.mime,
  });

  final Map<String, String> campos;
  final Uint8List? archivo;
  final String? nombreArchivo;
  final String? mime;
}
