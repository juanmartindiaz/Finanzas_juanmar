import 'package:material_ui/material_ui.dart';

/// Tema visual de la aplicación.
///
/// Fase 0: se usan los valores por defecto de Material 3, sin paleta propia ni
/// personalización. El diseño visual se define en fases posteriores.
abstract final class AppTheme {
  /// Tema claro (valores por defecto de Material 3).
  static ThemeData get light => ThemeData(brightness: Brightness.light);

  /// Tema oscuro (valores por defecto de Material 3).
  static ThemeData get dark => ThemeData(brightness: Brightness.dark);
}
