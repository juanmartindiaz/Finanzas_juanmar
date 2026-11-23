import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/dinero.dart';
import '../../data/providers.dart';
import '../../domain/entities/cuenta.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/entities/transaccion.dart';
import '../../domain/usecases/saldos.dart';
import '../shared/vistas.dart';

/// Listado de cuentas con su saldo calculado.
class CuentasListScreen extends ConsumerWidget {
  const CuentasListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuentasAsync = ref.watch(cuentasProvider);
    final transaccionesAsync = ref.watch(transaccionesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cuentas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/cuentas/nueva'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva cuenta'),
      ),
      body: cuentasAsync.hasError || transaccionesAsync.hasError
          ? VistaError(
              error: cuentasAsync.error ?? transaccionesAsync.error!,
              onReintentar: () {
                ref.invalidate(cuentasProvider);
                ref.invalidate(transaccionesProvider);
              },
            )
          : !cuentasAsync.hasValue || !transaccionesAsync.hasValue
              ? const VistaCargando()
              : _Lista(
                  cuentas: cuentasAsync.value!,
                  transacciones: transaccionesAsync.value!,
                ),
    );
  }
}

class _Lista extends ConsumerWidget {
  const _Lista({required this.cuentas, required this.transacciones});

  final List<Cuenta> cuentas;
  final List<Transaccion> transacciones;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<SaldoCuenta> saldos = calcularSaldos(
      cuentas,
      transacciones,
    );

    if (saldos.isEmpty) {
      return VistaVacia(
        icono: Icons.account_balance_wallet_outlined,
        mensaje: 'No tienes cuentas todavía',
        detalle: 'Crea una cuenta (efectivo, banco, Nequi…) para registrar '
            'tus movimientos.',
        accion: FilledButton.icon(
          onPressed: () => context.push('/cuentas/nueva'),
          icon: const Icon(Icons.add),
          label: const Text('Crear cuenta'),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      itemCount: saldos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int indice) {
        final SaldoCuenta saldo = saldos[indice];
        final Cuenta cuenta = saldo.cuenta;
        return Card(
          child: ListTile(
            onTap: () => context.push('/cuentas/${cuenta.id}/editar'),
            leading: Icon(_icono(cuenta.tipo)),
            title: Row(
              children: <Widget>[
                Flexible(child: Text(cuenta.nombre)),
                if (!cuenta.activa) ...<Widget>[
                  const SizedBox(width: 8),
                  const Chip(
                    label: Text('inactiva'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
            subtitle: Text(
              '${cuenta.tipo.etiqueta} · ${cuenta.moneda}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  formatearMonto(saldo.saldoCentavos, cuenta.moneda),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                PopupMenuButton<String>(
                  onSelected: (String opcion) =>
                      _accion(context, ref, cuenta, opcion),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'editar',
                      child: Text('Editar'),
                    ),
                    PopupMenuItem<String>(
                      value: 'activa',
                      child: Text(
                        cuenta.activa ? 'Desactivar' : 'Activar',
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'borrar',
                      child: Text('Borrar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _accion(
    BuildContext context,
    WidgetRef ref,
    Cuenta cuenta,
    String opcion,
  ) async {
    final repo = ref.read(cuentasRepoProvider);
    switch (opcion) {
      case 'editar':
        context.push('/cuentas/${cuenta.id}/editar');
      case 'activa':
        await repo.cambiarActiva(cuenta.id, !cuenta.activa);
        if (context.mounted) {
          mostrarAviso(
            context,
            cuenta.activa
                ? 'Cuenta desactivada (no aparecerá al registrar).'
                : 'Cuenta activada.',
          );
        }
      case 'borrar':
        final bool tiene = await repo.tieneTransacciones(cuenta.id);
        if (!context.mounted) {
          return;
        }
        if (tiene) {
          final bool desactivar = await confirmarAccion(
            context,
            titulo: 'La cuenta tiene movimientos',
            mensaje: 'No se puede borrar sin perder historia. ¿Quieres '
                'desactivarla para que no aparezca al registrar?',
            textoConfirmar: 'Desactivar',
          );
          if (desactivar) {
            await repo.cambiarActiva(cuenta.id, false);
            if (context.mounted) {
              mostrarAviso(context, 'Cuenta desactivada.');
            }
          }
        } else {
          final bool borrar = await confirmarAccion(
            context,
            titulo: 'Borrar cuenta',
            mensaje: 'Se ocultará la cuenta "${cuenta.nombre}".',
            textoConfirmar: 'Borrar',
            destructivo: true,
          );
          if (borrar) {
            await repo.eliminarLogico(cuenta.id);
            if (context.mounted) {
              mostrarAviso(context, 'Cuenta borrada.');
            }
          }
        }
    }
  }

  IconData _icono(TipoCuenta tipo) {
    switch (tipo) {
      case TipoCuenta.efectivo:
        return Icons.payments_outlined;
      case TipoCuenta.banco:
        return Icons.account_balance_outlined;
      case TipoCuenta.nequi:
      case TipoCuenta.daviplata:
        return Icons.phone_android;
      case TipoCuenta.tarjetaCredito:
        return Icons.credit_card;
      case TipoCuenta.ahorro:
        return Icons.savings_outlined;
      case TipoCuenta.inversion:
        return Icons.trending_up;
    }
  }
}
