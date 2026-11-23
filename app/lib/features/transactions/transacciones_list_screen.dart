import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/fechas.dart';
import '../../data/providers.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/cuenta.dart';
import '../../domain/entities/etiqueta.dart';
import '../../domain/entities/transaccion.dart';
import '../../domain/usecases/filtros.dart';
import '../shared/transaccion_item.dart';
import '../shared/vistas.dart';

/// Listado de transacciones con filtros básicos y búsqueda por nota.
class TransaccionesListScreen extends ConsumerStatefulWidget {
  const TransaccionesListScreen({super.key});

  @override
  ConsumerState<TransaccionesListScreen> createState() =>
      _TransaccionesListScreenState();
}

class _TransaccionesListScreenState
    extends ConsumerState<TransaccionesListScreen> {
  final TextEditingController _busquedaCtrl = TextEditingController();
  FiltroTransacciones _filtro = const FiltroTransacciones();

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transaccionesAsync = ref.watch(transaccionesProvider);
    final cuentasAsync = ref.watch(cuentasProvider);
    final categoriasAsync = ref.watch(categoriasProvider);
    final etiquetasAsync = ref.watch(etiquetasProvider);

    final bool hayError = transaccionesAsync.hasError ||
        cuentasAsync.hasError ||
        categoriasAsync.hasError ||
        etiquetasAsync.hasError;
    final bool cargando = !transaccionesAsync.hasValue ||
        !cuentasAsync.hasValue ||
        !categoriasAsync.hasValue ||
        !etiquetasAsync.hasValue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
        actions: <Widget>[
          if (!_filtro.vacio)
            IconButton(
              tooltip: 'Limpiar filtros',
              icon: const Icon(Icons.filter_alt_off_outlined),
              onPressed: () {
                _busquedaCtrl.clear();
                setState(() => _filtro = const FiltroTransacciones());
              },
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
              error: transaccionesAsync.error ??
                  cuentasAsync.error ??
                  categoriasAsync.error ??
                  etiquetasAsync.error ??
                  'Error desconocido',
              onReintentar: () {
                ref.invalidate(transaccionesProvider);
                ref.invalidate(cuentasProvider);
                ref.invalidate(categoriasProvider);
                ref.invalidate(etiquetasProvider);
              },
            )
          : cargando
              ? const VistaCargando()
              : Column(
                  children: <Widget>[
                    _Filtros(
                      filtro: _filtro,
                      busquedaCtrl: _busquedaCtrl,
                      cuentas: cuentasAsync.value!,
                      categorias: categoriasAsync.value!,
                      etiquetas: etiquetasAsync.value!,
                      onCambio: (FiltroTransacciones filtro) =>
                          setState(() => _filtro = filtro),
                    ),
                    Expanded(
                      child: _Lista(
                        transacciones: aplicarFiltroTransacciones(
                          transaccionesAsync.value!,
                          _filtro,
                        ),
                        cuentas: cuentasAsync.value!,
                        categorias: categoriasAsync.value!,
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _Filtros extends StatelessWidget {
  const _Filtros({
    required this.filtro,
    required this.busquedaCtrl,
    required this.cuentas,
    required this.categorias,
    required this.etiquetas,
    required this.onCambio,
  });

  final FiltroTransacciones filtro;
  final TextEditingController busquedaCtrl;
  final List<Cuenta> cuentas;
  final List<Categoria> categorias;
  final List<Etiqueta> etiquetas;
  final ValueChanged<FiltroTransacciones> onCambio;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            TextField(
              controller: busquedaCtrl,
              decoration: InputDecoration(
                labelText: 'Buscar en la nota',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: const OutlineInputBorder(),
                suffixIcon: busquedaCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          busquedaCtrl.clear();
                          onCambio(filtro.copyWith(texto: ''));
                        },
                      ),
              ),
              onChanged: (String texto) =>
                  onCambio(filtro.copyWith(texto: texto)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _Selector<TipoTransaccion>(
                  etiqueta: 'Tipo',
                  valor: filtro.tipo,
                  items: TipoTransaccion.values,
                  texto: (TipoTransaccion tipo) => tipo.etiqueta,
                  onChanged: (TipoTransaccion? valor) => onCambio(
                    valor == null
                        ? filtro.copyWith(limpiarTipo: true)
                        : filtro.copyWith(tipo: valor),
                  ),
                ),
                _Selector<int>(
                  etiqueta: 'Cuenta',
                  valor: filtro.cuentaId,
                  items: cuentas.map((Cuenta cuenta) => cuenta.id).toList(),
                  texto: (int id) => cuentas
                      .firstWhere((Cuenta cuenta) => cuenta.id == id)
                      .nombre,
                  onChanged: (int? valor) => onCambio(
                    valor == null
                        ? filtro.copyWith(limpiarCuenta: true)
                        : filtro.copyWith(cuentaId: valor),
                  ),
                ),
                _Selector<int>(
                  etiqueta: 'Categoría',
                  valor: filtro.categoriaId,
                  items:
                      categorias.map((Categoria categoria) => categoria.id).toList(),
                  texto: (int id) => categorias
                      .firstWhere((Categoria categoria) => categoria.id == id)
                      .nombre,
                  onChanged: (int? valor) => onCambio(
                    valor == null
                        ? filtro.copyWith(limpiarCategoria: true)
                        : filtro.copyWith(categoriaId: valor),
                  ),
                ),
                _Selector<int>(
                  etiqueta: 'Etiqueta',
                  valor: filtro.etiquetaId,
                  items:
                      etiquetas.map((Etiqueta etiqueta) => etiqueta.id).toList(),
                  texto: (int id) => etiquetas
                      .firstWhere((Etiqueta etiqueta) => etiqueta.id == id)
                      .nombre,
                  onChanged: (int? valor) => onCambio(
                    valor == null
                        ? filtro.copyWith(limpiarEtiqueta: true)
                        : filtro.copyWith(etiquetaId: valor),
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    filtro.desde == null || filtro.hasta == null
                        ? 'Fechas'
                        : '${fechaTexto(filtro.desde!)} – '
                            '${fechaTexto(filtro.hasta!)}',
                  ),
                  onPressed: () async {
                    final DateTimeRange? rango = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDateRange: filtro.desde != null &&
                              filtro.hasta != null
                          ? DateTimeRange(
                              start: filtro.desde!,
                              end: filtro.hasta!,
                            )
                          : null,
                    );
                    if (rango != null) {
                      onCambio(
                        filtro.copyWith(
                          desde: rango.start,
                          hasta: rango.end,
                        ),
                      );
                    }
                  },
                ),
                if (filtro.desde != null || filtro.hasta != null)
                  ActionChip(
                    avatar: const Icon(Icons.close, size: 18),
                    label: const Text('Quitar fechas'),
                    onPressed: () => onCambio(
                      filtro.copyWith(
                        limpiarDesde: true,
                        limpiarHasta: true,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Selector<T> extends StatelessWidget {
  const _Selector({
    required this.etiqueta,
    required this.valor,
    required this.items,
    required this.texto,
    required this.onChanged,
  });

  final String etiqueta;
  final T? valor;
  final List<T> items;
  final String Function(T) texto;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          isDense: true,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T?>(
            isExpanded: true,
            isDense: true,
            value: valor,
            hint: const Text('Todas'),
            items: <DropdownMenuItem<T?>>[
              DropdownMenuItem<T?>(value: null, child: const Text('Todas')),
              for (final T item in items)
                DropdownMenuItem<T?>(value: item, child: Text(texto(item))),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _Lista extends ConsumerWidget {
  const _Lista({
    required this.transacciones,
    required this.cuentas,
    required this.categorias,
  });

  final List<Transaccion> transacciones;
  final List<Cuenta> cuentas;
  final List<Categoria> categorias;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (transacciones.isEmpty) {
      return const VistaVacia(
        icono: Icons.receipt_long_outlined,
        mensaje: 'No hay movimientos con estos filtros',
        detalle: 'Prueba a cambiar los filtros o registra un movimiento nuevo.',
      );
    }
    final Map<int, Cuenta> cuentasPorId = <int, Cuenta>{
      for (final Cuenta cuenta in cuentas) cuenta.id: cuenta,
    };
    final Map<int, Categoria> categoriasPorId = <int, Categoria>{
      for (final Categoria categoria in categorias) categoria.id: categoria,
    };

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 96),
      itemCount: transacciones.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int indice) {
        final Transaccion transaccion = transacciones[indice];
        return TransaccionItem(
          transaccion: transaccion,
          cuentasPorId: cuentasPorId,
          categoriasPorId: categoriasPorId,
          onTap: () =>
              context.push('/transacciones/${transaccion.id}/editar'),
          onEliminar: () => _borrar(context, ref, transaccion),
        );
      },
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
      mensaje: 'El saldo de la cuenta se recalculará automáticamente.',
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
