/// Tasas de cambio manuales.
library;

/// Fuente de la tasa.
enum FuenteTasa {
  manual('manual', 'Manual'),
  trm('trm', 'TRM'),
  apiAbierta('api_abierta', 'API abierta');

  const FuenteTasa(this.valorDb, this.etiqueta);

  final String valorDb;
  final String etiqueta;

  static FuenteTasa desdeDb(String valor) => values.firstWhere(
    (FuenteTasa fuente) => fuente.valorDb == valor,
    orElse: () => FuenteTasa.manual,
  );
}

/// Tasa de cambio: unidades de `monedaDestino` por 1 de `monedaOrigen`.
class TasaCambio {
  const TasaCambio({
    required this.id,
    required this.monedaOrigen,
    required this.monedaDestino,
    required this.valor,
    required this.fecha,
    required this.fuente,
  });

  final int id;
  final String monedaOrigen;
  final String monedaDestino;
  final double valor;

  /// Fecha de calendario `YYYY-MM-DD`.
  final String fecha;
  final FuenteTasa fuente;
}
