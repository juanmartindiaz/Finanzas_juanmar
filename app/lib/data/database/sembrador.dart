import 'package:drift/drift.dart';

import '../../core/utils/fechas.dart';
import '../../domain/usecases/semilla.dart';
import 'app_database.dart';
import 'semilla_datos.dart';

/// Inserta la semilla inicial de categorías **una sola vez**.
///
/// Regla: si ya existe la clave `seed_categorias_v1` o si ya hay categorías
/// (aunque estén borradas), no se inserta nada (ADR-027).
class SembradorCategorias {
  SembradorCategorias(this._db);

  final AppDatabase _db;

  static const String claveMarcador = 'seed_categorias_v1';
  static const String claveMonedaBase = 'moneda_base';

  Future<void> ejecutarSiHaceFalta() async {
    final ConfiguracionRow? marcador = await (_db.select(
      _db.configuracion,
    )..where((t) => t.clave.equals(claveMarcador)))
        .getSingleOrNull();

    final List<CategoriaRow> existentes = await _db.select(_db.categorias).get();

    if (debeSembrarCategorias(
      yaSeSembro: marcador != null,
      categoriasExistentes: existentes.length,
    )) {
      await _db.transaction(() async {
        for (int indice = 0; indice < semillaCategorias.length; indice++) {
          final SemillaCategoria semilla = semillaCategorias[indice];
          final int categoriaId = await _db.into(_db.categorias).insert(
                CategoriasCompanion.insert(
                  nombre: semilla.nombre,
                  naturaleza: semilla.naturaleza.valorDb,
                  icono: Value<String>(semilla.icono),
                  color: Value<String>(semilla.color),
                  predefinida: const Value<bool>(true),
                  orden: Value<int>(indice),
                  creadoEn: ahoraMs(),
                  actualizadoEn: ahoraMs(),
                ),
              );

          for (final String nombreSubcategoria in semilla.subcategorias) {
            await _db.into(_db.subcategorias).insert(
                  SubcategoriasCompanion.insert(
                    categoriaId: categoriaId,
                    nombre: nombreSubcategoria,
                    predefinida: const Value<bool>(true),
                    creadoEn: ahoraMs(),
                    actualizadoEn: ahoraMs(),
                  ),
                );
          }
        }
      });
    }

    await _marcarSembrado();
    await _asegurarMonedaBase();
  }

  Future<void> _marcarSembrado() async {
    final ConfiguracionRow? marcador = await (_db.select(
      _db.configuracion,
    )..where((t) => t.clave.equals(claveMarcador)))
        .getSingleOrNull();
    if (marcador == null) {
      await _db.into(_db.configuracion).insert(
            ConfiguracionCompanion.insert(
              clave: claveMarcador,
              valor: '1',
              actualizadoEn: ahoraMs(),
            ),
          );
    }
  }

  Future<void> _asegurarMonedaBase() async {
    final ConfiguracionRow? moneda = await (_db.select(
      _db.configuracion,
    )..where((t) => t.clave.equals(claveMonedaBase)))
        .getSingleOrNull();
    if (moneda == null) {
      await _db.into(_db.configuracion).insert(
            ConfiguracionCompanion.insert(
              clave: claveMonedaBase,
              valor: 'COP',
              actualizadoEn: ahoraMs(),
            ),
          );
    }
  }
}
