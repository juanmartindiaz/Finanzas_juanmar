import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/iconos.dart';
import '../../data/providers.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/subcategoria.dart';
import '../shared/vistas.dart';

/// Gestión de categorías y subcategorías.
class CategoriasScreen extends ConsumerWidget {
  const CategoriasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasProvider);
    final subcategoriasAsync = ref.watch(subcategoriasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crearCategoria(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva categoría'),
      ),
      body: categoriasAsync.hasError || subcategoriasAsync.hasError
          ? VistaError(
              error: categoriasAsync.error ?? subcategoriasAsync.error!,
              onReintentar: () {
                ref.invalidate(categoriasProvider);
                ref.invalidate(subcategoriasProvider);
              },
            )
          : !categoriasAsync.hasValue || !subcategoriasAsync.hasValue
              ? const VistaCargando()
              : _Lista(
                  categorias: categoriasAsync.value!,
                  subcategorias: subcategoriasAsync.value!,
                ),
    );
  }
}

class _Lista extends ConsumerWidget {
  const _Lista({required this.categorias, required this.subcategorias});

  final List<Categoria> categorias;
  final List<Subcategoria> subcategorias;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categorias.isEmpty) {
      return VistaVacia(
        icono: Icons.category_outlined,
        mensaje: 'No hay categorías',
        detalle: 'Crea una categoría de gasto o de ingreso.',
        accion: FilledButton.icon(
          onPressed: () => _crearCategoria(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Crear categoría'),
        ),
      );
    }

    final List<NaturalezaCategoria> orden = <NaturalezaCategoria>[
      NaturalezaCategoria.gasto,
      NaturalezaCategoria.ingreso,
      NaturalezaCategoria.ambos,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      children: <Widget>[
        for (final NaturalezaCategoria naturaleza in orden)
          if (categorias.any(
            (Categoria categoria) => categoria.naturaleza == naturaleza,
          )) ...<Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
              child: Text(
                naturaleza == NaturalezaCategoria.gasto
                    ? 'Gastos'
                    : naturaleza == NaturalezaCategoria.ingreso
                        ? 'Ingresos'
                        : 'Ingresos y gastos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final Categoria categoria in categorias.where(
              (Categoria categoria) => categoria.naturaleza == naturaleza,
            ))
              _CategoriaCard(
                categoria: categoria,
                subcategorias: subcategorias
                    .where(
                      (Subcategoria subcategoria) =>
                          subcategoria.categoriaId == categoria.id,
                    )
                    .toList(),
              ),
          ],
      ],
    );
  }
}

class _CategoriaCard extends ConsumerWidget {
  const _CategoriaCard({
    required this.categoria,
    required this.subcategorias,
  });

  final Categoria categoria;
  final List<Subcategoria> subcategorias;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color color = colorPorHex(categoria.color);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(iconoPorNombre(categoria.icono), color: color),
        ),
        title: Row(
          children: <Widget>[
            Flexible(child: Text(categoria.nombre)),
            if (categoria.archivada) ...<Widget>[
              const SizedBox(width: 8),
              const Chip(
                label: Text('archivada'),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${subcategorias.length} subcategorías'
          '${categoria.predefinida ? ' · de fábrica' : ''}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String opcion) =>
              _accionCategoria(context, ref, opcion),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'editar',
              child: Text('Editar'),
            ),
            PopupMenuItem<String>(
              value: 'archivar',
              child: Text(
                categoria.archivada ? 'Reactivar' : 'Archivar',
              ),
            ),
            const PopupMenuItem<String>(
              value: 'borrar',
              child: Text('Borrar'),
            ),
          ],
        ),
        children: <Widget>[
          for (final Subcategoria subcategoria in subcategorias)
            ListTile(
              dense: true,
              leading: const Icon(Icons.subdirectory_arrow_right, size: 20),
              title: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: <Widget>[
                    Flexible(child: Text(subcategoria.nombre)),
                    if (subcategoria.archivada) ...<Widget>[
                      const SizedBox(width: 8),
                      const Chip(
                        label: Text('archivada'),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ],
                ),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (String opcion) =>
                    _accionSubcategoria(context, ref, subcategoria, opcion),
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'editar',
                    child: Text('Editar'),
                  ),
                  PopupMenuItem<String>(
                    value: 'archivar',
                    child: Text(
                      subcategoria.archivada ? 'Reactivar' : 'Archivar',
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'borrar',
                    child: Text('Borrar'),
                  ),
                ],
              ),
            ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.add, size: 20),
            title: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Agregar subcategoría'),
            ),
            onTap: () => _crearSubcategoria(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _accionCategoria(
    BuildContext context,
    WidgetRef ref,
    String opcion,
  ) async {
    final repo = ref.read(categoriasRepoProvider);
    switch (opcion) {
      case 'editar':
        await _editarCategoria(context, ref, categoria);
      case 'archivar':
        await repo.archivarCategoria(
          categoria.id,
          archivada: !categoria.archivada,
        );
        if (context.mounted) {
          mostrarAviso(
            context,
            categoria.archivada ? 'Categoría reactivada.' : 'Categoría archivada.',
          );
        }
      case 'borrar':
        final bool tiene = await repo.categoriaTieneTransacciones(categoria.id);
        if (!context.mounted) {
          return;
        }
        if (tiene) {
          final bool archivar = await confirmarAccion(
            context,
            titulo: 'La categoría tiene movimientos',
            mensaje: 'No se puede borrar sin perder historia. ¿Quieres '
                'archivarla para que no aparezca al registrar?',
            textoConfirmar: 'Archivar',
          );
          if (archivar) {
            await repo.archivarCategoria(categoria.id, archivada: true);
            if (context.mounted) {
              mostrarAviso(context, 'Categoría archivada.');
            }
          }
        } else {
          final bool borrar = await confirmarAccion(
            context,
            titulo: 'Borrar categoría',
            mensaje: 'Se ocultará la categoría "${categoria.nombre}".',
            textoConfirmar: 'Borrar',
            destructivo: true,
          );
          if (borrar) {
            await repo.eliminarCategoriaLogico(categoria.id);
            if (context.mounted) {
              mostrarAviso(context, 'Categoría borrada.');
            }
          }
        }
    }
  }

  Future<void> _accionSubcategoria(
    BuildContext context,
    WidgetRef ref,
    Subcategoria subcategoria,
    String opcion,
  ) async {
    final repo = ref.read(categoriasRepoProvider);
    switch (opcion) {
      case 'editar':
        await _editarSubcategoria(context, ref, subcategoria);
      case 'archivar':
        await repo.archivarSubcategoria(
          subcategoria.id,
          archivada: !subcategoria.archivada,
        );
        if (context.mounted) {
          mostrarAviso(
            context,
            subcategoria.archivada
                ? 'Subcategoría reactivada.'
                : 'Subcategoría archivada.',
          );
        }
      case 'borrar':
        final bool tiene =
            await repo.subcategoriaTieneTransacciones(subcategoria.id);
        if (!context.mounted) {
          return;
        }
        if (tiene) {
          final bool archivar = await confirmarAccion(
            context,
            titulo: 'La subcategoría tiene movimientos',
            mensaje: 'Se archivará en lugar de borrarse.',
            textoConfirmar: 'Archivar',
          );
          if (archivar) {
            await repo.archivarSubcategoria(subcategoria.id, archivada: true);
            if (context.mounted) {
              mostrarAviso(context, 'Subcategoría archivada.');
            }
          }
        } else {
          final bool borrar = await confirmarAccion(
            context,
            titulo: 'Borrar subcategoría',
            mensaje: 'Se ocultará "${subcategoria.nombre}".',
            textoConfirmar: 'Borrar',
            destructivo: true,
          );
          if (borrar) {
            await repo.eliminarSubcategoriaLogico(subcategoria.id);
            if (context.mounted) {
              mostrarAviso(context, 'Subcategoría borrada.');
            }
          }
        }
    }
  }

  Future<void> _crearSubcategoria(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final String? nombre = await showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          const _DialogoTexto(titulo: 'Nueva subcategoría'),
    );
    if (nombre == null || nombre.trim().isEmpty) {
      return;
    }
    try {
      await ref.read(categoriasRepoProvider).crearSubcategoria(
            categoriaId: categoria.id,
            nombre: nombre.trim(),
          );
      if (context.mounted) {
        mostrarAviso(context, 'Subcategoría creada.');
      }
    } on Exception catch (e) {
      if (context.mounted) {
        mostrarAviso(context, 'No se pudo crear: $e');
      }
    }
  }

  Future<void> _editarSubcategoria(
    BuildContext context,
    WidgetRef ref,
    Subcategoria subcategoria,
  ) async {
    final String? nombre = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => _DialogoTexto(
        titulo: 'Editar subcategoría',
        valorInicial: subcategoria.nombre,
      ),
    );
    if (nombre == null || nombre.trim().isEmpty) {
      return;
    }
    await ref.read(categoriasRepoProvider).actualizarSubcategoria(
          id: subcategoria.id,
          nombre: nombre.trim(),
        );
    if (context.mounted) {
      mostrarAviso(context, 'Subcategoría actualizada.');
    }
  }
}

Future<void> _crearCategoria(BuildContext context, WidgetRef ref) async {
  final _DatosCategoria? datos = await showDialog<_DatosCategoria>(
    context: context,
    builder: (BuildContext context) => const _DialogoCategoria(),
  );
  if (datos == null) {
    return;
  }
  try {
    await ref.read(categoriasRepoProvider).crearCategoria(
          nombre: datos.nombre,
          naturaleza: datos.naturaleza,
          icono: datos.icono,
          color: datos.color,
        );
    if (context.mounted) {
      mostrarAviso(context, 'Categoría creada.');
    }
  } on Exception catch (e) {
    if (context.mounted) {
      mostrarAviso(context, 'No se pudo crear: $e');
    }
  }
}

Future<void> _editarCategoria(
  BuildContext context,
  WidgetRef ref,
  Categoria categoria,
) async {
  final _DatosCategoria? datos = await showDialog<_DatosCategoria>(
    context: context,
    builder: (BuildContext context) => _DialogoCategoria(categoria: categoria),
  );
  if (datos == null) {
    return;
  }
  await ref.read(categoriasRepoProvider).actualizarCategoria(
        id: categoria.id,
        nombre: datos.nombre,
        naturaleza: datos.naturaleza,
        icono: datos.icono,
        color: datos.color,
      );
  if (context.mounted) {
    mostrarAviso(context, 'Categoría actualizada.');
  }
}

class _DatosCategoria {
  const _DatosCategoria({
    required this.nombre,
    required this.naturaleza,
    this.icono,
    this.color,
  });

  final String nombre;
  final NaturalezaCategoria naturaleza;
  final String? icono;
  final String? color;
}

class _DialogoCategoria extends StatefulWidget {
  const _DialogoCategoria({this.categoria});

  final Categoria? categoria;

  @override
  State<_DialogoCategoria> createState() => _DialogoCategoriaState();
}

class _DialogoCategoriaState extends State<_DialogoCategoria> {
  late final TextEditingController _nombreCtrl;
  late NaturalezaCategoria _naturaleza;
  String? _icono;
  String? _color;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.categoria?.nombre ?? '');
    _naturaleza =
        widget.categoria?.naturaleza ?? NaturalezaCategoria.gasto;
    _icono = widget.categoria?.icono ?? 'category';
    _color = widget.categoria?.color ?? paletaColores.first;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.categoria == null ? 'Nueva categoría' : 'Editar categoría',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<NaturalezaCategoria>(
                  isExpanded: true,
                  value: _naturaleza,
                  items: <DropdownMenuItem<NaturalezaCategoria>>[
                    for (final NaturalezaCategoria naturaleza
                        in NaturalezaCategoria.values)
                      DropdownMenuItem<NaturalezaCategoria>(
                        value: naturaleza,
                        child: Text(naturaleza.etiqueta),
                      ),
                  ],
                  onChanged: (NaturalezaCategoria? valor) {
                    if (valor != null) {
                      setState(() => _naturaleza = valor);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Icono'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: <Widget>[
                for (final MapEntry<String, IconData> entrada
                    in catalogoIconos.entries)
                  InkWell(
                    onTap: () => setState(() => _icono = entrada.key),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _icono == entrada.key
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor,
                          width: _icono == entrada.key ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(entrada.value, size: 22),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Color'),
            const SizedBox(height: 8),
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
                          color: _color == hex
                              ? Colors.white
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: _color == hex
                            ? <BoxShadow>[
                                BoxShadow(
                                  color: colorPorHex(hex),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final String nombre = _nombreCtrl.text.trim();
            if (nombre.isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              _DatosCategoria(
                nombre: nombre,
                naturaleza: _naturaleza,
                icono: _icono,
                color: _color,
              ),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _DialogoTexto extends StatefulWidget {
  const _DialogoTexto({required this.titulo, this.valorInicial});

  final String titulo;
  final String? valorInicial;

  @override
  State<_DialogoTexto> createState() => _DialogoTextoState();
}

class _DialogoTextoState extends State<_DialogoTexto> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.valorInicial ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Nombre'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_ctrl.text.trim()),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
