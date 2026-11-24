import 'package:go_router/go_router.dart';

import '../../features/accounts/cuenta_form_screen.dart';
import '../../features/accounts/cuentas_list_screen.dart';
import '../../features/bandeja/bandeja_screen.dart';
import '../../features/bandeja/revision_captura_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/settings/ajustes_screen.dart';
import '../../features/settings/canal_bot_screen.dart';
import '../../features/settings/capturas_screen.dart';
import '../../features/settings/categorias_screen.dart';
import '../../features/settings/etiquetas_screen.dart';
import '../../features/settings/monedas_screen.dart';
import '../../features/settings/simulador_screen.dart';
import '../../features/transactions/transaccion_form_screen.dart';
import '../../features/transactions/transacciones_list_screen.dart';

/// Rutas de la aplicación (Fase 1).
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/cuentas',
      name: 'cuentas',
      builder: (context, state) => const CuentasListScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: 'nueva',
          name: 'cuenta-nueva',
          builder: (context, state) => const CuentaFormScreen(),
        ),
        GoRoute(
          path: ':id/editar',
          name: 'cuenta-editar',
          builder: (context, state) => CuentaFormScreen(
            cuentaId: int.tryParse(state.pathParameters['id'] ?? ''),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/transacciones',
      name: 'transacciones',
      builder: (context, state) => const TransaccionesListScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: 'nueva',
          name: 'transaccion-nueva',
          builder: (context, state) => const TransaccionFormScreen(),
        ),
        GoRoute(
          path: ':id/editar',
          name: 'transaccion-editar',
          builder: (context, state) => TransaccionFormScreen(
            transaccionId: int.tryParse(state.pathParameters['id'] ?? ''),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/bandeja',
      name: 'bandeja',
      builder: (context, state) => const BandejaScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: ':id',
          name: 'bandeja-revision',
          builder: (context, state) => RevisionCapturaScreen(
            capturaId: int.tryParse(state.pathParameters['id'] ?? ''),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/ajustes',
      name: 'ajustes',
      builder: (context, state) => const AjustesScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: 'categorias',
          name: 'ajustes-categorias',
          builder: (context, state) => const CategoriasScreen(),
        ),
        GoRoute(
          path: 'etiquetas',
          name: 'ajustes-etiquetas',
          builder: (context, state) => const EtiquetasScreen(),
        ),
        GoRoute(
          path: 'monedas',
          name: 'ajustes-monedas',
          builder: (context, state) => const MonedasScreen(),
        ),
        GoRoute(
          path: 'canal-bot',
          name: 'ajustes-canal-bot',
          builder: (context, state) => const CanalBotScreen(),
        ),
        GoRoute(
          path: 'capturas',
          name: 'ajustes-capturas',
          builder: (context, state) => const CapturasScreen(),
        ),
        GoRoute(
          path: 'simulador',
          name: 'ajustes-simulador',
          builder: (context, state) => const SimuladorScreen(),
        ),
      ],
    ),
  ],
);
