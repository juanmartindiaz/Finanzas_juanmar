import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/fechas.dart';
import '../../data/providers.dart';
import '../../domain/entities/captura.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/cuenta.dart';
import '../../domain/entities/etiqueta.dart';
import '../../domain/entities/subcategoria.dart';
import '../../domain/parsers/parser_texto.dart';
import '../shared/vistas.dart';

/// Bandeja de capturas: lo que llegó del bot/simulador o se capturó a mano.
class BandejaScreen extends ConsumerWidget {
  const BandejaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturasAsync = ref.watch(capturasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bandeja de capturas'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Capturar texto',
            icon: const Icon(Icons.note_add_outlined),
            onPressed: () => _capturarTexto(context, ref),
          ),
        ],
      ),
      body: capturasAsync.hasError
          ? VistaError(
              error: capturasAsync.error!,
              onReintentar: () => ref.invalidate(capturasProvider),
            )
          : !capturasAsync.hasValue
              ? const VistaCargando()
              : _Contenido(capturas: capturasAsync.value!),
    );
  }

  Future<void> _capturarTexto(BuildContext context, WidgetRef ref) async {
    final String? texto = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => const _DialogoCapturaTexto(),
    );
    if (texto == null || texto.trim().isEmpty) {
      return;
    }
    final List<Categoria> categorias =
        ref.read(categoriasProvider).value ?? <Categoria>[];
    final List<Subcategoria> subcategorias =
        ref.read(subcategoriasProvider).value ?? <Subcategoria>[];
    final List<Etiqueta> etiquetas =
        ref.read(etiquetasProvider).value ?? <Etiqueta>[];
    final List<Cuenta> cuentas =
        ref.read(cuentasProvider).value ?? <Cuenta>[];
    final String monedaBase =
        ref.read(monedaBaseProvider).value ?? 'COP';
    final int? cuentaPorDefecto =
        ref.read(capturaCuentaIdProvider).value;

    final PropuestaCaptura propuesta = parsearTexto(
      texto,
      ContextoParser(
        categorias: categorias,
        subcategorias: subcategorias,
        etiquetas: etiquetas,
        cuentas: cuentas,
        monedaBase: monedaBase,
        cuentaPorDefectoId: cuentaPorDefecto,
      ),
    );
    final int id = await ref
        .read(capturasRepoProvider)
        .crearManualTexto(texto: texto.trim(), propuesta: propuesta);
    if (context.mounted) {
      context.push('/bandeja/$id');
    }
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.capturas});

  final List<CapturaEntrante> capturas;

  @override
  Widget build(BuildContext context) {
    final List<CapturaEntrante> abiertas =
        capturas.where((CapturaEntrante captura) => captura.estaAbierta).toList();
    final List<CapturaEntrante> historial =
        capturas.where((CapturaEntrante captura) => !captura.estaAbierta).toList();

    if (capturas.isEmpty) {
      return const VistaVacia(
        icono: Icons.inbox_outlined,
        mensaje: 'La bandeja está vacía',
        detalle: 'Las capturas que lleguen por el bot o por el simulador '
            'aparecerán aquí antes de convertirse en transacciones.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: <Widget>[
        if (abiertas.isNotEmpty) ...<Widget>[
          _Encabezado(
            titulo: 'Por revisar (${abiertas.length})',
            detalle: 'Nada se guarda hasta que confirmes.',
          ),
          for (final CapturaEntrante captura in abiertas)
            _ItemCaptura(captura: captura),
          const SizedBox(height: 16),
        ],
        if (historial.isNotEmpty) ...<Widget>[
          const _Encabezado(
            titulo: 'Historial',
            detalle: 'Confirmadas o descartadas.',
          ),
          for (final CapturaEntrante captura in historial)
            _ItemCaptura(captura: captura),
        ],
      ],
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.titulo, required this.detalle});

  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(titulo, style: Theme.of(context).textTheme.titleMedium),
          Text(detalle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ItemCaptura extends StatelessWidget {
  const _ItemCaptura({required this.captura});

  final CapturaEntrante captura;

  @override
  Widget build(BuildContext context) {
    final IconData icono = switch (captura.canal) {
      CanalCaptura.texto => Icons.chat_outlined,
      CanalCaptura.audio => Icons.mic_none,
      CanalCaptura.foto => Icons.image_outlined,
      CanalCaptura.app => Icons.edit_note,
    };
    final bool requiereRevision = captura.estado == EstadoCaptura.listo &&
        (captura.propuesta?.confianza == ConfianzaPropuesta.baja ||
            (captura.propuesta?.faltantes.isNotEmpty ?? false));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icono)),
        title: Text(
          captura.resumen,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 2),
            Text(
              '${captura.canal.etiqueta} · ${captura.origen.etiqueta} · '
              '${fechaHoraTexto(DateTime.fromMillisecondsSinceEpoch(captura.createdAt))}',
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: <Widget>[
                Chip(
                  label: Text(captura.estado.etiqueta),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                if (requiereRevision)
                  const Chip(
                    label: Text('requiere revisión'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                if (captura.propuesta?.faltantes.isNotEmpty ?? false)
                  Chip(
                    label: Text(
                      'falta: ${captura.propuesta!.faltantes.join(', ')}',
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/bandeja/${captura.id}'),
      ),
    );
  }
}

class _DialogoCapturaTexto extends StatefulWidget {
  const _DialogoCapturaTexto();

  @override
  State<_DialogoCapturaTexto> createState() => _DialogoCapturaTextoState();
}

class _DialogoCapturaTextoState extends State<_DialogoCapturaTexto> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Capturar texto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Prueba el pipeline sin bot. El parser propondrá monto y '
            'categoría; tú revisas antes de guardar.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Mensaje',
              hintText: 'Ej.: gasté 18.500 en mercado',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (String valor) => Navigator.of(context).pop(valor),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_ctrl.text.trim()),
          child: const Text('Procesar'),
        ),
      ],
    );
  }
}
