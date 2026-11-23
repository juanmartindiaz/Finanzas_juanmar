import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/welcome/welcome_screen.dart';

/// Configuración de rutas de la aplicación.
///
/// Fase 0: una única ruta de bienvenida. A partir de la Fase 1 se añadirán las
/// rutas de cuentas, transacciones, presupuestos, deudas, metas, reportes,
/// captura y ajustes.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'bienvenida',
      builder: (BuildContext context, GoRouterState state) =>
          const WelcomeScreen(),
    ),
  ],
);
