import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Nombre lógico de la base (sin extensión), como lo usa drift_flutter.
const String nombreBaseDatos = 'gestor_finanzas';

/// Nombre del archivo SQLite que usa drift_flutter: `$name.sqlite`.
const String archivoBaseDatos = '$nombreBaseDatos.sqlite';

/// Ruta única de la base de datos.
///
/// drift_flutter usa por defecto `getApplicationDocumentsDirectory()/$name.sqlite`;
/// aquí se fija explícitamente con [DriftNativeOptions.databasePath] para que la
/// apertura y el respaldo usen **exactamente** el mismo archivo.
class RutasBaseDatos {
  /// Permite a las pruebas usar una carpeta temporal.
  static Future<Directory> Function()? directorioOverride;

  static Future<Directory> directorio() async {
    final Future<Directory> Function()? override = directorioOverride;
    if (override != null) {
      return override();
    }
    return getApplicationDocumentsDirectory();
  }

  /// Ruta absoluta del archivo SQLite.
  static Future<String> ruta() async {
    final Directory dir = await directorio();
    return p.join(dir.path, archivoBaseDatos);
  }

  /// Ruta absoluta de la copia previa a migrar.
  static Future<String> rutaRespaldo() async => '${await ruta()}.backup';

  /// Copia la base a `.backup` antes de abrirla. Devuelve `false` si la base
  /// todavía no existe (primer arranque).
  static Future<bool> copiarAResplado() async {
    final File origen = File(await ruta());
    if (!await origen.exists()) {
      return false;
    }
    await origen.copy(await rutaRespaldo());
    return true;
  }

  /// Restaura `.backup` sobre la base. Devuelve `false` si no hay copia.
  static Future<bool> restaurarDesdeRespaldo() async {
    final File respaldo = File(await rutaRespaldo());
    if (!await respaldo.exists()) {
      return false;
    }
    await respaldo.copy(await ruta());
    return true;
  }

  /// Borra ambas rutas (solo para pruebas).
  static Future<void> borrar() async {
    for (final File archivo in <File>[
      File(await ruta()),
      File(await rutaRespaldo()),
    ]) {
      if (await archivo.exists()) {
        await archivo.delete();
      }
    }
  }
}
