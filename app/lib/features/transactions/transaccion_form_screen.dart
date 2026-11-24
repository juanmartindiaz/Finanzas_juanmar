import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/dinero.dart';
import '../../core/utils/fechas.dart';
import '../../data/providers.dart';
import '../../domain/entities/captura.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/cuenta.dart';
import '../../domain/entities/etiqueta.dart';
import '../../domain/entities/subcategoria.dart';
import '../../domain/entities/transaccion.dart';
import '../../domain/usecases/validacion.dart';
import '../shared/vistas.dart';

/// Formulario para crear o editar un ingreso, gasto o transferencia.
class TransaccionFormScreen extends ConsumerStatefulWidget {
  const TransaccionFormScreen({super.key, this.transaccionId, this.capturaId});

  final int? transaccionId;

  /// Si viene, el formulario está en modo revisión de captura.
  final int? capturaId;

  @override
  ConsumerState<TransaccionFormScreen> createState() =>
      _TransaccionFormScreenState();
}

class _TransaccionFormScreenState
    extends ConsumerState<TransaccionFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _montoCtrl = TextEditingController();
  final TextEditingController _montoDestinoCtrl = TextEditingController();
  final TextEditingController _notaCtrl = TextEditingController();

  TipoTransaccion _tipo = TipoTransaccion.gasto;
  int? _cuentaId;
  int? _cuentaDestinoId;
  int? _categoriaId;
  int? _subcategoriaId;
  Set<int> _etiquetaIds = <int>{};
  DateTime _fechaHora = DateTime.now();
  bool _cargando = false;
  bool _guardando = false;
  List<String> _errores = <String>[];
  CapturaEntrante? _captura;
  File? _adjunto;

  bool get _esEdicion => widget.transaccionId != null;
  bool get _esRevision => widget.capturaId != null;
  bool get _esTransferencia => _tipo == TipoTransaccion.transferencia;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      _cargar();
    } else if (_esRevision) {
      _cargarCaptura();
    }
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _montoDestinoCtrl.dispose();
    _notaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final Transaccion? transaccion =
        await ref.read(transaccionesRepoProvider).obtener(widget.transaccionId!);
    if (!mounted) {
      return;
    }
    if (transaccion == null) {
      setState(() {
        _cargando = false;
        _errores = <String>['El movimiento no existe.'];
      });
      return;
    }
    setState(() {
      _cargando = false;
      _tipo = transaccion.tipo;
      _cuentaId = transaccion.cuentaId;
      _cuentaDestinoId = transaccion.cuentaDestinoId;
      _categoriaId = transaccion.categoriaId;
      _subcategoriaId = transaccion.subcategoriaId;
      _etiquetaIds =
          transaccion.etiquetas.map((elemento) => elemento.id).toSet();
      _fechaHora =
          DateTime.fromMillisecondsSinceEpoch(transaccion.fechaHora);
      _montoCtrl.text = formatearMonto(
        transaccion.montoCentavos,
        transaccion.moneda,
      );
      if (transaccion.montoDestinoCentavos != null) {
        _montoDestinoCtrl.text = formatearMonto(
          transaccion.montoDestinoCentavos!,
          transaccion.monedaDestino ?? transaccion.moneda,
        );
      }
      _notaCtrl.text = transaccion.nota ?? '';
    });
  }

  Future<void> _cargarCaptura() async {
    setState(() => _cargando = true);
    final CapturaEntrante? captura =
        await ref.read(capturasRepoProvider).obtener(widget.capturaId!);
    if (!mounted) {
      return;
    }
    if (captura == null) {
      setState(() {
        _cargando = false;
        _errores = <String>['La captura no existe.'];
      });
      return;
    }
    File? adjunto;
    if (captura.adjuntoPath != null) {
      final File archivo =
          await ref.read(almacenAdjuntosProvider).resolver(captura.adjuntoPath!);
      if (await archivo.exists()) {
        adjunto = archivo;
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _cargando = false;
      _captura = captura;
      _adjunto = adjunto;
      _fechaHora = DateTime.now();
      final PropuestaCaptura? propuesta = captura.propuesta;
      if (propuesta != null) {
        _tipo = propuesta.tipo ?? TipoTransaccion.gasto;
        if (propuesta.montoCentavos != null) {
          _montoCtrl.text =
              formatearMonto(propuesta.montoCentavos!, propuesta.moneda);
        }
        _cuentaId = propuesta.cuentaId;
        _categoriaId = propuesta.categoriaId;
        _subcategoriaId = propuesta.subcategoriaId;
        _etiquetaIds = propuesta.etiquetaIds.toSet();
      }
    });
  }

  Widget _tarjetaCaptura(BuildContext context) {
    final CapturaEntrante? captura = _captura;
    if (captura == null) {
      return const SizedBox.shrink();
    }
    final PropuestaCaptura? propuesta = captura.propuesta;
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  switch (captura.canal) {
                    CanalCaptura.texto => Icons.chat_outlined,
                    CanalCaptura.audio => Icons.mic_none,
                    CanalCaptura.foto => Icons.image_outlined,
                    CanalCaptura.app => Icons.edit_note,
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${captura.canal.etiqueta} · ${captura.origen.etiqueta}',
                  ),
                ),
                Chip(
                  label: Text(captura.estado.etiqueta),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            if (captura.textoCrudo != null &&
                captura.textoCrudo!.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text('"${captura.textoCrudo!.trim()}"'),
            ],
            if (captura.canal == CanalCaptura.foto && _adjunto != null) ...<Widget>[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _adjunto!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Text('No se pudo mostrar la foto.'),
                ),
              ),
            ] else if (captura.canal == CanalCaptura.audio) ...<Widget>[
              const SizedBox(height: 8),
              const Row(
                children: <Widget>[
                  Icon(Icons.audiotrack, size: 18),
                  SizedBox(width: 6),
                  Text('Audio adjunto (sin transcripción todavía)'),
                ],
              ),
            ],
            if (propuesta != null && propuesta.faltantes.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'El parser no pudo completar: ${propuesta.faltantes.join(', ')}.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cuentasAsync = ref.watch(cuentasProvider);    final categoriasAsync = ref.watch(categoriasProvider);
    final subcategoriasAsync = ref.watch(subcategoriasProvider);
    final etiquetasAsync = ref.watch(etiquetasProvider);

    final bool cargando = _cargando ||
        !cuentasAsync.hasValue ||
        !categoriasAsync.hasValue ||
        !subcategoriasAsync.hasValue ||
        !etiquetasAsync.hasValue;

    final List<Cuenta> cuentas = cuentasAsync.value ?? <Cuenta>[];
    final List<Categoria> categorias =
        categoriasAsync.value ?? <Categoria>[];
    final List<Subcategoria> subcategorias =
        subcategoriasAsync.value ?? <Subcategoria>[];
    final List<Etiqueta> etiquetas = etiquetasAsync.value ?? <Etiqueta>[];

    final List<Cuenta> cuentasDisponibles = cuentas
        .where(
          (Cuenta cuenta) =>
              cuenta.activa ||
              cuenta.id == _cuentaId ||
              cuenta.id == _cuentaDestinoId,
        )
        .toList();

    final Cuenta? cuentaOrigen = _buscarCuenta(cuentas, _cuentaId);
    final Cuenta? cuentaDestino = _buscarCuenta(cuentas, _cuentaDestinoId);
    final String monedaOrigen = cuentaOrigen?.moneda ?? monedaBasePorDefecto;
    final String monedaDestino = cuentaDestino?.moneda ?? monedaOrigen;

    final NaturalezaCategoria requerida = _tipo == TipoTransaccion.gasto
        ? NaturalezaCategoria.gasto
        : NaturalezaCategoria.ingreso;
    final List<Categoria> categoriasCompatibles = categorias
        .where(
          (Categoria categoria) =>
              !categoria.archivada || categoria.id == _categoriaId,
        )
        .where(
          (Categoria categoria) =>
              categoria.naturaleza == requerida ||
              categoria.naturaleza == NaturalezaCategoria.ambos,
        )
        .toList();
    final List<Subcategoria> subcategoriasCompatibles = subcategorias
        .where((Subcategoria subcategoria) {
      if (subcategoria.categoriaId != _categoriaId) {
        return false;
      }
      return !subcategoria.archivada || subcategoria.id == _subcategoriaId;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esRevision
              ? 'Revisar captura'
              : _esEdicion
                  ? 'Editar movimiento'
                  : 'Nuevo movimiento',
        ),
        actions: <Widget>[
          if (_esRevision)
            IconButton(
              tooltip: 'Descartar captura',
              icon: const Icon(Icons.delete_outline),
              onPressed: _descartar,
            ),
        ],
      ),
      body: cargando
          ? const VistaCargando()
          : cuentasDisponibles.isEmpty
              ? VistaVacia(
                  icono: Icons.account_balance_wallet_outlined,
                  mensaje: 'Necesitas una cuenta primero',
                  detalle: 'Crea una cuenta y vuelve para registrar el '
                      'movimiento.',
                  accion: FilledButton.icon(
                    onPressed: () => context.push('/cuentas/nueva'),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear cuenta'),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: <Widget>[
                      if (_esRevision) ...<Widget>[
                        _tarjetaCaptura(context),
                        const SizedBox(height: 16),
                      ],
                      SegmentedButton<TipoTransaccion>(
                        segments: <ButtonSegment<TipoTransaccion>>[
                          for (final TipoTransaccion tipo
                              in TipoTransaccion.values)
                            ButtonSegment<TipoTransaccion>(
                              value: tipo,
                              label: Text(tipo.etiqueta),
                            ),
                        ],
                        selected: <TipoTransaccion>{_tipo},
                        onSelectionChanged: (Set<TipoTransaccion> seleccion) {
                          setState(() {
                            _tipo = seleccion.first;
                            _categoriaId = null;
                            _subcategoriaId = null;
                            _cuentaDestinoId = null;
                            _montoDestinoCtrl.clear();
                            _errores = <String>[];
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _montoCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: _esTransferencia
                              ? 'Monto de origen'
                              : 'Monto',
                          suffixText: monedaOrigen,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (String? valor) {
                          final int? centavos = parsearMonto(valor ?? '');
                          if (centavos == null || centavos <= 0) {
                            return 'Escribe un monto mayor que cero.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _Desplegable<Cuenta>(
                        etiqueta: _esTransferencia
                            ? 'Cuenta de origen'
                            : 'Cuenta',
                        valor: cuentaOrigen,
                        items: cuentasDisponibles,
                        texto: (Cuenta cuenta) =>
                            '${cuenta.nombre} (${cuenta.moneda})',
                        onChanged: (Cuenta? cuenta) {
                          setState(() {
                            _cuentaId = cuenta?.id;
                            if (_esTransferencia &&
                                _cuentaDestinoId == cuenta?.id) {
                              _cuentaDestinoId = null;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_esTransferencia) ...<Widget>[
                        _Desplegable<Cuenta>(
                          etiqueta: 'Cuenta de destino',
                          valor: cuentaDestino,
                          items: cuentasDisponibles
                              .where((Cuenta cuenta) => cuenta.id != _cuentaId)
                              .toList(),
                          texto: (Cuenta cuenta) =>
                              '${cuenta.nombre} (${cuenta.moneda})',
                          onChanged: (Cuenta? cuenta) => setState(
                            () => _cuentaDestinoId = cuenta?.id,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _montoDestinoCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Monto que llega a destino',
                            suffixText: monedaDestino,
                            border: const OutlineInputBorder(),
                            helperText: monedaOrigen == monedaDestino
                                ? 'Igual al monto de origen si no hay comisión.'
                                : 'Se usa para calcular la tasa del movimiento.',
                          ),
                          validator: (String? valor) {
                            final int? centavos = parsearMonto(valor ?? '');
                            if (centavos == null || centavos <= 0) {
                              return 'Escribe el monto de destino.';
                            }
                            return null;
                          },
                        ),
                        if (monedaOrigen != monedaDestino &&
                            _tasaCalculada != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Tasa: 1 $monedaOrigen = '
                              '${formatearTasa(_tasaCalculada!)} '
                              '$monedaDestino',
                            ),
                          ),
                      ] else ...<Widget>[
                        _Desplegable<Categoria>(
                          etiqueta: 'Categoría',
                          valor: _buscarCategoria(
                            categoriasCompatibles,
                            _categoriaId,
                          ),
                          items: categoriasCompatibles,
                          texto: (Categoria categoria) => categoria.nombre,
                          onChanged: (Categoria? categoria) {
                            setState(() {
                              _categoriaId = categoria?.id;
                              _subcategoriaId = null;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        if (subcategoriasCompatibles.isNotEmpty)
                          _DesplegableOpcional<Subcategoria>(
                            etiqueta: 'Subcategoría (opcional)',
                            valor: _buscarSubcategoria(
                              subcategoriasCompatibles,
                              _subcategoriaId,
                            ),
                            items: subcategoriasCompatibles,
                            texto: (Subcategoria subcategoria) =>
                                subcategoria.nombre,
                            textoVacio: 'Sin subcategoría',
                            onChanged: (Subcategoria? subcategoria) => setState(
                              () => _subcategoriaId = subcategoria?.id,
                            ),
                          ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        'Etiquetas',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      if (etiquetas.isEmpty)
                        Text(
                          'No hay etiquetas. Puedes crearlas en Ajustes → '
                          'Etiquetas.',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            for (final Etiqueta etiqueta in etiquetas)
                              FilterChip(
                                label: Text(etiqueta.nombre),
                                selected: _etiquetaIds.contains(etiqueta.id),
                                onSelected: (bool seleccionada) {
                                  setState(() {
                                    if (seleccionada) {
                                      _etiquetaIds.add(etiqueta.id);
                                    } else {
                                      _etiquetaIds.remove(etiqueta.id);
                                    }
                                  });
                                },
                              ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _elegirFecha,
                              icon: const Icon(Icons.calendar_today_outlined),
                              label: Text(fechaTexto(_fechaHora)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _elegirHora,
                              icon: const Icon(Icons.access_time),
                              label: Text(_horaTexto),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nota (opcional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        maxLength: 1000,
                      ),
                      if (_errores.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 8),
                        Card(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                for (final String error in _errores)
                                  Text('• $error'),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _guardando ? null : _guardar,
                        icon: _guardando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _guardando ? 'Guardando…' : 'Guardar movimiento',
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  String get _horaTexto {
    final String hora = _fechaHora.hour.toString().padLeft(2, '0');
    final String minuto = _fechaHora.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  double? get _tasaCalculada {
    final int? origen = parsearMonto(_montoCtrl.text);
    final int? destino = parsearMonto(_montoDestinoCtrl.text);
    if (origen == null || destino == null || origen <= 0) {
      return null;
    }
    return destino / origen;
  }

  Future<void> _elegirFecha() async {
    final DateTime? seleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaHora,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (seleccionada == null) {
      return;
    }
    setState(() {
      _fechaHora = DateTime(
        seleccionada.year,
        seleccionada.month,
        seleccionada.day,
        _fechaHora.hour,
        _fechaHora.minute,
      );
    });
  }

  Future<void> _elegirHora() async {
    final TimeOfDay? seleccionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fechaHora),
    );
    if (seleccionada == null) {
      return;
    }
    setState(() {
      _fechaHora = DateTime(
        _fechaHora.year,
        _fechaHora.month,
        _fechaHora.day,
        seleccionada.hour,
        seleccionada.minute,
      );
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final List<Cuenta> cuentas =
        ref.read(cuentasProvider).value ?? <Cuenta>[];
    final List<Categoria> categorias =
        ref.read(categoriasProvider).value ?? <Categoria>[];
    final List<Subcategoria> subcategorias =
        ref.read(subcategoriasProvider).value ?? <Subcategoria>[];

    final Cuenta? cuentaOrigen = _buscarCuenta(cuentas, _cuentaId);
    final Cuenta? cuentaDestino = _buscarCuenta(cuentas, _cuentaDestinoId);
    final String monedaOrigen = cuentaOrigen?.moneda ?? monedaBasePorDefecto;
    final int? monto = parsearMonto(_montoCtrl.text);
    final int? montoDestino =
        _esTransferencia ? parsearMonto(_montoDestinoCtrl.text) : null;

    final List<String> errores = validarTransaccion(
      tipo: _tipo,
      montoCentavos: monto,
      moneda: monedaOrigen,
      cuentaId: _cuentaId,
      cuentaDestinoId: _esTransferencia ? _cuentaDestinoId : null,
      montoDestinoCentavos: montoDestino,
      monedaDestino: _esTransferencia ? cuentaDestino?.moneda : null,
      categoriaId: _esTransferencia ? null : _categoriaId,
      subcategoriaId: _esTransferencia ? null : _subcategoriaId,
      fechaHora: _fechaHora,
      nota: _notaCtrl.text,
      cuentas: cuentas,
      categorias: categorias,
      subcategorias: subcategorias,
      permitirFechaFutura: true,
    );
    setState(() => _errores = errores);
    if (errores.isNotEmpty) {
      return;
    }

    final bool esFuturo = _fechaHora.isAfter(
      DateTime.now().add(const Duration(minutes: 1)),
    );
    if (esFuturo) {
      final bool continuar = await confirmarAccion(
        context,
        titulo: 'Fecha futura',
        mensaje: 'Elegiste una fecha que todavía no ha pasado. '
            '¿Quieres guardarla igualmente?',
        textoConfirmar: 'Guardar igual',
      );
      if (!continuar) {
        return;
      }
    }

    setState(() {
      _guardando = true;
      _errores = <String>[];
    });

    try {
      final String monedaDestino = cuentaDestino?.moneda ?? monedaOrigen;
      final double? tasa = _esTransferencia &&
              monedaOrigen != monedaDestino &&
              monto != null &&
              monto > 0 &&
              montoDestino != null
          ? montoDestino / monto
          : null;
      if (_esRevision) {
        await ref.read(capturasRepoProvider).confirmar(
          capturaId: widget.capturaId!,
          tipo: _tipo,
          montoCentavos: monto!,
          moneda: monedaOrigen,
          cuentaId: _cuentaId!,
          fecha: fechaIso(_fechaHora),
          fechaHora: _fechaHora.millisecondsSinceEpoch,
          etiquetaIds: _etiquetaIds.toList(),
          cuentaDestinoId: _esTransferencia ? _cuentaDestinoId : null,
          montoDestinoCentavos: _esTransferencia ? montoDestino : null,
          monedaDestino: _esTransferencia ? monedaDestino : null,
          categoriaId: _esTransferencia ? null : _categoriaId,
          subcategoriaId: _esTransferencia ? null : _subcategoriaId,
          nota: _notaCtrl.text.trim().isEmpty ? null : _notaCtrl.text.trim(),
          tasaCambio: tasa,
        );
      } else if (_esEdicion) {
        await ref.read(transaccionesRepoProvider).actualizar(
          id: widget.transaccionId!,
          tipo: _tipo,
          montoCentavos: monto!,
          moneda: monedaOrigen,
          cuentaId: _cuentaId!,
          fecha: fechaIso(_fechaHora),
          fechaHora: _fechaHora.millisecondsSinceEpoch,
          etiquetaIds: _etiquetaIds.toList(),
          cuentaDestinoId: _esTransferencia ? _cuentaDestinoId : null,
          montoDestinoCentavos: _esTransferencia ? montoDestino : null,
          monedaDestino: _esTransferencia ? monedaDestino : null,
          categoriaId: _esTransferencia ? null : _categoriaId,
          subcategoriaId: _esTransferencia ? null : _subcategoriaId,
          nota: _notaCtrl.text.trim().isEmpty ? null : _notaCtrl.text.trim(),
          tasaCambio: tasa,
        );
      } else {
        await ref.read(transaccionesRepoProvider).crear(
          tipo: _tipo,
          montoCentavos: monto!,
          moneda: monedaOrigen,
          cuentaId: _cuentaId!,
          fecha: fechaIso(_fechaHora),
          fechaHora: _fechaHora.millisecondsSinceEpoch,
          etiquetaIds: _etiquetaIds.toList(),
          cuentaDestinoId: _esTransferencia ? _cuentaDestinoId : null,
          montoDestinoCentavos: _esTransferencia ? montoDestino : null,
          monedaDestino: _esTransferencia ? monedaDestino : null,
          categoriaId: _esTransferencia ? null : _categoriaId,
          subcategoriaId: _esTransferencia ? null : _subcategoriaId,
          nota: _notaCtrl.text.trim().isEmpty ? null : _notaCtrl.text.trim(),
          tasaCambio: tasa,
        );
      }
      if (!mounted) {
        return;
      }
      mostrarAviso(
        context,
        _esRevision
            ? 'Captura confirmada.'
            : _esEdicion
                ? 'Movimiento actualizado.'
                : 'Movimiento guardado.',
      );
      context.pop();
    } on Exception catch (e) {
      setState(() => _errores = <String>['No se pudo guardar: $e']);
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }
  Future<void> _descartar() async {
    final CapturaEntrante? captura = _captura;
    if (captura == null) {
      return;
    }
    final bool confirma = await confirmarAccion(
      context,
      titulo: 'Descartar captura',
      mensaje: 'No se creará ninguna transacción.',
      textoConfirmar: 'Descartar',
      destructivo: true,
    );
    if (!confirma || !mounted) {
      return;
    }
    bool borrarArchivo = false;
    if (captura.adjuntoPath != null) {
      borrarArchivo = await confirmarAccion(
        context,
        titulo: 'Archivo adjunto',
        mensaje: '¿Quieres borrar también el archivo guardado?',
        textoConfirmar: 'Borrar archivo',
        destructivo: true,
      );
    }
    await ref.read(capturasRepoProvider).descartar(captura.id);
    if (borrarArchivo && captura.adjuntoPath != null) {
      await ref.read(almacenAdjuntosProvider).borrar(captura.adjuntoPath!);
    }
    if (!mounted) {
      return;
    }
    mostrarAviso(context, 'Captura descartada.');
    context.pop();
  }
}

Cuenta? _buscarCuenta(List<Cuenta> cuentas, int? id) {
  if (id == null) {
    return null;
  }
  for (final Cuenta cuenta in cuentas) {
    if (cuenta.id == id) {
      return cuenta;
    }
  }
  return null;
}

Categoria? _buscarCategoria(List<Categoria> categorias, int? id) {
  if (id == null) {
    return null;
  }
  for (final Categoria categoria in categorias) {
    if (categoria.id == id) {
      return categoria;
    }
  }
  return null;
}

Subcategoria? _buscarSubcategoria(List<Subcategoria> subcategorias, int? id) {
  if (id == null) {
    return null;
  }
  for (final Subcategoria subcategoria in subcategorias) {
    if (subcategoria.id == id) {
      return subcategoria;
    }
  }
  return null;
}

class _Desplegable<T> extends StatelessWidget {
  const _Desplegable({
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
    return InputDecorator(
      decoration: InputDecoration(
        labelText: etiqueta,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: valor,
          hint: const Text('Elegir'),
          items: items
              .map(
                (T item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(texto(item), overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DesplegableOpcional<T> extends StatelessWidget {
  const _DesplegableOpcional({
    required this.etiqueta,
    required this.valor,
    required this.items,
    required this.texto,
    required this.textoVacio,
    required this.onChanged,
  });

  final String etiqueta;
  final T? valor;
  final List<T> items;
  final String Function(T) texto;
  final String textoVacio;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: etiqueta,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          isExpanded: true,
          value: valor,
          items: <DropdownMenuItem<T?>>[
            DropdownMenuItem<T?>(child: Text(textoVacio)),
            for (final T item in items)
              DropdownMenuItem<T?>(
                value: item,
                child: Text(texto(item), overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
