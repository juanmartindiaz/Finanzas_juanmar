/// Resultados derivados para el dashboard.
library;

import 'cuenta.dart';
import 'transaccion.dart';

/// Saldo calculado de una cuenta (saldo inicial + movimientos).
class SaldoCuenta {
  const SaldoCuenta({required this.cuenta, required this.saldoCentavos});

  final Cuenta cuenta;
  final int saldoCentavos;
}

/// Total por moneda.
class TotalPorMoneda {
  const TotalPorMoneda({required this.moneda, required this.centavos});

  final String moneda;
  final int centavos;
}

/// Total consolidado en la moneda base del usuario.
class Consolidado {
  const Consolidado({
    required this.monedaBase,
    required this.totalCentavos,
    required this.monedasSinTasa,
  });

  final String monedaBase;
  final int totalCentavos;

  /// Monedas de cuentas que no se pudieron convertir por falta de tasa.
  final List<String> monedasSinTasa;

  bool get completo => monedasSinTasa.isEmpty;
}

/// Todo lo que necesita el dashboard para pintarse.
class DashboardData {
  const DashboardData({
    required this.saldos,
    required this.subtotales,
    required this.consolidado,
    required this.recientes,
  });

  final List<SaldoCuenta> saldos;
  final List<TotalPorMoneda> subtotales;
  final Consolidado consolidado;
  final List<Transaccion> recientes;
}
