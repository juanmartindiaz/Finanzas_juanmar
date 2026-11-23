/// Categorías de gasto o ingreso.
library;

/// Naturaleza de una categoría (quién la puede usar).
enum NaturalezaCategoria {
  ingreso('ingreso', 'Ingreso'),
  gasto('gasto', 'Gasto'),
  ambos('ambos', 'Ingreso y gasto');

  const NaturalezaCategoria(this.valorDb, this.etiqueta);

  final String valorDb;
  final String etiqueta;

  static NaturalezaCategoria desdeDb(String valor) => values.firstWhere(
    (NaturalezaCategoria naturaleza) => naturaleza.valorDb == valor,
    orElse: () => NaturalezaCategoria.gasto,
  );
}

/// Categoría (por ejemplo Alimentación o Salario).
class Categoria {
  const Categoria({
    required this.id,
    required this.nombre,
    required this.naturaleza,
    required this.predefinida,
    required this.orden,
    required this.archivada,
    this.icono,
    this.color,
  });

  final int id;
  final String nombre;
  final NaturalezaCategoria naturaleza;
  final String? icono;
  final String? color;
  final bool predefinida;
  final int orden;
  final bool archivada;

  Categoria copyWith({
    String? nombre,
    NaturalezaCategoria? naturaleza,
    String? icono,
    String? color,
    bool? archivada,
  }) {
    return Categoria(
      id: id,
      nombre: nombre ?? this.nombre,
      naturaleza: naturaleza ?? this.naturaleza,
      icono: icono ?? this.icono,
      color: color ?? this.color,
      predefinida: predefinida,
      orden: orden,
      archivada: archivada ?? this.archivada,
    );
  }
}
