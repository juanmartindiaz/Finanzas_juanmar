/// Subcategorías (hijas de una categoría).
library;

/// Subcategoría de una categoría.
class Subcategoria {
  const Subcategoria({
    required this.id,
    required this.categoriaId,
    required this.nombre,
    required this.predefinida,
    required this.archivada,
  });

  final int id;
  final int categoriaId;
  final String nombre;
  final bool predefinida;
  final bool archivada;

  Subcategoria copyWith({String? nombre, bool? archivada}) {
    return Subcategoria(
      id: id,
      categoriaId: categoriaId,
      nombre: nombre ?? this.nombre,
      predefinida: predefinida,
      archivada: archivada ?? this.archivada,
    );
  }
}
