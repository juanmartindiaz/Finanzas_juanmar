import 'package:drift/drift.dart';

import '../../core/utils/fechas.dart';
import '../../domain/entities/etiqueta.dart';
import '../database/app_database.dart';

/// Acceso a datos de etiquetas.
class EtiquetasRepository {
  EtiquetasRepository(this._db);

  final AppDatabase _db;

  Stream<List<Etiqueta>> watchTodas() {
    final query = _db.select(_db.etiquetas)
      ..where((t) => t.eliminadoEn.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.nombre)]);
    return query.watch().map(
      (filas) => filas.map(_aDominio).toList(),
    );
  }

  Future<List<Etiqueta>> obtenerTodas() async {
    final filas = await (_db.select(
      _db.etiquetas,
    )..where((t) => t.eliminadoEn.isNull()))
        .get();
    return filas.map(_aDominio).toList();
  }

  Future<int> crear({required String nombre, String? color}) {
    return _db.into(_db.etiquetas).insert(
          EtiquetasCompanion.insert(
            nombre: nombre,
            color: Value<String?>(color),
            creadoEn: ahoraMs(),
            actualizadoEn: ahoraMs(),
          ),
        );
  }

  Future<void> actualizar({
    required int id,
    required String nombre,
    String? color,
  }) {
    return (_db.update(_db.etiquetas)..where((t) => t.id.equals(id))).write(
      EtiquetasCompanion(
        nombre: Value<String>(nombre),
        color: Value<String?>(color),
        actualizadoEn: Value<int>(ahoraMs()),
      ),
    );
  }

  /// Borra la etiqueta y la quita de todas sus transacciones (no borra las
  /// transacciones).
  Future<void> eliminar(int id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.transaccionEtiquetas)
            ..where((t) => t.etiquetaId.equals(id)))
          .go();
      await (_db.update(_db.etiquetas)..where((t) => t.id.equals(id))).write(
        EtiquetasCompanion(
          eliminadoEn: Value<int>(ahoraMs()),
          actualizadoEn: Value<int>(ahoraMs()),
        ),
      );
    });
  }
}

Etiqueta _aDominio(EtiquetaRow fila) {
  return Etiqueta(id: fila.id, nombre: fila.nombre, color: fila.color);
}
