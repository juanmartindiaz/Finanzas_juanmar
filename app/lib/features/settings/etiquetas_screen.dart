import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/iconos.dart';
import '../../data/providers.dart';
import '../../domain/entities/etiqueta.dart';
import '../shared/vistas.dart';

/// Gestión de etiquetas.
class EtiquetasScreen extends ConsumerWidget {
  const EtiquetasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final etiquetasAsync = ref.watch(etiquetasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Etiquetas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crear(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva etiqueta'),
      ),
      body: etiquetasAsync.hasError
          ? VistaError(
              error: etiquetasAsync.error!,
              onReintentar: () => ref.invalidate(etiquetasProvider),
            )
          : !etiquetasAsync.hasValue
              ? const VistaCargando()
              : _Lista(etiquetas: etiquetasAsync.value!),
    );
  }
}

class _Lista extends ConsumerWidget {
  const _Lista({required this.etiquetas});

  final List<Etiqueta> etiquetas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (etiquetas.isEmpty) {
      return VistaVacia(
        icono: Icons.label_outline,
        mensaje: 'No hay etiquetas',
        detalle: 'Las etiquetas sirven para clasificar movimientos '
            '(por ejemplo: trabajo, viaje).',
        accion: FilledButton.icon(
          onPressed: () => _crear(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Crear etiqueta'),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      itemCount: etiquetas.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int indice) {
        final Etiqueta etiqueta = etiquetas[indice];
        final Color color = colorPorHex(etiqueta.color);
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(Icons.label, color: color, size: 20),
          ),
          title: Text(etiqueta.nombre),
          trailing: PopupMenuButton<String>(
            onSelected: (String opcion) =>
                _accion(context, ref, etiqueta, opcion),
            itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'editar', child: Text('Editar')),
              PopupMenuItem<String>(value: 'borrar', child: Text('Borrar')),
            ],
          ),
        );
      },
    );
  }

  Future<void> _accion(
    BuildContext context,
    WidgetRef ref,
    Etiqueta etiqueta,
    String opcion,
  ) async {
    if (opcion == 'editar') {
      await _editar(context, ref, etiqueta);
      return;
    }
    final bool borrar = await confirmarAccion(
      context,
      titulo: 'Borrar etiqueta',
      mensaje: 'Se quitará de todos los movimientos que la usan, pero los '
          'movimientos se conservan.',
      textoConfirmar: 'Borrar',
      destructivo: true,
    );
    if (!borrar) {
      return;
    }
    await ref.read(etiquetasRepoProvider).eliminar(etiqueta.id);
    if (context.mounted) {
      mostrarAviso(context, 'Etiqueta borrada.');
    }
  }
}

Future<void> _crear(BuildContext context, WidgetRef ref) async {
  final _DatosEtiqueta? datos = await showDialog<_DatosEtiqueta>(
    context: context,
    builder: (BuildContext context) => const _DialogoEtiqueta(),
  );
  if (datos == null) {
    return;
  }
  try {
    await ref.read(etiquetasRepoProvider).crear(
          nombre: datos.nombre,
          color: datos.color,
        );
    if (context.mounted) {
      mostrarAviso(context, 'Etiqueta creada.');
    }
  } on Exception catch (e) {
    if (context.mounted) {
      mostrarAviso(context, 'No se pudo crear: $e');
    }
  }
}

Future<void> _editar(
  BuildContext context,
  WidgetRef ref,
  Etiqueta etiqueta,
) async {
  final _DatosEtiqueta? datos = await showDialog<_DatosEtiqueta>(
    context: context,
    builder: (BuildContext context) => _DialogoEtiqueta(etiqueta: etiqueta),
  );
  if (datos == null) {
    return;
  }
  await ref.read(etiquetasRepoProvider).actualizar(
        id: etiqueta.id,
        nombre: datos.nombre,
        color: datos.color,
      );
  if (context.mounted) {
    mostrarAviso(context, 'Etiqueta actualizada.');
  }
}

class _DatosEtiqueta {
  const _DatosEtiqueta({required this.nombre, this.color});

  final String nombre;
  final String? color;
}

class _DialogoEtiqueta extends StatefulWidget {
  const _DialogoEtiqueta({this.etiqueta});

  final Etiqueta? etiqueta;

  @override
  State<_DialogoEtiqueta> createState() => _DialogoEtiquetaState();
}

class _DialogoEtiquetaState extends State<_DialogoEtiqueta> {
  late final TextEditingController _ctrl;
  String? _color;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.etiqueta?.nombre ?? '');
    _color = widget.etiqueta?.color ?? paletaColores.first;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.etiqueta == null ? 'Nueva etiqueta' : 'Editar etiqueta',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _ctrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final String hex in paletaColores)
                InkWell(
                  onTap: () => setState(() => _color = hex),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colorPorHex(hex),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _color == hex ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final String nombre = _ctrl.text.trim();
            if (nombre.isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              _DatosEtiqueta(nombre: nombre, color: _color),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
