/// Configuración básica de la aplicación.
///
/// Solo constantes de identificación del proyecto. Los valores que se puedan
/// configurar por el usuario (moneda base, modo mock del bot, etc.) vivirán en
/// la tabla `configuracion` de la base de datos a partir de la Fase 1.
abstract final class AppConfig {
  /// Nombre visible de la aplicación.
  static const String appName = 'Gestor Finanzas';

  /// Versión de la aplicación (Fase 0).
  static const String appVersion = '0.1.0';

  /// Fase de desarrollo actual.
  static const String fase = 'Fase 0';

  /// Identificador del paquete Android.
  static const String packageName = 'com.juanmartin.gestor_finanzas';
}
