/// Construcción de los datos del dashboard.
library;

import '../entities/cuenta.dart';
import '../entities/dashboard.dart';
import '../entities/tasa_cambio.dart';
import '../entities/transaccion.dart';
import 'saldos.dart';
import 'tasas.dart';

/// Calcula saldos por cuenta, subtotales por moneda, total consolidado y las
/// últimas transacciones.
DashboardData construirDashboard({
  required List<Cuenta> cuentas,
  required List<Transaccion> transacciones,
  required List<TasaCambio> tasas,
  required String monedaBase,
  int limiteRecientes = 10,
  DateTime? ahora,
}) {
  final List<SaldoCuenta> saldos = calcularSaldos(cuentas, transacciones);
  final List<Transaccion> ordenadas = List<Transaccion>.from(transacciones)
    ..sort(
      (Transaccion a, Transaccion b) => b.fechaHora.compareTo(a.fechaHora),
    );

  return DashboardData(
    saldos: saldos,
    subtotales: subtotalesPorMoneda(saldos),
    consolidado: consolidar(
      saldos: saldos,
      tasas: tasas,
      monedaBase: monedaBase,
      hoy: ahora,
    ),
    recientes: ordenadas.take(limiteRecientes).toList(),
  );
}
