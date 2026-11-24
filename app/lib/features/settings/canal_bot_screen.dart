import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/providers.dart';
import '../shared/vistas.dart';

/// Ajustes del canal bot: token, puerto, MOCK_BOT y estado del servidor.
class CanalBotScreen extends ConsumerStatefulWidget {
  const CanalBotScreen({super.key});

  @override
  ConsumerState<CanalBotScreen> createState() => _CanalBotScreenState();
}

class _CanalBotScreenState extends ConsumerState<CanalBotScreen> {
  final TextEditingController _puertoCtrl = TextEditingController();
  bool _inicializado = false;

  @override
  void dispose() {
    _puertoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokenAsync = ref.watch(tokenBotProvider);
    final puertoAsync = ref.watch(puertoBotProvider);
    final mockAsync = ref.watch(modoMockProvider);

    if (!_inicializado && puertoAsync.hasValue) {
      _puertoCtrl.text = '${puertoAsync.value}';
      _inicializado = true;
    }
    if (tokenAsync.hasError || puertoAsync.hasError || mockAsync.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Canal bot')),
        body: VistaError(
          error: tokenAsync.error ?? puertoAsync.error ?? mockAsync.error!,
          onReintentar: () {
            ref.invalidate(tokenBotProvider);
            ref.invalidate(puertoBotProvider);
            ref.invalidate(modoMockProvider);
          },
        ),
      );
    }
    if (!tokenAsync.hasValue || !puertoAsync.hasValue || !mockAsync.hasValue) {
      return Scaffold(
        appBar: AppBar(title: const Text('Canal bot')),
        body: const VistaCargando(),
      );
    }

    final servidor = ref.watch(servidorCapturasProvider);
    final bool mock = mockAsync.value!;
    final String token = tokenAsync.value!;
    final int puerto = puertoAsync.value!;

    return Scaffold(
      appBar: AppBar(title: const Text('Canal bot')),
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
                    'Estado del servidor',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Icon(
                        servidor.activo ? Icons.check_circle : Icons.error,
                        color: servidor.activo ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          servidor.activo
                              ? 'Escuchando en 127.0.0.1:${servidor.puerto}'
                              : (servidor.ultimoError ??
                                  'Servidor detenido (no hay errores).'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _puertoCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Puerto',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () => _guardarPuerto(puerto),
                        child: const Text('Guardar y reiniciar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Solo escucha en 127.0.0.1 (loopback). Sin servicio en '
                    'primer plano: si cierras la app, el servidor se apaga.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Token del bot',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    token,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: <Widget>[
                      OutlinedButton.icon(
                        onPressed: () => _copiar(token),
                        icon: const Icon(Icons.copy),
                        label: const Text('Copiar'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _regenerar,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Regenerar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  value: mock,
                  onChanged: (bool activo) async {
                    await ref
                        .read(configuracionRepoProvider)
                        .guardarModoMock(activo);
                  },
                  title: const Text('MOCK_BOT (simulador de bot)'),
                  subtitle: const Text(
                    'Permite probar el canal desde el emulador sin WhatsApp.',
                  ),
                ),
                if (mock)
                  ListTile(
                    leading: const Icon(Icons.smart_toy_outlined),
                    title: const Text('Abrir simulador de bot'),
                    subtitle: const Text(
                      'Envía texto, imagen o audio al servidor real.',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/ajustes/simulador'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copiar(String token) async {
    await Clipboard.setData(ClipboardData(text: token));
    if (mounted) {
      mostrarAviso(context, 'Token copiado.');
    }
  }

  Future<void> _regenerar() async {
    final bool confirma = await confirmarAccion(
      context,
      titulo: 'Regenerar token',
      mensaje: 'El bot que ya tengas configurado dejará de funcionar hasta '
          'que copies el token nuevo.',
      textoConfirmar: 'Regenerar',
      destructivo: true,
    );
    if (!confirma) {
      return;
    }
    await ref.read(configuracionRepoProvider).regenerarToken();
    if (mounted) {
      mostrarAviso(context, 'Token regenerado.');
    }
  }

  Future<void> _guardarPuerto(int anterior) async {
    final int? nuevo = int.tryParse(_puertoCtrl.text.trim());
    if (nuevo == null || nuevo < 1024 || nuevo > 65535) {
      mostrarAviso(context, 'Escribe un puerto entre 1024 y 65535.');
      return;
    }
    await ref.read(configuracionRepoProvider).guardarPuerto(nuevo);
    final servidor = ref.read(servidorCapturasProvider);
    try {
      await servidor.reiniciar();
      if (mounted) {
        mostrarAviso(
          context,
          servidor.activo
              ? 'Servidor escuchando en 127.0.0.1:${servidor.puerto}.'
              : (servidor.ultimoError ?? 'No se pudo iniciar el servidor.'),
        );
        setState(() {});
      }
    } on Object {
      if (mounted) {
        mostrarAviso(
          context,
          servidor.ultimoError ?? 'No se pudo reiniciar en el puerto $nuevo.',
        );
        setState(() {});
      }
    }
    if (anterior != nuevo && mounted) {
      setState(() {});
    }
  }
}
