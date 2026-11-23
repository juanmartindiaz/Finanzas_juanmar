/// Etiquetas libres para clasificar transacciones.
library;

/// Etiqueta (por ejemplo "trabajo", "viaje").
class Etiqueta {
  const Etiqueta({
    required this.id,
    required this.nombre,
    this.color,
  });

  final int id;
  final String nombre;
  final String? color;

  Etiqueta copyWith({String? nombre, String? color}) {
    return Etiqueta(id: id, nombre: nombre ?? this.nombre, color: color ?? this.color);
  }
}

/// Referencia mínima a una etiqueta dentro de una transacción.
class EtiquetaRef {
  const EtiquetaRef({required this.id, required this.nombre});

  final int id;
  final String nombre;
}
