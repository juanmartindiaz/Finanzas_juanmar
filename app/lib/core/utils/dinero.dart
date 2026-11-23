/// Manejo de dinero: centavos enteros, catálogo de monedas y formato es-CO.
///
/// Regla del proyecto: **todos los montos son enteros de centavos**. Aquí se
/// convierten a texto solo para mostrarlos y se leen del texto del usuario solo
/// al guardar.
library;

import 'package:intl/intl.dart';

/// Moneda del catálogo fijo de la aplicación.
class Moneda {
  const Moneda(this.codigo, this.nombre, this.simbolo);

  final String codigo;
  final String nombre;
  final String simbolo;
}

/// Catálogo de monedas principales (ADR-028). COP es la base por defecto.
const List<Moneda> monedasSoportadas = <Moneda>[
  Moneda('COP', 'Peso colombiano', '\$'),
  Moneda('USD', 'Dólar estadounidense', 'US\$'),
  Moneda('EUR', 'Euro', '€'),
  Moneda('GBP', 'Libra esterlina', '£'),
  Moneda('BRL', 'Real brasileño', 'R\$'),
  Moneda('ARS', 'Peso argentino', 'ARS\$'),
  Moneda('MXN', 'Peso mexicano', 'MX\$'),
  Moneda('CLP', 'Peso chileno', 'CLP\$'),
  Moneda('PEN', 'Sol peruano', 'S/'),
];

/// Moneda base por defecto.
const String monedaBasePorDefecto = 'COP';

/// Devuelve la moneda del catálogo o la base si el código no existe.
Moneda monedaPorCodigo(String codigo) {
  for (final Moneda moneda in monedasSoportadas) {
    if (moneda.codigo == codigo) {
      return moneda;
    }
  }
  return monedasSoportadas.first;
}

/// Indica si el código pertenece al catálogo.
bool monedaSoportada(String codigo) =>
    monedasSoportadas.any((Moneda m) => m.codigo == codigo);

/// Formatea un monto en centavos con el estilo pedido: `$ 1.234.567`.
///
/// Si el monto tiene centavos distintos de cero, se muestran dos decimales.
String formatearMonto(int centavos, String codigoMoneda) {
  final Moneda moneda = monedaPorCodigo(codigoMoneda);
  final int decimales = centavos % 100 == 0 ? 0 : 2;
  final NumberFormat formato = NumberFormat.decimalPattern('es_CO')
    ..minimumFractionDigits = decimales
    ..maximumFractionDigits = decimales;
  return '${moneda.simbolo} ${formato.format(centavos / 100)}';
}

/// Formatea un monto con signo explícito (+/−).
String formatearMontoConSigno(int centavos, String codigoMoneda) {
  final String signo = centavos < 0 ? '−' : '+';
  return '$signo ${formatearMonto(centavos.abs(), codigoMoneda)}';
}

/// Formatea una tasa de cambio (factor, no dinero): `4.000` o `0,00025`.
String formatearTasa(double valor) {
  final NumberFormat formato = NumberFormat('#,##0.####', 'es_CO');
  return formato.format(valor);
}

/// Convierte el texto que escribe el usuario a centavos.
///
/// Acepta `18.500`, `18.500,50`, `18500.50`, `$ 1.234.567`, etc. Devuelve
/// `null` si no hay ningún dígito.
int? parsearMonto(String texto) {
  final String limpio = texto.replaceAll(RegExp(r'[^0-9.,]'), '');
  if (limpio.isEmpty) {
    return null;
  }

  final int ultimaComa = limpio.lastIndexOf(',');
  final int ultimoPunto = limpio.lastIndexOf('.');
  int? posicionDecimal;

  if (ultimaComa >= 0 && ultimoPunto >= 0) {
    posicionDecimal = ultimaComa > ultimoPunto ? ultimaComa : ultimoPunto;
  } else if (ultimaComa >= 0) {
    if (limpio.length - ultimaComa - 1 <= 2) {
      posicionDecimal = ultimaComa;
    }
  } else if (ultimoPunto >= 0) {
    if (limpio.length - ultimoPunto - 1 <= 2) {
      posicionDecimal = ultimoPunto;
    }
  }

  final String parteEntera;
  final String parteDecimal;
  if (posicionDecimal != null) {
    parteEntera =
        limpio.substring(0, posicionDecimal).replaceAll(RegExp(r'[.,]'), '');
    parteDecimal = limpio
        .substring(posicionDecimal + 1)
        .replaceAll(RegExp(r'[.,]'), '');
  } else {
    parteEntera = limpio.replaceAll(RegExp(r'[.,]'), '');
    parteDecimal = '';
  }

  final int? enteros = int.tryParse(parteEntera.isEmpty ? '0' : parteEntera);
  if (enteros == null) {
    return null;
  }
  final String decimales = parteDecimal.padRight(2, '0').substring(0, 2);
  final int? centavos = int.tryParse(decimales);
  if (centavos == null) {
    return null;
  }
  return enteros * 100 + centavos;
}
