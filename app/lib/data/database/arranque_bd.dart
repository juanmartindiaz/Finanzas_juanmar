import 'app_database.dart';
import 'rutas_base_datos.dart';

/// Error de arranque que se puede mostrar al usuario.
class ErrorArranqueBase implements Exception {
  const ErrorArranqueBase(this.mensaje, {this.detalle});

  final String mensaje;
  final Object? detalle;

  @override
  String toString() => detalle == null ? mensaje : '$mensaje ($detalle)';
}

/// Copia la base a `.backup`, abre la base y fuerza la migración pendiente.
///
/// Si algo falla, restaura la copia y lanza [ErrorArranqueBase]. Así una
/// migración rota nunca deja la base a medias (DATA_MODEL.md §8.1).
Future<AppDatabase> abrirBaseDeDatosConRespaldo() async {
  await RutasBaseDatos.copiarAResplado();
  AppDatabase? db;
  try {
    db = AppDatabase();
    // Fuerza la apertura real y, con ella, la migración.
    await db.customSelect('SELECT 1').getSingle();
    return db;
  } on Object catch (error) {
    await db?.close();
    final bool restaurada = await RutasBaseDatos.restaurarDesdeRespaldo();
    throw ErrorArranqueBase(
      restaurada
          ? 'La base no se pudo abrir; se restauró la copia de seguridad.'
          : 'La base no se pudo abrir y no había copia de seguridad.',
      detalle: error,
    );
  }
}
