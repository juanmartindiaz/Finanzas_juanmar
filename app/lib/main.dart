import 'package:material_ui/material_ui.dart';

import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Punto de entrada de la aplicación.
void main() {
  runApp(const GestorFinanzasApp());
}

/// Aplicación "Gestor Finanzas".
///
/// Fase 0: solo esqueleto técnico. La pantalla de bienvenida se muestra desde
/// [appRouter] y todavía no existe ninguna lógica de finanzas.
class GestorFinanzasApp extends StatelessWidget {
  const GestorFinanzasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
