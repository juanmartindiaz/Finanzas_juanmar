/// Validación de una transacción antes de guardarla.
///
/// Es lógica pura: la usan el formulario y las pruebas.
library;

import '../../core/utils/dinero.dart';
import '../entities/categoria.dart';
import '../entities/cuenta.dart';
import '../entities/subcategoria.dart';
import '../entities/transaccion.dart';

/// Valida todos los campos de una transacción y devuelve los errores en
/// español (lista vacía = válida).
List<String> validarTransaccion({
  required TipoTransaccion tipo,
  required int? montoCentavos,
  required String moneda,
  required int? cuentaId,
  required int? cuentaDestinoId,
  required int? montoDestinoCentavos,
  required String? monedaDestino,
  required int? categoriaId,
  required int? subcategoriaId,
  required DateTime fechaHora,
  required String? nota,
  required List<Cuenta> cuentas,
  required List<Categoria> categorias,
  required List<Subcategoria> subcategorias,
  bool permitirFechaFutura = false,
  DateTime? ahora,
}) {
  final List<String> errores = <String>[];

  if (montoCentavos == null || montoCentavos <= 0) {
    errores.add('El monto debe ser mayor que cero.');
  }
  if (!monedaSoportada(moneda)) {
    errores.add('La moneda no está en el catálogo.');
  }
  if (nota != null && nota.length > 1000) {
    errores.add('La nota no puede superar 1.000 caracteres.');
  }

  final Cuenta? cuentaOrigen = _buscarCuenta(cuentas, cuentaId);
  if (cuentaOrigen == null) {
    errores.add('Elige la cuenta del movimiento.');
  }

  if (tipo == TipoTransaccion.transferencia) {
    _validarTransferencia(
      errores: errores,
      cuentaOrigen: cuentaOrigen,
      cuentas: cuentas,
      cuentaDestinoId: cuentaDestinoId,
      montoCentavos: montoCentavos,
      montoDestinoCentavos: montoDestinoCentavos,
      moneda: moneda,
      monedaDestino: monedaDestino,
      categoriaId: categoriaId,
    );
  } else {
    _validarIngresoGasto(
      errores: errores,
      tipo: tipo,
      cuentaDestinoId: cuentaDestinoId,
      montoDestinoCentavos: montoDestinoCentavos,
      categoriaId: categoriaId,
      subcategoriaId: subcategoriaId,
      categorias: categorias,
      subcategorias: subcategorias,
    );
  }

  final DateTime momento = ahora ?? DateTime.now();
  final DateTime limiteFuturo = momento.add(const Duration(minutes: 1));
  if (!permitirFechaFutura && fechaHora.isAfter(limiteFuturo)) {
    errores.add('La fecha no puede ser futura (confirma para continuar).');
  }

  return errores;
}

void _validarTransferencia({
  required List<String> errores,
  required Cuenta? cuentaOrigen,
  required List<Cuenta> cuentas,
  required int? cuentaDestinoId,
  required int? montoCentavos,
  required int? montoDestinoCentavos,
  required String moneda,
  required String? monedaDestino,
  required int? categoriaId,
}) {
  final Cuenta? cuentaDestino = _buscarCuenta(cuentas, cuentaDestinoId);
  if (cuentaDestino == null) {
    errores.add('Elige la cuenta de destino.');
  } else if (cuentaDestino.id == cuentaOrigen?.id) {
    errores.add('La cuenta de destino debe ser distinta a la de origen.');
  }

  if (montoDestinoCentavos == null || montoDestinoCentavos <= 0) {
    errores.add('El monto de destino debe ser mayor que cero.');
  }
  if (monedaDestino == null || !monedaSoportada(monedaDestino)) {
    errores.add('La moneda de destino no está en el catálogo.');
  } else if (cuentaDestino != null && cuentaDestino.moneda != monedaDestino) {
    errores.add(
      'La moneda de destino debe ser la moneda de la cuenta de destino.',
    );
  }

  final bool mismaMoneda = monedaDestino != null && monedaDestino == moneda;
  if (mismaMoneda &&
      montoCentavos != null &&
      montoDestinoCentavos != null &&
      montoCentavos != montoDestinoCentavos) {
    errores.add(
      'Si las monedas son iguales, el monto de destino debe ser igual al de '
      'origen.',
    );
  }
  if (categoriaId != null) {
    errores.add('Una transferencia no lleva categoría.');
  }
}

void _validarIngresoGasto({
  required List<String> errores,
  required TipoTransaccion tipo,
  required int? cuentaDestinoId,
  required int? montoDestinoCentavos,
  required int? categoriaId,
  required int? subcategoriaId,
  required List<Categoria> categorias,
  required List<Subcategoria> subcategorias,
}) {
  if (cuentaDestinoId != null) {
    errores.add('Solo las transferencias llevan cuenta de destino.');
  }
  if (montoDestinoCentavos != null) {
    errores.add('Solo las transferencias llevan monto de destino.');
  }

  final Categoria? categoria = _buscarCategoria(categorias, categoriaId);
  if (categoria == null) {
    errores.add('Elige una categoría.');
  } else {
    final NaturalezaCategoria requerida = tipo == TipoTransaccion.gasto
        ? NaturalezaCategoria.gasto
        : NaturalezaCategoria.ingreso;
    if (categoria.naturaleza != requerida &&
        categoria.naturaleza != NaturalezaCategoria.ambos) {
      errores.add('La categoría no sirve para este tipo de movimiento.');
    }
  }

  if (subcategoriaId != null) {
    final Subcategoria? subcategoria = _buscarSubcategoria(
      subcategorias,
      subcategoriaId,
    );
    if (subcategoria == null) {
      errores.add('La subcategoría no existe.');
    } else if (categoria != null &&
        subcategoria.categoriaId != categoria.id) {
      errores.add('La subcategoría no pertenece a la categoría elegida.');
    }
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
