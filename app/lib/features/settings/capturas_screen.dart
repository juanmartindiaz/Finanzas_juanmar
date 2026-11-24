import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/providers.dart';
import '../../domain/entities/cuenta.dart';
import '../shared/vistas.dart';

/// Ajustes de capturas: cuenta por defecto para las propuestas.
class CapturasScreen extends ConsumerWidget {
  const CapturasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuentasAsync = ref.watch(cuentasProvider);
    final cuentaAsync = ref.watch(capturaCuentaIdProvider);

    if (cuentasAsync.hasError || cuentaAsync.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Capturas')),
        body: VistaError(
          error: cuentasAsync.error ?? cuentaAsync.error!,
          onReintentar: () {
            ref.invalidate(cuentasProvider);
            ref.invalidate(capturaCuentaIdProvider);
          },
        ),
      );
    }
    if (!cuentasAsync.hasValue || !cuentaAsync.hasValue) {
      return Scaffold(
        appBar: AppBar(title: const Text('Capturas')),
        body: const VistaCargando(),
      );
    }

    final List<Cuenta> cuentas = cuentasAsync.value!
        .where((Cuenta cuenta) => cuenta.activa)
        .toList();
    final int? seleccionada = cuentaAsync.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Capturas')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Cuenta por defecto',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'El parser la propone cuando no puede identificar la '
                    'cuenta en el texto. Siempre se puede cambiar al revisar.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        isExpanded: true,
                        value: seleccionada,
                        items: <DropdownMenuItem<int?>>[
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Ninguna (elegir al revisar)'),
                          ),
                          for (final Cuenta cuenta in cuentas)
                            DropdownMenuItem<int?>(
                              value: cuenta.id,
                              child: Text('${cuenta.nombre} (${cuenta.moneda})'),
                            ),
                        ],
                        onChanged: (int? valor) async {
                          await ref
                              .read(configuracionRepoProvider)
                              .guardarCapturaCuentaId(valor);
                          if (context.mounted) {
                            mostrarAviso(context, 'Cuenta por defecto guardada.');
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Las fotos y los audios se guardan en la carpeta privada de la '
              'app. En esta parte todavía no hay OCR ni transcripción: se '
              'revisan a mano.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
