import 'dart:io';

import 'package:path/path.dart' as p;

import '../../data/database/rutas_base_datos.dart';

/// Guarda y resuelve los adjuntos de las capturas dentro de la carpeta privada
/// `capturas/` (ADR-033). La base solo guarda la ruta relativa.
class AlmacenAdjuntos {
  Future<Directory> _carpeta() async {
    final Directory base = await RutasBaseDatos.directorio();
    final Directory carpeta = Directory(p.join(base.path, 'capturas'));
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }
    return carpeta;
  }

  /// Guarda el archivo y devuelve la ruta relativa (`capturas/...`).
  Future<String> guardar(
    List<int> bytes, {
    required String messageId,
    required String extension,
  }) async {
    final Directory carpeta = await _carpeta();
    final String seguro = messageId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final String nombre =
        '${seguro}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final File archivo = File(p.join(carpeta.path, nombre));
    await archivo.writeAsBytes(bytes, flush: true);
    return p.join('capturas', nombre);
  }

  Future<File> resolver(String rutaRelativa) async {
    final Directory base = await RutasBaseDatos.directorio();
    return File(p.join(base.path, rutaRelativa));
  }

  Future<bool> existe(String rutaRelativa) async {
    return (await resolver(rutaRelativa)).exists();
  }

  Future<void> borrar(String rutaRelativa) async {
    final File archivo = await resolver(rutaRelativa);
    if (await archivo.exists()) {
      await archivo.delete();
    }
  }

  String extensionDesdeMime(String? mime, String? nombreArchivo) {
    const Map<String, String> porMime = <String, String>{
      'image/jpeg': 'jpg',
      'image/jpg': 'jpg',
      'image/png': 'png',
      'image/webp': 'webp',
      'audio/ogg': 'ogg',
      'audio/opus': 'opus',
      'audio/mpeg': 'mp3',
      'audio/mp4': 'm4a',
      'audio/amr': 'amr',
    };
    if (mime != null && porMime.containsKey(mime)) {
      return porMime[mime]!;
    }
    if (nombreArchivo != null && nombreArchivo.contains('.')) {
      return nombreArchivo.split('.').last.toLowerCase();
    }
    return 'bin';
  }
}
