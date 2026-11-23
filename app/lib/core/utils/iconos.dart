import 'package:material_ui/material_ui.dart';

/// Catálogo pequeño de iconos para categorías (se guarda el nombre en la base).
const Map<String, IconData> catalogoIconos = <String, IconData>{
  'restaurant': Icons.restaurant,
  'directions_bus': Icons.directions_bus,
  'home': Icons.home,
  'local_hospital': Icons.local_hospital,
  'school': Icons.school,
  'movie': Icons.movie,
  'checkroom': Icons.checkroom,
  'shopping_bag': Icons.shopping_bag,
  'pets': Icons.pets,
  'category': Icons.category,
  'payments': Icons.payments,
  'work': Icons.work,
  'store': Icons.store,
  'card_giftcard': Icons.card_giftcard,
  'trending_up': Icons.trending_up,
  'savings': Icons.savings,
  'flight': Icons.flight,
  'sports_esports': Icons.sports_esports,
};

/// Icono por defecto cuando la categoría no tiene uno.
IconData iconoPorNombre(String? nombre) =>
    catalogoIconos[nombre] ?? Icons.category;

/// Paleta de colores para categorías y etiquetas (se guarda `#RRGGBB`).
const List<String> paletaColores = <String>[
  '#E53935',
  '#FB8C00',
  '#FDD835',
  '#43A047',
  '#00897B',
  '#1E88E5',
  '#3949AB',
  '#8E24AA',
  '#F4511E',
  '#6D4C41',
  '#546E7A',
  '#D81B60',
];

/// Convierte `#RRGGBB` a [Color] (con valor por defecto).
Color colorPorHex(String? hex, {Color porDefecto = const Color(0xFF546E7A)}) {
  if (hex == null) {
    return porDefecto;
  }
  final String limpio = hex.replaceAll('#', '');
  if (limpio.length != 6) {
    return porDefecto;
  }
  final int? valor = int.tryParse(limpio, radix: 16);
  if (valor == null) {
    return porDefecto;
  }
  return Color(0xFF000000 | valor);
}

/// Color sugerido para una categoría nueva.
String colorSugerido(int indice) => paletaColores[indice % paletaColores.length];
