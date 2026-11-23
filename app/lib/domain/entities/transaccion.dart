/// Transacciones: ingresos, gastos y transferencias.
library;

import 'etiqueta.dart';

/// Tipo de movimiento.
enum TipoTransaccion {
  ingreso('ingreso', 'Ingreso'),
  gasto('gasto', 'Gasto'),
  transferencia('transferencia', 'Transferencia');

  const TipoTransaccion(this.valorDb, this.etiqueta);

  final String valorDb;
  final String etiqueta;

  static TipoTransaccion desdeDb(String valor) => values.firstWhere(
    (TipoTransaccion tipo) => tipo.valorDb == valor,
    orElse: () => TipoTransaccion.gasto,
  );
}

/// Estado de la transacción. `pendiente` queda reservado para el bot (Fase 2).
enum EstadoTransaccion {
  confirmada('confirmada', 'Confirmada'),
  pendiente('pendiente', 'Pendiente');

  const EstadoTransaccion(this.valorDb, this.etiqueta);

  final String valorDb;
  final String etiqueta;

  static EstadoTransaccion desdeDb(String valor) => values.firstWhere(
    (EstadoTransaccion estado) => estado.valorDb == valor,
    orElse: () => EstadoTransaccion.confirmada,
  );
}

/// Origen del registro.
enum OrigenTransaccion {
  manual('manual', 'Manual'),
  bot('bot', 'Bot'),
  importado('importado', 'Importado');

  const OrigenTransaccion(this.valorDb, this.etiqueta);

  final String valorDb;
  final String etiqueta;

  static OrigenTransaccion desdeDb(String valor) => values.firstWhere(
    (OrigenTransaccion origen) => origen.valorDb == valor,
    orElse: () => OrigenTransaccion.manual,
  );
}

/// Movimiento financiero.
class Transaccion {
  const Transaccion({
    required this.id,
    required this.tipo,
    required this.montoCentavos,
    required this.moneda,
    required this.cuentaId,
    required this.fecha,
    required this.fechaHora,
    required this.estado,
    required this.origen,
    this.cuentaDestinoId,
    this.montoDestinoCentavos,
    this.monedaDestino,
    this.categoriaId,
    this.subcategoriaId,
    this.nota,
    this.tasaCambio,
    this.etiquetas = const <EtiquetaRef>[],
  });

  final int id;
  final TipoTransaccion tipo;

  /// Monto en la moneda de la cuenta origen.
  final int montoCentavos;
  final String moneda;
  final int cuentaId;

  /// Solo en transferencias: cuenta que recibe.
  final int? cuentaDestinoId;

  /// Solo en transferencias: monto que llega a la cuenta destino.
  final int? montoDestinoCentavos;
  final String? monedaDestino;
  final int? categoriaId;
  final int? subcategoriaId;

  /// Fecha de calendario `YYYY-MM-DD` elegida por el usuario.
  final String fecha;

  /// Fecha y hora (epoch ms) elegidas por el usuario; ordena el listado.
  final int fechaHora;
  final String? nota;

  /// Tasa efectiva usada (destino por 1 origen), solo si cambia de moneda.
  final double? tasaCambio;
  final EstadoTransaccion estado;
  final OrigenTransaccion origen;
  final List<EtiquetaRef> etiquetas;

  bool get esTransferencia => tipo == TipoTransaccion.transferencia;

  /// Monto que recibe la cuenta destino (si no se guardó, es el mismo monto).
  int get montoDestinoEfectivo => montoDestinoCentavos ?? montoCentavos;

  Transaccion copyWith({
    TipoTransaccion? tipo,
    int? montoCentavos,
    String? moneda,
    int? cuentaId,
    int? cuentaDestinoId,
    int? montoDestinoCentavos,
    String? monedaDestino,
    int? categoriaId,
    int? subcategoriaId,
    String? fecha,
    int? fechaHora,
    String? nota,
    double? tasaCambio,
    List<EtiquetaRef>? etiquetas,
  }) {
    return Transaccion(
      id: id,
      tipo: tipo ?? this.tipo,
      montoCentavos: montoCentavos ?? this.montoCentavos,
      moneda: moneda ?? this.moneda,
      cuentaId: cuentaId ?? this.cuentaId,
      cuentaDestinoId: cuentaDestinoId ?? this.cuentaDestinoId,
      montoDestinoCentavos: montoDestinoCentavos ?? this.montoDestinoCentavos,
      monedaDestino: monedaDestino ?? this.monedaDestino,
      categoriaId: categoriaId ?? this.categoriaId,
      subcategoriaId: subcategoriaId ?? this.subcategoriaId,
      fecha: fecha ?? this.fecha,
      fechaHora: fechaHora ?? this.fechaHora,
      nota: nota ?? this.nota,
      tasaCambio: tasaCambio ?? this.tasaCambio,
      estado: estado,
      origen: origen,
      etiquetas: etiquetas ?? this.etiquetas,
    );
  }
}
