import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/dinero.dart';
import '../../data/providers.dart';
import '../../domain/entities/tasa_cambio.dart';
import '../shared/vistas.dart';

/// Moneda base y tasas de cambio manuales.
class MonedasScreen extends ConsumerStatefulWidget {
  const MonedasScreen({super.key});

  @override
  ConsumerState<MonedasScreen> createState() => _MonedasScreenState();
}

class _MonedasScreenState extends ConsumerState<MonedasScreen> {
  final TextEditingController _valorCtrl = TextEditingController();
  String? _origen;

  @override
  void dispose() {
    _valorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseAsync = ref.watch(monedaBaseProvider);
    final tasasAsync = ref.watch(tasasProvider);

    if (baseAsync.hasError || tasasAsync.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Monedas y tasas')),
        body: VistaError(
          error: baseAsync.error ?? tasasAsync.error!,
          onReintentar: () {
            ref.invalidate(monedaBaseProvider);
            ref.invalidate(tasasProvider);
          },
        ),
      );
    }
    if (!baseAsync.hasValue || !tasasAsync.hasValue) {
      return Scaffold(
        appBar: AppBar(title: const Text('Monedas y tasas')),
        body: const VistaCargando(),
      );
    }

    final String base = baseAsync.value!;
    final List<TasaCambio> tasas = tasasAsync.value!;
    final List<String> otras = monedasSoportadas
        .map((Moneda moneda) => moneda.codigo)
        .where((String codigo) => codigo != base)
        .toList();
    final String origen =
        _origen != null && _origen != base ? _origen! : otras.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Monedas y tasas')),
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
                    'Moneda base',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'El dashboard consolida todos los saldos en esta moneda.',
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
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: base,
                        items: <DropdownMenuItem<String>>[
                          for (final Moneda moneda in monedasSoportadas)
                            DropdownMenuItem<String>(
                              value: moneda.codigo,
                              child: Text(
                                '${moneda.codigo} — ${moneda.nombre}',
                              ),
                            ),
                        ],
                        onChanged: (String? valor) async {
                          if (valor == null) {
                            return;
                          }
                          await ref
                              .read(configuracionRepoProvider)
                              .guardarMonedaBase(valor);
                          if (context.mounted) {
                            mostrarAviso(
                              context,
                              'Moneda base: $valor.',
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tasas manuales',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Cada tasa indica cuántas unidades de la moneda base equivalen a '
            '1 unidad de la otra moneda. Se usa la más reciente hasta hoy; si '
            'falta, la cuenta se muestra como "sin convertir".',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          if (tasas.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No hay tasas registradas. Si todas tus cuentas son en '
                  'COP, no necesitas ninguna.',
                ),
              ),
            )
          else
            Card(
              child: Column(
                children: <Widget>[
                  for (final TasaCambio tasa in tasas)
                    ListTile(
                      leading: const Icon(Icons.currency_exchange),
                      title: Text(
                        '1 ${tasa.monedaOrigen} = '
                        '${formatearTasa(tasa.valor)} ${tasa.monedaDestino}',
                      ),
                      subtitle: Text(
                        '${tasa.fecha} · ${tasa.fuente.etiqueta}',
                      ),
                      trailing: IconButton(
                        tooltip: 'Borrar tasa',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final bool borrar = await confirmarAccion(
                            context,
                            titulo: 'Borrar tasa',
                            mensaje: 'Se borrará la tasa de '
                                '${tasa.monedaOrigen} a ${tasa.monedaDestino} '
                                'del ${tasa.fecha}.',
                            textoConfirmar: 'Borrar',
                            destructivo: true,
                          );
                          if (borrar) {
                            await ref
                                .read(tasasRepoProvider)
                                .eliminar(tasa.id);
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Agregar tasa de hoy',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Moneda',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: origen,
                              items: <DropdownMenuItem<String>>[
                                for (final String codigo in otras)
                                  DropdownMenuItem<String>(
                                    value: codigo,
                                    child: Text(codigo),
                                  ),
                              ],
                              onChanged: (String? valor) =>
                                  setState(() => _origen = valor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _valorCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Valor en $base',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () => _guardar(origen, base),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar tasa'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardar(String origen, String base) async {
    final double? valor =
        double.tryParse(_valorCtrl.text.trim().replaceAll(',', '.'));
    if (valor == null || valor <= 0) {
      mostrarAviso(context, 'Escribe un valor mayor que cero.');
      return;
    }
    await ref.read(tasasRepoProvider).guardar(
          monedaOrigen: origen,
          monedaDestino: base,
          valor: valor,
        );
    _valorCtrl.clear();
    if (mounted) {
      mostrarAviso(context, 'Tasa guardada para hoy.');
    }
  }
}
