import 'dart:convert';

/// Compara tokens en tiempo constante para no filtrar información por el
/// tiempo de respuesta (API_CONTRACT.md §3).
bool tokensIguales(String? recibido, String esperado) {
  if (recibido == null || esperado.isEmpty) {
    return false;
  }
  final List<int> a = utf8.encode(recibido);
  final List<int> b = utf8.encode(esperado);
  int diferencia = a.length ^ b.length;
  for (int i = 0; i < b.length; i++) {
    diferencia |= (i < a.length ? a[i] : 0) ^ b[i];
  }
  return diferencia == 0;
}
