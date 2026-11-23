import 'package:material_ui/material_ui.dart';

import '../../core/config/app_config.dart';

/// Pantalla de bienvenida de la Fase 0.
///
/// No contiene funcionalidad de finanzas: solo confirma que el esqueleto
/// compila, que `go_router` está configurado y que la app arranca en el
/// emulador.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 96,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  '${AppConfig.appName} — ${AppConfig.fase}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Esqueleto técnico listo. La captura de gastos, los '
                  'presupuestos y los reportes llegan en las siguientes fases.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                Text(
                  'versión ${AppConfig.appVersion}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
