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
import '../../domain/parsers/parser_texto.dart';
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
  });

  static const int limiteBytes = 8 * 1024 * 1024;
  static const int limiteTexto = 4000;

  final ConfiguracionRepository configuracion;
  final CapturasRepository capturas;
  final CategoriasRepository categorias;
  final EtiquetasRepository etiquetas;
  final CuentasRepository cuentas;
  final AlmacenAdjuntos almacen;

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
    return _json(201, <String, Object?>{
      'captura_id': id,
      'estado': EstadoCaptura.listo.valorDb,
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
    final EstadoCaptura estado =
        esAudio ? EstadoCaptura.pendiente : EstadoCaptura.listo;
    final int id = await capturas.crearDesdeCanal(
      messageId: messageId,
      canal: canal,
      estado: estado,
      origen: _origenDe(request),
      timestamp: timestamp,
      adjuntoPath: ruta,
    );
    return _json(201, <String, Object?>{
      'captura_id': id,
      'estado': estado.valorDb,
    });
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
    final int? cuentaPorDefecto = await configuracion.obtenerCapturaCuentaId();
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
