import 'package:drift/drift.dart';

import '../../core/utils/fechas.dart';
import '../../domain/entities/cuenta.dart';
import '../database/app_database.dart';

/// Acceso a datos de cuentas.
class CuentasRepository {
  CuentasRepository(this._db);

  final AppDatabase _db;

  Stream<List<Cuenta>> watchTodas() {
    final query = _db.select(_db.cuentas)
      ..where((t) => t.eliminadoEn.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.nombre)]);
    return query.watch().map(
      (filas) => filas.map(_aDominio).toList(),
    );
  }

  Future<List<Cuenta>> obtenerTodas() async {
    final filas = await (_db.select(
      _db.cuentas,
    )..where((t) => t.eliminadoEn.isNull()))
        .get();
    return filas.map(_aDominio).toList();
  }

  Future<Cuenta?> obtener(int id) async {
    final fila = await (_db.select(
      _db.cuentas,
    )..where((t) => t.id.equals(id) & t.eliminadoEn.isNull()))
        .getSingleOrNull();
    return fila == null ? null : _aDominio(fila);
  }

  Future<int> crear({
    required String nombre,
    required TipoCuenta tipo,
    required int saldoInicialCentavos,
    required String moneda,
    required bool activa,
    String? nota,
  }) {
    return _db.into(_db.cuentas).insert(
          CuentasCompanion.insert(
            nombre: nombre,
            tipo: tipo.valorDb,
            saldoInicialCentavos: Value<int>(saldoInicialCentavos),
            moneda: Value<String>(moneda),
            activa: Value<bool>(activa),
            nota: Value<String?>(nota),
            creadoEn: ahoraMs(),
            actualizadoEn: ahoraMs(),
          ),
        );
  }

  Future<void> actualizar({
    required int id,
    required String nombre,
    required TipoCuenta tipo,
    required int saldoInicialCentavos,
    required String moneda,
    required bool activa,
    String? nota,
  }) {
    return (_db.update(_db.cuentas)..where((t) => t.id.equals(id))).write(
      CuentasCompanion(
        nombre: Value<String>(nombre),
        tipo: Value<String>(tipo.valorDb),
        saldoInicialCentavos: Value<int>(saldoInicialCentavos),
        moneda: Value<String>(moneda),
        activa: Value<bool>(activa),
        nota: Value<String?>(nota),
        actualizadoEn: Value<int>(ahoraMs()),
      ),
    );
  }

  Future<void> eliminarLogico(int id) {
    return (_db.update(_db.cuentas)..where((t) => t.id.equals(id))).write(
      CuentasCompanion(
        eliminadoEn: Value<int>(ahoraMs()),
        actualizadoEn: Value<int>(ahoraMs()),
      ),
    );
  }

  Future<void> cambiarActiva(int id, bool activa) {
    return (_db.update(_db.cuentas)..where((t) => t.id.equals(id))).write(
      CuentasCompanion(
        activa: Value<bool>(activa),
        actualizadoEn: Value<int>(ahoraMs()),
      ),
    );
  }

  /// Indica si la cuenta tiene movimientos (como origen o como destino).
  Future<bool> tieneTransacciones(int cuentaId) async {
    final fila = await _db.customSelect(
      'SELECT COUNT(*) AS total FROM transacciones '
      'WHERE eliminado_en IS NULL AND (cuenta_id = ?1 OR cuenta_destino_id = ?1)',
      variables: [Variable.withInt(cuentaId)],
    ).getSingle();
    return fila.read<int>('total') > 0;
  }
}

Cuenta _aDominio(CuentaRow fila) {
  return Cuenta(
    id: fila.id,
    nombre: fila.nombre,
    tipo: TipoCuenta.desdeDb(fila.tipo),
    saldoInicialCentavos: fila.saldoInicialCentavos,
    moneda: fila.moneda,
    activa: fila.activa,
    nota: fila.nota,
  );
}
