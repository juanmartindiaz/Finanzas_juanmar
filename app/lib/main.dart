import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'data/database/sembrador.dart';
import 'data/providers.dart';

/// Punto de entrada de la aplicación (Fase 1: MVP local).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppDatabase db = AppDatabase();
  await SembradorCategorias(db).ejecutarSiHaceFalta();

  runApp(
    ProviderScope(
      overrides: [
        dbProvider.overrideWith((Ref ref) => db),
      ],
      child: const GestorFinanzasApp(),
    ),
  );
}

/// Aplicación "Gestor Finanzas".
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
      locale: const Locale('es', 'CO'),
      supportedLocales: const <Locale>[Locale('es', 'CO'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: appRouter,
    );
  }
}
