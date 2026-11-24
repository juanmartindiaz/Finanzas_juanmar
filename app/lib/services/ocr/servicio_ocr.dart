import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Abstracción para poder probar el servidor sin ML Kit.
abstract class ServicioOcr {
  Future<String> reconocerTexto(String rutaAbsoluta);
}

/// OCR offline con ML Kit (modelo latino incluido en el APK).
class ServicioOcrMlKit implements ServicioOcr {
  final TextRecognizer _reconocedor = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  @override
  Future<String> reconocerTexto(String rutaAbsoluta) async {
    final InputImage imagen = InputImage.fromFilePath(rutaAbsoluta);
    final RecognizedText resultado = await _reconocedor.processImage(imagen);
    return resultado.text;
  }

  Future<void> cerrar() async {
    await _reconocedor.close();
  }
}
