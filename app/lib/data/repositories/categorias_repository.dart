import 'package:drift/drift.dart';

import '../../core/utils/fechas.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/subcategoria.dart';
import '../database/app_database.dart';

/// Acceso a datos de categorías y subcategorías.
class CategoriasRepository {
  CategoriasRepository(this._db);

  final AppDatabase _db;

  Stream<List<Categoria>> watchCategorias() {
    final query = _db.select(_db.categorias)
      ..where((t) => t.eliminadoEn.isNull())
      ..orderBy([
        (t) => OrderingTerm(expression: t.orden),
        (t) => OrderingTerm(expression: t.nombre),
      ]);
    return query.watch().map(
      (filas) => filas.map(_categoriaADominio).toList(),
    );
  }

  Stream<List<Subcategoria>> watchSubcategorias() {
    final query = _db.select(_db.subcategorias)
      ..where((t) => t.eliminadoEn.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.nombre)]);
    return query.watch().map(
      (filas) => filas.map(_subcategoriaADominio).toList(),
    );
  }

  Future<List<Categoria>> obtenerCategorias() async {
    final filas = await (_db.select(
      _db.categorias,
    )..where((t) => t.eliminadoEn.isNull()))
        .get();
    return filas.map(_categoriaADominio).toList();
  }

  Future<int> contarCategorias() async {
    final filas = await _db.select(_db.categorias).get();
    return filas.length;
  }

  Future<int> crearCategoria({
    required String nombre,
    required NaturalezaCategoria naturaleza,
    String? icono,
    String? color,
  }) {
    return _db.into(_db.categorias).insert(
          CategoriasCompanion.insert(
            nombre: nombre,
            naturaleza: naturaleza.valorDb,
            icono: Value<String?>(icono),
            color: Value<String?>(color),
            creadoEn: ahoraMs(),
            actualizadoEn: ahoraMs(),
          ),
        );
  }

  Future<void> actualizarCategoria({
    required int id,
    required String nombre,
    required NaturalezaCategoria naturaleza,
    String? icono,
    String? color,
  }) {
    return (_db.update(_db.categorias)..where((t) => t.id.equals(id))).write(
      CategoriasCompanion(
        nombre: Value<String>(nombre),
        naturaleza: Value<String>(naturaleza.valorDb),
        icono: Value<String?>(icono),
        color: Value<String?>(color),
        actualizadoEn: Value<int>(ahoraMs()),
      ),
    );
  }

  Future<void> archivarCategoria(int id, {required bool archivada}) {
    return (_db.update(_db.categorias)..where((t) => t.id.equals(id))).write(
      CategoriasCompanion(
        archivada: Value<bool>(archivada),
        actualizadoEn: Value<int>(ahoraMs()),
      ),
    );
  }

  Future<void> eliminarCategoriaLogico(int id) {
    return (_db.update(_db.categorias)..where((t) => t.id.equals(id))).write(
      CategoriasCompanion(
        eliminadoEn: Value<int>(ahoraMs()),
        actualizadoEn: Value<int>(ahoraMs()),
      ),
    );
  }

  Future<bool> categoriaTieneTransacciones(int categoriaId) async {
    final fila = await _db.customSelect(
      'SELECT COUNT(*) AS total FROM transacciones '
      'WHERE eliminado_en IS NULL AND categoria_id = ?1',
      variables: [Variable.withInt(categoriaId)],
    ).getSingle();
    return fila.read<int>('total') > 0;
  }

  Future<int> crearSubcategoria({
    required int categoriaId,
    required String nombre,
  }) {
    return _db.into(_db.subcategorias).insert(
          SubcategoriasCompanion.insert(
            categoriaId: categoriaId,
            nombre: nombre,
            creadoEn: ahoraMs(),
            actualizadoEn: ahoraMs(),
          ),
        );
  }

  Future<void> actualizarSubcategoria({
    required int id,
    required String nombre,
  }) {
    return (_db.update(_db.subcategorias)
          ..where((t) => t.id.equals(id)))
        .write(
      SubcategoriasCompanion(
        nombre: Value<String>(nombre),
        actualizadoEn: Value<int>(ahoraMs()),
      ),
    );
  }

  Future<void> archivarSubcategoria(int id, {required bool archivada}) {
    return (_db.update(_db.subcategorias)
          ..where((t) => t.id.equals(id)))
        .write(
      SubcategoriasCompanion(
        archivada: Value<bool>(archivada),
        actualizadoEn: Value<int>(ahoraMs()),
      ),
    );
  }

  Future<void> eliminarSubcategoriaLogico(int id) {
    return (_db.update(_db.subcategorias)
          ..where((t) => t.id.equals(id)))
        .write(
      SubcategoriasCompanion(
        eliminadoEn: Value<int>(ahoraMs()),
        actualizadoEn: Value<int>(ahoraMs()),
      ),
    );
  }

  Future<bool> subcategoriaTieneTransacciones(int subcategoriaId) async {
    final fila = await _db.customSelect(
      'SELECT COUNT(*) AS total FROM transacciones '
      'WHERE eliminado_en IS NULL AND subcategoria_id = ?1',
      variables: [Variable.withInt(subcategoriaId)],
    ).getSingle();
    return fila.read<int>('total') > 0;
  }
}

Categoria _categoriaADominio(CategoriaRow fila) {
  return Categoria(
    id: fila.id,
    nombre: fila.nombre,
    naturaleza: NaturalezaCategoria.desdeDb(fila.naturaleza),
    icono: fila.icono,
    color: fila.color,
    predefinida: fila.predefinida,
    orden: fila.orden,
    archivada: fila.archivada,
  );
}

Subcategoria _subcategoriaADominio(SubcategoriaRow fila) {
  return Subcategoria(
    id: fila.id,
    categoriaId: fila.categoriaId,
    nombre: fila.nombre,
    predefinida: fila.predefinida,
    archivada: fila.archivada,
  );
}
