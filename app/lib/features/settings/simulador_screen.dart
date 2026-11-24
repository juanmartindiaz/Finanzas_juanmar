import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/providers.dart';
import '../../services/whatsapp_bridge/cliente_simulador.dart';
import '../shared/vistas.dart';

/// Simulador de bot: hace peticiones HTTP reales al servidor local con el
/// token, como lo haría el bot (ADR-032).
class SimuladorScreen extends ConsumerStatefulWidget {
  const SimuladorScreen({super.key});

  @override
  ConsumerState<SimuladorScreen> createState() => _SimuladorScreenState();
}

class _SimuladorScreenState extends ConsumerState<SimuladorScreen> {
  final TextEditingController _textoCtrl = TextEditingController();
  bool _enviando = false;
  String? _resultado;

  @override
  void dispose() {
    _textoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servidor = ref.watch(servidorCapturasProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de bot')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          Card(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Icon(Icons.smart_toy_outlined),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bot simulado — usa el servidor local de la app '
                      '(127.0.0.1). No sale a internet.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (!servidor.activo)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'El servidor no está escuchando: '
                      '${servidor.ultimoError ?? 'sin detalles'}',
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () async {
                        try {
                          await servidor.iniciar();
                        } on Object {
                          // El error queda en ultimoError.
                        }
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Mensaje de texto',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _textoCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Texto',
                      hintText: 'gasté 18.500 en mercado',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _enviando ? null : _enviarTexto,
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar texto por HTTP'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: const Text('Enviar imagen (foto de recibo)'),
                  subtitle: const Text(
                    'Se guarda como captura; sin OCR todavía.',
                  ),
                  onTap: _enviando ? null : () => _enviarArchivo(esAudio: false),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.mic_none),
                  title: const Text('Enviar audio (nota de voz)'),
                  subtitle: const Text(
                    'Se guarda como captura; sin transcripción todavía.',
                  ),
                  onTap: _enviando ? null : () => _enviarArchivo(esAudio: true),
                ),
              ],
            ),
          ),
          if (_resultado != null) ...<Widget>[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_resultado!),
              ),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push('/bandeja'),
            icon: const Icon(Icons.inbox_outlined),
            label: const Text('Ir a la bandeja'),
          ),
        ],
      ),
    );
  }

  Future<void> _enviarTexto() async {
    final String texto = _textoCtrl.text.trim();
    if (texto.isEmpty) {
      mostrarAviso(context, 'Escribe un mensaje.');
      return;
    }
    setState(() {
      _enviando = true;
      _resultado = null;
    });
    try {
      final resultado =
          await ref.read(clienteSimuladorProvider).enviarTexto(texto);
      await _procesarResultado(resultado);
    } on Object catch (error) {
      setState(() => _resultado = 'Error de red: $error');
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  Future<void> _enviarArchivo({required bool esAudio}) async {
    final PlatformFile? seleccion = await FilePicker.pickFile(
      type: esAudio ? FileType.audio : FileType.image,
    );
    final String? ruta = seleccion?.path;
    if (ruta == null || !mounted) {
      return;
    }
    setState(() {
      _enviando = true;
      _resultado = null;
    });
    try {
      final resultado = await ref
          .read(clienteSimuladorProvider)
          .enviarArchivo(File(ruta), esAudio: esAudio);
      await _procesarResultado(resultado);
    } on Object catch (error) {
      setState(() => _resultado = 'Error de red: $error');
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  Future<void> _procesarResultado(ResultadoSimulacion resultado) async {
    if (!mounted) {
      return;
    }
    if (resultado.ok) {
      setState(
        () => _resultado =
            'Captura #${resultado.capturaId} creada (estado: '
            '${resultado.cuerpo['estado']}).',
      );
      mostrarAviso(context, 'Captura creada. Abriendo la bandeja…');
      context.push('/bandeja');
    } else {
      setState(
        () => _resultado = 'El servidor respondió ${resultado.codigo}: '
            '${resultado.error}',
      );
    }
  }
}
