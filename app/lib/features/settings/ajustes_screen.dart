import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/config/app_config.dart';

/// Índice de ajustes de la Fase 1.
class AjustesScreen extends ConsumerWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.currency_exchange),
                  title: const Text('Moneda base y tasas de cambio'),
                  subtitle: const Text(
                    'COP por defecto; tasas manuales para otras monedas.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/ajustes/monedas'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('Categorías y subcategorías'),
                  subtitle: const Text(
                    'Edita, archiva o borra las categorías sembradas.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/ajustes/categorias'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: const Text('Etiquetas'),
                  subtitle: const Text(
                    'Clasificación libre de movimientos.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/ajustes/etiquetas'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Cuentas'),
                  subtitle: const Text(
                    'Crear, editar, activar o borrar cuentas.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/cuentas'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.inbox_outlined),
                  title: const Text('Bandeja de capturas'),
                  subtitle: const Text(
                    'Lo que llega del bot o del simulador, antes de confirmar.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/bandeja'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.hub_outlined),
                  title: const Text('Canal bot'),
                  subtitle: const Text(
                    'Token, puerto y MOCK_BOT.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/ajustes/canal-bot'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Capturas'),
                  subtitle: const Text('Cuenta por defecto para las capturas.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/ajustes/capturas'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.smart_toy_outlined),
                  title: const Text('Avanzado: simulador de bot'),
                  subtitle: const Text(
                    'Envía texto, imagen o audio al servidor local.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/ajustes/simulador'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text('${AppConfig.appName} ${AppConfig.appVersion}'),
              subtitle: Text(
                '${AppConfig.fase} · ${AppConfig.packageName}\n'
                'Funciona sin internet. Los datos son locales.',
              ),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'En la Fase 2 llegarán el OCR, el audio y el bot de WhatsApp.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
