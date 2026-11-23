import 'package:drift/drift.dart';

import '../../core/utils/fechas.dart';
import '../../domain/entities/etiqueta.dart';
import '../../domain/entities/transaccion.dart';
import '../database/app_database.dart';

/// Acceso a datos de transacciones.
class TransaccionesRepository {
  TransaccionesRepository(this._db);

  final AppDatabase _db;

  static const String _sqlBase = '''
SELECT t.id AS id,
       t.tipo AS tipo,
       t.monto_centavos AS monto_centavos,
       t.moneda AS moneda,
       t.cuenta_id AS cuenta_id,
       t.cuenta_destino_id AS cuenta_destino_id,
       t.monto_destino_centavos AS monto_destino_centavos,
       t.moneda_destino AS moneda_destino,
       t.categoria_id AS categoria_id,
       t.subcategoria_id AS subcategoria_id,
       t.fecha AS fecha,
       t.fecha_hora AS fecha_hora,
       t.nota AS nota,
       t.tasa_cambio AS tasa_cambio,
       t.estado AS estado,
       t.origen AS origen,
       GROUP_CONCAT(e.id, '|') AS etiquetas_ids,
       GROUP_CONCAT(e.nombre, '|') AS etiquetas_nombres
FROM transacciones t
LEFT JOIN transaccion_etiquetas te ON te.transaccion_id = t.id
LEFT JOIN etiquetas e ON e.id = te.etiqueta_id AND e.eliminado_en IS NULL
WHERE t.eliminado_en IS NULL
GROUP BY t.id
ORDER BY t.fecha_hora DESC, t.id DESC
''';

  Set<ResultSetImplementation<dynamic, dynamic>> get _tablas => {
        _db.transacciones,
        _db.transaccionEtiquetas,
        _db.etiquetas,
      };

  Stream<List<Transaccion>> watchTodas() {
    return _db
        .customSelect(_sqlBase, readsFrom: _tablas)
        .watch()
        .map((filas) => filas.map(_desdeFila).toList());
  }

  Future<List<Transaccion>> obtenerTodas() async {
    final filas =
        await _db.customSelect(_sqlBase, readsFrom: _tablas).get();
    return filas.map(_desdeFila).toList();
  }

  Future<Transaccion?> obtener(int id) async {
    final filas = await _db.customSelect(
      '''
SELECT t.id AS id, t.tipo AS tipo, t.monto_centavos AS monto_centavos,
       t.moneda AS moneda, t.cuenta_id AS cuenta_id,
       t.cuenta_destino_id AS cuenta_destino_id,
       t.monto_destino_centavos AS monto_destino_centavos,
       t.moneda_destino AS moneda_destino,
       t.categoria_id AS categoria_id, t.subcategoria_id AS subcategoria_id,
       t.fecha AS fecha, t.fecha_hora AS fecha_hora, t.nota AS nota,
       t.tasa_cambio AS tasa_cambio, t.estado AS estado, t.origen AS origen,
       GROUP_CONCAT(e.id, '|') AS etiquetas_ids,
       GROUP_CONCAT(e.nombre, '|') AS etiquetas_nombres
FROM transacciones t
LEFT JOIN transaccion_etiquetas te ON te.transaccion_id = t.id
LEFT JOIN etiquetas e ON e.id = te.etiqueta_id AND e.eliminado_en IS NULL
WHERE t.eliminado_en IS NULL AND t.id = ?1
GROUP BY t.id
''',
      variables: [Variable.withInt(id)],
      readsFrom: _tablas,
    ).get();
    return filas.isEmpty ? null : _desdeFila(filas.first);
  }

  Future<int> crear({
    required TipoTransaccion tipo,
    required int montoCentavos,
    required String moneda,
    required int cuentaId,
    required String fecha,
    required int fechaHora,
    List<int> etiquetaIds = const <int>[],
    int? cuentaDestinoId,
    int? montoDestinoCentavos,
    String? monedaDestino,
    int? categoriaId,
    int? subcategoriaId,
    String? nota,
    double? tasaCambio,
    EstadoTransaccion estado = EstadoTransaccion.confirmada,
    OrigenTransaccion origen = OrigenTransaccion.manual,
  }) {
    return _db.transaction(() async {
      final id = await _db.into(_db.transacciones).insert(
            TransaccionesCompanion.insert(
              tipo: tipo.valorDb,
              montoCentavos: montoCentavos,
              moneda: moneda,
              cuentaId: cuentaId,
              fecha: fecha,
              fechaHora: fechaHora,
              cuentaDestinoId: Value<int?>(cuentaDestinoId),
              montoDestinoCentavos: Value<int?>(montoDestinoCentavos),
              monedaDestino: Value<String?>(monedaDestino),
              categoriaId: Value<int?>(categoriaId),
              subcategoriaId: Value<int?>(subcategoriaId),
              nota: Value<String?>(nota),
              tasaCambio: Value<double?>(tasaCambio),
              estado: Value<String>(estado.valorDb),
              origen: Value<String>(origen.valorDb),
              creadoEn: ahoraMs(),
              actualizadoEn: ahoraMs(),
            ),
          );
      await _reemplazarEtiquetas(id, etiquetaIds);
      return id;
    });
  }

  Future<void> actualizar({
    required int id,
    required TipoTransaccion tipo,
    required int montoCentavos,
    required String moneda,
    required int cuentaId,
    required String fecha,
    required int fechaHora,
    List<int> etiquetaIds = const <int>[],
    int? cuentaDestinoId,
    int? montoDestinoCentavos,
    String? monedaDestino,
    int? categoriaId,
    int? subcategoriaId,
    String? nota,
    double? tasaCambio,
  }) {
    return _db.transaction(() async {
      await (_db.update(_db.transacciones)
            ..where((t) => t.id.equals(id)))
          .write(
        TransaccionesCompanion(
          tipo: Value<String>(tipo.valorDb),
          montoCentavos: Value<int>(montoCentavos),
          moneda: Value<String>(moneda),
          cuentaId: Value<int>(cuentaId),
          cuentaDestinoId: Value<int?>(cuentaDestinoId),
          montoDestinoCentavos: Value<int?>(montoDestinoCentavos),
          monedaDestino: Value<String?>(monedaDestino),
          categoriaId: Value<int?>(categoriaId),
          subcategoriaId: Value<int?>(subcategoriaId),
          fecha: Value<String>(fecha),
          fechaHora: Value<int>(fechaHora),
          nota: Value<String?>(nota),
          tasaCambio: Value<double?>(tasaCambio),
          actualizadoEn: Value<int>(ahoraMs()),
        ),
      );
      await _reemplazarEtiquetas(id, etiquetaIds);
    });
  }

  Future<void> eliminarLogico(int id) {
    return (_db.update(_db.transacciones)..where((t) => t.id.equals(id))).write(
      TransaccionesCompanion(
        eliminadoEn: Value<int>(ahoraMs()),
        actualizadoEn: Value<int>(ahoraMs()),
      ),
    );
  }

  Future<void> _reemplazarEtiquetas(int transaccionId, List<int> ids) async {
    await (_db.delete(_db.transaccionEtiquetas)
          ..where((t) => t.transaccionId.equals(transaccionId)))
        .go();
    final Set<int> unicos = ids.toSet();
    for (final int etiquetaId in unicos) {
      await _db.into(_db.transaccionEtiquetas).insert(
            TransaccionEtiquetasCompanion.insert(
              transaccionId: transaccionId,
              etiquetaId: etiquetaId,
            ),
          );
    }
  }
}

Transaccion _desdeFila(QueryRow fila) {
  final List<EtiquetaRef> etiquetas = <EtiquetaRef>[];
  final ids = fila.readNullable<String>('etiquetas_ids');
  final nombres = fila.readNullable<String>('etiquetas_nombres');
  if (ids != null && nombres != null) {
    final listaIds = ids.split('|');
    final listaNombres = nombres.split('|');
    final total =
        listaIds.length < listaNombres.length ? listaIds.length : listaNombres.length;
    for (int i = 0; i < total; i++) {
      final etiquetaId = int.tryParse(listaIds[i]);
      if (etiquetaId != null) {
        etiquetas.add(EtiquetaRef(id: etiquetaId, nombre: listaNombres[i]));
      }
    }
  }

  return Transaccion(
    id: fila.read<int>('id'),
    tipo: TipoTransaccion.desdeDb(fila.read<String>('tipo')),
    montoCentavos: fila.read<int>('monto_centavos'),
    moneda: fila.read<String>('moneda'),
    cuentaId: fila.read<int>('cuenta_id'),
    cuentaDestinoId: fila.readNullable<int>('cuenta_destino_id'),
    montoDestinoCentavos: fila.readNullable<int>('monto_destino_centavos'),
    monedaDestino: fila.readNullable<String>('moneda_destino'),
    categoriaId: fila.readNullable<int>('categoria_id'),
    subcategoriaId: fila.readNullable<int>('subcategoria_id'),
    fecha: fila.read<String>('fecha'),
    fechaHora: fila.read<int>('fecha_hora'),
    nota: fila.readNullable<String>('nota'),
    tasaCambio: fila.readNullable<double>('tasa_cambio'),
    estado: EstadoTransaccion.desdeDb(fila.read<String>('estado')),
    origen: OrigenTransaccion.desdeDb(fila.read<String>('origen')),
    etiquetas: etiquetas,
  );
}
