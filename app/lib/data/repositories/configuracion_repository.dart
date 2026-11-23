import '../../core/utils/dinero.dart';
import '../../core/utils/fechas.dart';
import '../database/app_database.dart';

/// Acceso a la configuración clave/valor.
class ConfiguracionRepository {
  ConfiguracionRepository(this._db);

  final AppDatabase _db;

  static const String claveMonedaBase = 'moneda_base';

  Stream<String> watchMonedaBase() {
    return (_db.select(_db.configuracion)
          ..where((t) => t.clave.equals(claveMonedaBase)))
        .watchSingleOrNull()
        .map(
          (ConfiguracionRow? fila) =>
              fila?.valor ?? monedaBasePorDefecto,
        );
  }

  Future<String> obtenerMonedaBase() async {
    final ConfiguracionRow? fila = await (_db.select(_db.configuracion)
          ..where((t) => t.clave.equals(claveMonedaBase)))
        .getSingleOrNull();
    return fila?.valor ?? monedaBasePorDefecto;
  }

  Future<void> guardarMonedaBase(String codigo) {
    return _db.into(_db.configuracion).insertOnConflictUpdate(
          ConfiguracionCompanion.insert(
            clave: claveMonedaBase,
            valor: codigo,
            actualizadoEn: ahoraMs(),
          ),
        );
  }

  Future<void> guardarValor(String clave, String valor) {
    return _db.into(_db.configuracion).insertOnConflictUpdate(
          ConfiguracionCompanion.insert(
            clave: clave,
            valor: valor,
            actualizadoEn: ahoraMs(),
          ),
        );
  }

  Future<String?> obtenerValor(String clave) async {
    final ConfiguracionRow? fila = await (_db.select(_db.configuracion)
          ..where((t) => t.clave.equals(clave)))
        .getSingleOrNull();
    return fila?.valor;
  }
}
