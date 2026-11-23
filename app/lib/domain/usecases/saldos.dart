/// Cálculo de saldos y totales.
///
/// Los saldos **nunca** se guardan: se derivan de la cuenta y de sus
/// transacciones vigentes (DATA_MODEL §6.1).
library;

import '../entities/cuenta.dart';
import '../entities/dashboard.dart';
import '../entities/transaccion.dart';

/// Saldo de una cuenta: inicial + ingresos − gastos ± transferencias.
///
/// Las transferencias no son ingreso ni gasto: solo mueven saldo.
int saldoDeCuenta(Cuenta cuenta, Iterable<Transaccion> transacciones) {
  int saldo = cuenta.saldoInicialCentavos;

  for (final Transaccion transaccion in transacciones) {
    final bool saleDeLaCuenta = transaccion.cuentaId == cuenta.id;
    if (saleDeLaCuenta) {
      switch (transaccion.tipo) {
        case TipoTransaccion.ingreso:
          saldo += transaccion.montoCentavos;
        case TipoTransaccion.gasto:
          saldo -= transaccion.montoCentavos;
        case TipoTransaccion.transferencia:
          saldo -= transaccion.montoCentavos;
      }
    }

    final bool entraALaCuenta = transaccion.esTransferencia &&
        transaccion.cuentaDestinoId == cuenta.id;
    if (entraALaCuenta) {
      saldo += transaccion.montoDestinoEfectivo;
    }
  }

  return saldo;
}

/// Saldos de todas las cuentas recibidas.
List<SaldoCuenta> calcularSaldos(
  List<Cuenta> cuentas,
  List<Transaccion> transacciones,
) {
  return cuentas
      .map(
        (Cuenta cuenta) => SaldoCuenta(
          cuenta: cuenta,
          saldoCentavos: saldoDeCuenta(cuenta, transacciones),
        ),
      )
      .toList();
}

/// Ingresos y gastos agregados (las transferencias no cuentan).
class TotalesAgregados {
  const TotalesAgregados({
    required this.ingresosCentavos,
    required this.gastosCentavos,
  });

  final int ingresosCentavos;
  final int gastosCentavos;

  int get netoCentavos => ingresosCentavos - gastosCentavos;
}

/// Suma ingresos y gastos por separado, ignorando transferencias.
TotalesAgregados calcularTotalesAgregados(
  Iterable<Transaccion> transacciones,
) {
  int ingresos = 0;
  int gastos = 0;
  for (final Transaccion transaccion in transacciones) {
    switch (transaccion.tipo) {
      case TipoTransaccion.ingreso:
        ingresos += transaccion.montoCentavos;
      case TipoTransaccion.gasto:
        gastos += transaccion.montoCentavos;
      case TipoTransaccion.transferencia:
        break;
    }
  }
  return TotalesAgregados(
    ingresosCentavos: ingresos,
    gastosCentavos: gastos,
  );
}

/// Subtotales por moneda del saldo de las cuentas.
List<TotalPorMoneda> subtotalesPorMoneda(List<SaldoCuenta> saldos) {
  final Map<String, int> acumulado = <String, int>{};
  for (final SaldoCuenta saldo in saldos) {
    final String moneda = saldo.cuenta.moneda;
    acumulado[moneda] = (acumulado[moneda] ?? 0) + saldo.saldoCentavos;
  }
  final List<String> monedas = acumulado.keys.toList()..sort();
  return monedas
      .map(
        (String moneda) =>
            TotalPorMoneda(moneda: moneda, centavos: acumulado[moneda] ?? 0),
      )
      .toList();
}
