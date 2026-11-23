/// Utilidades de fechas.
///
/// Convención del modelo: la fecha de calendario se guarda como texto
/// `YYYY-MM-DD` y los instantes como epoch en milisegundos.
library;

String _dosDigitos(int valor) => valor.toString().padLeft(2, '0');

/// Fecha de calendario en formato `YYYY-MM-DD`.
String fechaIso(DateTime fecha) =>
    '${fecha.year}-${_dosDigitos(fecha.month)}-${_dosDigitos(fecha.day)}';

/// Convierte `YYYY-MM-DD` a un [DateTime] local a medianoche.
DateTime parseFechaIso(String texto) {
  final List<int> partes = texto.split('-').map(int.parse).toList();
  return DateTime(partes[0], partes[1], partes[2]);
}

/// Fecha legible `dd/MM/yyyy`.
String fechaTexto(DateTime fecha) =>
    '${_dosDigitos(fecha.day)}/${_dosDigitos(fecha.month)}/${fecha.year}';

/// Fecha y hora legible `dd/MM/yyyy HH:mm`.
String fechaHoraTexto(DateTime fecha) =>
    '${fechaTexto(fecha)} ${_dosDigitos(fecha.hour)}:${_dosDigitos(fecha.minute)}';

/// Epoch en milisegundos del momento actual.
int ahoraMs() => DateTime.now().millisecondsSinceEpoch;

/// Convierte una fecha de calendario a epoch ms (medianoche local).
int fechaIsoAMs(String texto) => parseFechaIso(texto).millisecondsSinceEpoch;
