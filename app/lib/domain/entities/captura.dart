/// Capturas entrantes: lo que llega del bot o del simulador antes de que el
/// usuario confirme. Nunca crea una transacción por sí sola (ADR-031).
library;

import 'transaccion.dart';

/// Canal por el que llegó la captura.
enum CanalCaptura {
  texto('texto', 'Texto'),
  audio('audio', 'Audio'),
  foto('foto', 'Foto'),
  app('app', 'Manual');

  const CanalCaptura(this.valorDb, this.etiqueta);

  final String valorDb;
  final String etiqueta;

  static CanalCaptura desdeDb(String valor) => values.firstWhere(
    (CanalCaptura canal) => canal.valorDb == valor,
    orElse: () => CanalCaptura.texto,
  );
}

/// Quién originó la captura.
enum OrigenCaptura {
  mock('mock', 'Simulador'),
  bot('bot', 'Bot'),
  manual('manual', 'Manual');

  const OrigenCaptura(this.valorDb, this.etiqueta);

  final String valorDb;
  final String etiqueta;

  static OrigenCaptura desdeDb(String valor) => values.firstWhere(
    (OrigenCaptura origen) => origen.valorDb == valor,
    orElse: () => OrigenCaptura.manual,
  );
}

/// Estado de la captura en la bandeja.
enum EstadoCaptura {
  pendiente('pendiente', 'Pendiente'),
  procesando('procesando', 'Procesando'),
  listo('listo', 'Listo para revisar'),
  confirmado('confirmado', 'Confirmado'),
  descartado('descartado', 'Descartado'),
  error('error', 'Con error');

  const EstadoCaptura(this.valorDb, this.etiqueta);

  final String valorDb;
  final String etiqueta;

  static EstadoCaptura desdeDb(String valor) => values.firstWhere(
    (EstadoCaptura estado) => estado.valorDb == valor,
    orElse: () => EstadoCaptura.pendiente,
  );
}

/// Nivel de confianza del parser.
enum ConfianzaPropuesta {
  alta('alta', 'Confianza alta'),
  media('media', 'Confianza media'),
  baja('baja', 'Requiere revisión');

  const ConfianzaPropuesta(this.valorDb, this.etiqueta);

  final String valorDb;
  final String etiqueta;

  static ConfianzaPropuesta desdeDb(String valor) => values.firstWhere(
    (ConfianzaPropuesta confianza) => confianza.valorDb == valor,
    orElse: () => ConfianzaPropuesta.baja,
  );

  static ConfianzaPropuesta desdeValor(Object? valor) {
    if (valor is String) {
      for (final ConfianzaPropuesta confianza in values) {
        if (confianza.valorDb == valor) {
          return confianza;
        }
      }
    }
    return ConfianzaPropuesta.baja;
  }
}

/// Propuesta que hace el parser a partir de un texto. Solo es una sugerencia:
/// el usuario puede cambiarla toda antes de confirmar.
class PropuestaCaptura {
  const PropuestaCaptura({
    this.tipo,
    this.montoCentavos,
    required this.moneda,
    this.cuentaId,
    this.cuentaNombre,
    this.categoriaId,
    this.categoriaNombre,
    this.subcategoriaId,
    this.subcategoriaNombre,
    this.etiquetaIds = const <int>[],
    this.etiquetaNombres = const <String>[],
    required this.confianza,
    this.faltantes = const <String>[],
    this.resumen = '',
  });

  final TipoTransaccion? tipo;
  final int? montoCentavos;
  final String moneda;
  final int? cuentaId;
  final String? cuentaNombre;
  final int? categoriaId;
  final String? categoriaNombre;
  final int? subcategoriaId;
  final String? subcategoriaNombre;
  final List<int> etiquetaIds;
  final List<String> etiquetaNombres;
  final ConfianzaPropuesta confianza;

  /// Campos que el parser no pudo completar ("monto", "categoría", ...).
  final List<String> faltantes;
  final String resumen;

  bool get estaCompleta => faltantes.isEmpty && confianza == ConfianzaPropuesta.alta;

  Map<String, Object?> toJson() => <String, Object?>{
    'tipo': tipo?.valorDb,
    'monto_centavos': montoCentavos,
    'moneda': moneda,
    'cuenta_id': cuentaId,
    'cuenta_nombre': cuentaNombre,
    'categoria_id': categoriaId,
    'categoria_nombre': categoriaNombre,
    'subcategoria_id': subcategoriaId,
    'subcategoria_nombre': subcategoriaNombre,
    'etiqueta_ids': etiquetaIds,
    'etiqueta_nombres': etiquetaNombres,
    'confianza': confianza.valorDb,
    'faltantes': faltantes,
    'resumen': resumen,
  };

  static PropuestaCaptura desdeJson(Map<String, Object?> json) {
    final String moneda = (json['moneda'] as String?) ?? 'COP';
    return PropuestaCaptura(
      tipo: json['tipo'] is String
          ? TipoTransaccion.desdeDb(json['tipo'] as String)
          : null,
      montoCentavos: _entero(json['monto_centavos']),
      moneda: moneda,
      cuentaId: _entero(json['cuenta_id']),
      cuentaNombre: json['cuenta_nombre'] as String?,
      categoriaId: _entero(json['categoria_id']),
      categoriaNombre: json['categoria_nombre'] as String?,
      subcategoriaId: _entero(json['subcategoria_id']),
      subcategoriaNombre: json['subcategoria_nombre'] as String?,
      etiquetaIds: _enteros(json['etiqueta_ids']),
      etiquetaNombres: _textos(json['etiqueta_nombres']),
      confianza: ConfianzaPropuesta.desdeValor(json['confianza']),
      faltantes: _textos(json['faltantes']),
      resumen: (json['resumen'] as String?) ?? '',
    );
  }

  static int? _entero(Object? valor) {
    if (valor is int) {
      return valor;
    }
    if (valor is num) {
      return valor.toInt();
    }
    return int.tryParse('$valor');
  }

  static List<int> _enteros(Object? valor) {
    if (valor is List) {
      return valor
          .map((Object? elemento) => _entero(elemento))
          .whereType<int>()
          .toList();
    }
    return const <int>[];
  }

  static List<String> _textos(Object? valor) {
    if (valor is List) {
      return valor.map((Object? elemento) => '$elemento').toList();
    }
    return const <String>[];
  }
}

/// Fila de la bandeja de capturas.
class CapturaEntrante {
  const CapturaEntrante({
    required this.id,
    required this.canal,
    required this.origen,
    required this.estado,
    required this.createdAt,
    this.messageIdExterno,
    this.textoCrudo,
    this.adjuntoPath,
    this.propuesta,
    this.errorDetalle,
    this.transaccionId,
    this.procesadaAt,
    this.incompleta = false,
  });

  final int id;
  final CanalCaptura canal;
  final OrigenCaptura origen;
  final String? messageIdExterno;
  final String? textoCrudo;
  final String? adjuntoPath;
  final EstadoCaptura estado;
  final PropuestaCaptura? propuesta;
  final String? errorDetalle;
  final int? transaccionId;
  final int createdAt;
  final int? procesadaAt;
  /// `true` cuando se usaron valores por defecto (cuenta/categoría).
  final bool incompleta;

  bool get estaAbierta =>
      estado == EstadoCaptura.pendiente || estado == EstadoCaptura.listo;

  String get resumen {
    if (propuesta != null && propuesta!.resumen.isNotEmpty) {
      return propuesta!.resumen;
    }
    if (textoCrudo != null && textoCrudo!.trim().isNotEmpty) {
      return textoCrudo!.trim();
    }
    if (canal == CanalCaptura.foto) {
      return 'Foto recibida (sin OCR todavía)';
    }
    if (canal == CanalCaptura.audio) {
      return 'Audio recibido (sin transcripción todavía)';
    }
    return 'Captura sin texto';
  }
}
