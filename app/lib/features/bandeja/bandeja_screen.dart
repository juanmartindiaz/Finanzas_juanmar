import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/fechas.dart';
import '../../data/providers.dart';
import '../../domain/entities/captura.dart';
import '../shared/vistas.dart';

/// Actividad de WhatsApp: movimientos que el bot ya registró (historial).
class BandejaScreen extends ConsumerWidget {
  const BandejaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturasAsync = ref.watch(capturasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Actividad de WhatsApp')),
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
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.capturas});

  final List<CapturaEntrante> capturas;

  @override
  Widget build(BuildContext context) {
    final List<CapturaEntrante> registros = capturas
        .where(
          (CapturaEntrante captura) =>
              captura.transaccionId != null &&
              captura.origen != OrigenCaptura.manual &&
              captura.estado != EstadoCaptura.descartado,
        )
        .toList()
      ..sort(
        (CapturaEntrante a, CapturaEntrante b) =>
            b.createdAt.compareTo(a.createdAt),
      );

    if (registros.isEmpty) {
      return const VistaVacia(
        icono: Icons.chat_outlined,
        mensaje: 'Aún no hay movimientos de WhatsApp',
        detalle: 'Cuando registres un gasto por el bot, aparecerá aquí para '
            'que lo revises o edites. El dashboard y Transacciones siguen '
            'mostrando todo.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Text(
            'Registros recientes (${registros.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        for (final CapturaEntrante captura in registros)
          _ItemCaptura(captura: captura),
      ],
    );
  }
}

class _ItemCaptura extends ConsumerWidget {
  const _ItemCaptura({required this.captura});

  final CapturaEntrante captura;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final IconData icono = switch (captura.canal) {
      CanalCaptura.texto => Icons.chat_outlined,
      CanalCaptura.audio => Icons.mic_none,
      CanalCaptura.foto => Icons.image_outlined,
      CanalCaptura.app => Icons.edit_note,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final int? transaccionId = captura.transaccionId;
          if (transaccionId != null) {
            context.push('/transacciones/$transaccionId/editar');
          }
        },
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
                '${captura.canal.etiqueta} · '
                '${fechaHoraTexto(DateTime.fromMillisecondsSinceEpoch(captura.createdAt))}',
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: <Widget>[
                  const Chip(
                    label: Text('Registrado'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  if (captura.incompleta)
                    const Chip(
                      label: Text('incompleta'),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  final int? transaccionId = captura.transaccionId;
                  if (transaccionId != null) {
                    context.push('/transacciones/$transaccionId/editar');
                  }
                },
              ),
              IconButton(
                tooltip: 'Deshacer',
                icon: const Icon(Icons.undo),
                onPressed: () => _deshacer(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deshacer(BuildContext context, WidgetRef ref) async {
    final int? transaccionId = captura.transaccionId;
    if (transaccionId == null) return;
    final bool confirma = await confirmarAccion(
      context,
      titulo: 'Deshacer registro',
      mensaje: 'Se borrará la transacción y el saldo de la cuenta volverá '
          'atrás. No se puede deshacer esta acción.',
      textoConfirmar: 'Deshacer',
      destructivo: true,
    );
    if (!confirma || !context.mounted) return;
    await ref.read(transaccionesRepoProvider).eliminarLogico(transaccionId);
    await ref.read(capturasRepoProvider).descartar(captura.id);
    if (context.mounted) {
      mostrarAviso(context, 'Registro deshecho.');
    }
  }
}
