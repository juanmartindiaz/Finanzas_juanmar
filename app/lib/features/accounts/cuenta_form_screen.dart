import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/dinero.dart';
import '../../data/providers.dart';
import '../../domain/entities/cuenta.dart';
import '../shared/vistas.dart';

/// Formulario para crear o editar una cuenta.
class CuentaFormScreen extends ConsumerStatefulWidget {
  const CuentaFormScreen({super.key, this.cuentaId});

  final int? cuentaId;

  @override
  ConsumerState<CuentaFormScreen> createState() => _CuentaFormScreenState();
}

class _CuentaFormScreenState extends ConsumerState<CuentaFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _saldoCtrl = TextEditingController(text: '0');
  final TextEditingController _notaCtrl = TextEditingController();

  TipoCuenta _tipo = TipoCuenta.efectivo;
  String _moneda = monedaBasePorDefecto;
  bool _activa = true;
  bool _cargando = false;
  bool _guardando = false;
  String? _error;

  bool get _esEdicion => widget.cuentaId != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      _cargar();
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _saldoCtrl.dispose();
    _notaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final Cuenta? cuenta =
        await ref.read(cuentasRepoProvider).obtener(widget.cuentaId!);
    if (!mounted) {
      return;
    }
    setState(() {
      _cargando = false;
      if (cuenta == null) {
        _error = 'La cuenta no existe.';
        return;
      }
      _nombreCtrl.text = cuenta.nombre;
      _tipo = cuenta.tipo;
      _moneda = cuenta.moneda;
      _activa = cuenta.activa;
      _notaCtrl.text = cuenta.nota ?? '';
      _saldoCtrl.text = formatearMonto(
        cuenta.saldoInicialCentavos,
        cuenta.moneda,
      );
    });
  }

  int? _saldoEnCentavos() {
    final String texto = _saldoCtrl.text.trim();
    if (texto.isEmpty) {
      return 0;
    }
    final bool negativo = texto.startsWith('-') || texto.startsWith('−');
    final int? valor = parsearMonto(texto);
    if (valor == null) {
      return null;
    }
    return negativo ? -valor : valor;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final int? saldo = _saldoEnCentavos();
    if (saldo == null) {
      setState(() => _error = 'El saldo inicial no es un número válido.');
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      final repo = ref.read(cuentasRepoProvider);
      if (_esEdicion) {
        await repo.actualizar(
          id: widget.cuentaId!,
          nombre: _nombreCtrl.text.trim(),
          tipo: _tipo,
          saldoInicialCentavos: saldo,
          moneda: _moneda,
          activa: _activa,
          nota: _notaCtrl.text.trim().isEmpty
              ? null
              : _notaCtrl.text.trim(),
        );
      } else {
        await repo.crear(
          nombre: _nombreCtrl.text.trim(),
          tipo: _tipo,
          saldoInicialCentavos: saldo,
          moneda: _moneda,
          activa: _activa,
          nota: _notaCtrl.text.trim().isEmpty
              ? null
              : _notaCtrl.text.trim(),
        );
      }
      if (!mounted) {
        return;
      }
      mostrarAviso(
        context,
        _esEdicion ? 'Cuenta actualizada.' : 'Cuenta creada.',
      );
      context.pop();
    } on Exception catch (e) {
      setState(() => _error = 'No se pudo guardar: $e');
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar cuenta' : 'Nueva cuenta'),
      ),
      body: _cargando
          ? const VistaCargando()
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la cuenta',
                      hintText: 'Ej.: Efectivo, Cuenta bancaria',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (String? valor) {
                      final String texto = (valor ?? '').trim();
                      if (texto.isEmpty) {
                        return 'Escribe un nombre.';
                      }
                      if (texto.length > 60) {
                        return 'Máximo 60 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _Desplegable<TipoCuenta>(
                    etiqueta: 'Tipo de cuenta',
                    valor: _tipo,
                    items: TipoCuenta.values,
                    texto: (TipoCuenta tipo) => tipo.etiqueta,
                    onChanged: (TipoCuenta? valor) {
                      if (valor != null) {
                        setState(() => _tipo = valor);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _saldoCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Saldo inicial',
                      helperText: 'Puede ser negativo (por ejemplo, una '
                          'tarjeta de crédito).',
                      suffixText: _moneda,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Desplegable<String>(
                    etiqueta: 'Moneda',
                    valor: _moneda,
                    items: monedasSoportadas
                        .map((Moneda moneda) => moneda.codigo)
                        .toList(),
                    texto: (String codigo) =>
                        '$codigo — ${monedaPorCodigo(codigo).nombre}',
                    onChanged: (String? valor) {
                      if (valor != null) {
                        setState(() => _moneda = valor);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _activa,
                    onChanged: (bool valor) => setState(() => _activa = valor),
                    title: const Text('Cuenta activa'),
                    subtitle: const Text(
                      'Si la desactivas, no aparecerá al registrar movimientos.',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nota (opcional)',
                    ),
                    maxLines: 2,
                    maxLength: 500,
                  ),
                  if (_error != null) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
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
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_guardando ? 'Guardando…' : 'Guardar cuenta'),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Desplegable simple con etiqueta, sin depender de la API de formularios.
class _Desplegable<T> extends StatelessWidget {
  const _Desplegable({
    required this.etiqueta,
    required this.valor,
    required this.items,
    required this.texto,
    required this.onChanged,
  });

  final String etiqueta;
  final T valor;
  final List<T> items;
  final String Function(T) texto;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: etiqueta,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: valor,
          items: items
              .map(
                (T item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(texto(item)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
