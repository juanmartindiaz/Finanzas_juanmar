import 'package:drift/drift.dart';

import '../../core/utils/fechas.dart';
import '../../domain/entities/tasa_cambio.dart';
import '../database/app_database.dart';

/// Acceso a datos de tasas de cambio manuales.
class TasasRepository {
  TasasRepository(this._db);

  final AppDatabase _db;

  Stream<List<TasaCambio>> watchTodas() {
    final query = _db.select(_db.tasasCambio)
      ..orderBy([
        (t) => OrderingTerm(expression: t.fecha, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
      (filas) => filas.map(_aDominio).toList(),
    );
  }

  Future<List<TasaCambio>> obtenerTodas() async {
    final filas = await _db.select(_db.tasasCambio).get();
    return filas.map(_aDominio).toList();
  }

  /// Guarda la tasa del día de hoy para el par (actualiza si ya existía).
  Future<void> guardar({
    required String monedaOrigen,
    required String monedaDestino,
    required double valor,
  }) async {
    final fecha = fechaIso(DateTime.now());
    final existente = await (_db.select(_db.tasasCambio)
          ..where(
            (t) =>
                t.monedaOrigen.equals(monedaOrigen) &
                t.monedaDestino.equals(monedaDestino) &
                t.fecha.equals(fecha),
          ))
        .getSingleOrNull();

    if (existente == null) {
      await _db.into(_db.tasasCambio).insert(
            TasasCambioCompanion.insert(
              monedaOrigen: monedaOrigen,
              monedaDestino: monedaDestino,
              valor: valor,
              fecha: fecha,
              fuente: FuenteTasa.manual.valorDb,
              creadoEn: ahoraMs(),
            ),
          );
    } else {
      await (_db.update(_db.tasasCambio)
            ..where((t) => t.id.equals(existente.id)))
          .write(TasasCambioCompanion(valor: Value<double>(valor)));
    }
  }

  Future<void> eliminar(int id) {
    return (_db.delete(_db.tasasCambio)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}

TasaCambio _aDominio(TasaCambioRow fila) {
  return TasaCambio(
    id: fila.id,
    monedaOrigen: fila.monedaOrigen,
    monedaDestino: fila.monedaDestino,
    valor: fila.valor,
    fecha: fila.fecha,
    fuente: FuenteTasa.desdeDb(fila.fuente),
  );
}
