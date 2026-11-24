import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/dinero.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/cuenta.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/entities/transaccion.dart';
import '../../domain/usecases/dashboard.dart';
import '../../data/providers.dart';
import '../shared/transaccion_item.dart';
import '../shared/vistas.dart';

/// Pantalla principal: saldos, subtotales, total consolidado y últimos
/// movimientos.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuentasAsync = ref.watch(cuentasProvider);
    final transaccionesAsync = ref.watch(transaccionesProvider);
    final tasasAsync = ref.watch(tasasProvider);
    final monedaBaseAsync = ref.watch(monedaBaseProvider);
    final categoriasAsync = ref.watch(categoriasProvider);
    final pendientesAsync = ref.watch(capturasPendientesProvider);
    final int pendientes = switch (pendientesAsync) {
      AsyncData<int>(:final int value) => value,
      _ => 0,
    };

    final bool hayError = cuentasAsync.hasError ||
        transaccionesAsync.hasError ||
        tasasAsync.hasError ||
        monedaBaseAsync.hasError ||
        categoriasAsync.hasError;
    final bool cargando = !cuentasAsync.hasValue ||
        !transaccionesAsync.hasValue ||
        !tasasAsync.hasValue ||
        !monedaBaseAsync.hasValue ||
        !categoriasAsync.hasValue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor Finanzas'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Bandeja de capturas',
            icon: Badge(
              isLabelVisible: pendientes > 0,
              label: Text('$pendientes'),
              child: const Icon(Icons.inbox_outlined),
            ),
            onPressed: () => context.push('/bandeja'),
          ),
          IconButton(
            tooltip: 'Cuentas',
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () => context.push('/cuentas'),
          ),
          IconButton(
            tooltip: 'Transacciones',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => context.push('/transacciones'),
          ),
          IconButton(
            tooltip: 'Ajustes',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/ajustes'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transacciones/nueva'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo movimiento'),
      ),
      body: hayError
          ? VistaError(
              error: cuentasAsync.error ??
                  transaccionesAsync.error ??
                  tasasAsync.error ??
                  monedaBaseAsync.error ??
                  categoriasAsync.error ??
                  'Error desconocido',
              onReintentar: () {
                ref.invalidate(cuentasProvider);
                ref.invalidate(transaccionesProvider);
                ref.invalidate(tasasProvider);
                ref.invalidate(monedaBaseProvider);
                ref.invalidate(categoriasProvider);
              },
            )
          : cargando
              ? const VistaCargando()
              : _Contenido(
                  data: construirDashboard(
                    cuentas: cuentasAsync.value!,
                    transacciones: transaccionesAsync.value!,
                    tasas: tasasAsync.value!,
                    monedaBase: monedaBaseAsync.value!,
                  ),
                  monedaBase: monedaBaseAsync.value!,
                  categorias: categoriasAsync.value!,
                  cuentas: cuentasAsync.value!,
                ),
    );
  }
}

class _Contenido extends ConsumerWidget {
  const _Contenido({
    required this.data,
    required this.monedaBase,
    required this.categorias,
    required this.cuentas,
  });

  final DashboardData data;
  final String monedaBase;
  final List<Categoria> categorias;
  final List<Cuenta> cuentas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<int, Categoria> categoriasPorId = <int, Categoria>{
      for (final Categoria categoria in categorias) categoria.id: categoria,
    };
    final Map<int, Cuenta> cuentasPorId = <int, Cuenta>{
      for (final Cuenta cuenta in cuentas) cuenta.id: cuenta,
    };

    final Map<GrupoCuenta, List<SaldoCuenta>> porGrupo =
        <GrupoCuenta, List<SaldoCuenta>>{};
    for (final SaldoCuenta saldo in data.saldos) {
      porGrupo.putIfAbsent(saldo.cuenta.tipo.grupo, () => <SaldoCuenta>[])
        .add(saldo);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: <Widget>[
        _TarjetaTotal(data: data),
        if (data.subtotales.length > 1) ...<Widget>[
          const SizedBox(height: 12),
          _Subtotales(subtotales: data.subtotales),
        ],
        const SizedBox(height: 20),
        if (data.saldos.isEmpty)
          VistaVacia(
            icono: Icons.account_balance_wallet_outlined,
            mensaje: 'Aún no tienes cuentas',
            detalle: 'Crea tu primera cuenta para empezar a registrar '
                'movimientos.',
            accion: FilledButton.icon(
              onPressed: () => context.push('/cuentas/nueva'),
              icon: const Icon(Icons.add),
              label: const Text('Crear cuenta'),
            ),
          )
        else
          for (final GrupoCuenta grupo in GrupoCuenta.values)
            if (porGrupo.containsKey(grupo)) ...<Widget>[
              _SeccionGrupo(grupo: grupo, saldos: porGrupo[grupo]!),
              const SizedBox(height: 12),
            ],
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Últimos movimientos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () => context.push('/transacciones'),
              child: const Text('Ver todos'),
            ),
          ],
        ),
        if (data.recientes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('Todavía no hay movimientos registrados.'),
          )
        else
          Card(
            child: Column(
              children: <Widget>[
                for (final Transaccion transaccion in data.recientes)
                  TransaccionItem(
                    transaccion: transaccion,
                    cuentasPorId: cuentasPorId,
                    categoriasPorId: categoriasPorId,
                    onTap: () => context
                        .push('/transacciones/${transaccion.id}/editar'),
                    onEliminar: () => _borrar(context, ref, transaccion),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _borrar(
    BuildContext context,
    WidgetRef ref,
    Transaccion transaccion,
  ) async {
    final bool confirma = await confirmarAccion(
      context,
      titulo: 'Borrar movimiento',
      mensaje: 'El saldo de la cuenta se recalculará automáticamente. '
          '¿Quieres borrarlo?',
      textoConfirmar: 'Borrar',
      destructivo: true,
    );
    if (!confirma) {
      return;
    }
    await ref.read(transaccionesRepoProvider).eliminarLogico(transaccion.id);
    if (context.mounted) {
      mostrarAviso(context, 'Movimiento borrado.');
    }
  }
}

class _TarjetaTotal extends StatelessWidget {
  const _TarjetaTotal({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Total consolidado (${data.consolidado.monedaBase})',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              formatearMonto(
                data.consolidado.totalCentavos,
                data.consolidado.monedaBase,
              ),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!data.consolidado.completo) ...<Widget>[
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Sin tasa de cambio para: '
                      '${data.consolidado.monedasSinTasa.join(', ')}. '
                      'Esas cuentas no se incluyen en el total.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/ajustes/monedas'),
                  child: const Text('Configurar tasas'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Subtotales extends StatelessWidget {
  const _Subtotales({required this.subtotales});

  final List<TotalPorMoneda> subtotales;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final TotalPorMoneda total in subtotales)
          Chip(
            avatar: Icon(
              Icons.payments_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            label: Text(
              '${total.moneda} ${formatearMonto(total.centavos, total.moneda)}',
            ),
          ),
      ],
    );
  }
}

class _SeccionGrupo extends StatelessWidget {
  const _SeccionGrupo({required this.grupo, required this.saldos});

  final GrupoCuenta grupo;
  final List<SaldoCuenta> saldos;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              grupo.etiqueta,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          for (final SaldoCuenta saldo in saldos)
            ListTile(
              onTap: () =>
                  context.push('/cuentas/${saldo.cuenta.id}/editar'),
              leading: Icon(_icono(saldo.cuenta.tipo)),
              title: Row(
                children: <Widget>[
                  Flexible(child: Text(saldo.cuenta.nombre)),
                  if (!saldo.cuenta.activa) ...<Widget>[
                    const SizedBox(width: 8),
                    const Chip(
                      label: Text('inactiva'),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ],
              ),
              subtitle: Text(saldo.cuenta.tipo.etiqueta),
              trailing: Text(
                formatearMonto(saldo.saldoCentavos, saldo.cuenta.moneda),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
        ],
      ),
    );
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
