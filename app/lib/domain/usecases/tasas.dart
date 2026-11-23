/// Conversión de monedas con tasas manuales.
library;

import '../../core/utils/fechas.dart';
import '../entities/dashboard.dart';
import '../entities/tasa_cambio.dart';

/// Devuelve la tasa vigente (la más reciente no futura) de `origen` a
/// `destino`, o `null` si no hay ninguna. Si no existe el par directo, intenta
/// el inverso (1 / valor).
double? tasaVigente(
  List<TasaCambio> tasas,
  String origen,
  String destino, {
  DateTime? hoy,
}) {
  if (origen == destino) {
    return 1;
  }
  final String fechaHoy = fechaIso(hoy ?? DateTime.now());

  TasaCambio? directa;
  for (final TasaCambio tasa in tasas) {
    if (tasa.monedaOrigen == origen &&
        tasa.monedaDestino == destino &&
        tasa.fecha.compareTo(fechaHoy) <= 0) {
      if (directa == null || tasa.fecha.compareTo(directa.fecha) > 0) {
        directa = tasa;
      }
    }
  }
  if (directa != null) {
    return directa.valor;
  }

  TasaCambio? inversa;
  for (final TasaCambio tasa in tasas) {
    if (tasa.monedaOrigen == destino &&
        tasa.monedaDestino == origen &&
        tasa.fecha.compareTo(fechaHoy) <= 0) {
      if (inversa == null || tasa.fecha.compareTo(inversa.fecha) > 0) {
        inversa = tasa;
      }
    }
  }
  if (inversa != null && inversa.valor > 0) {
    return 1 / inversa.valor;
  }

  return null;
}

/// Consolida los saldos en la moneda base.
///
/// Si una cuenta está en una moneda sin tasa disponible, no se inventa un
/// valor: se omite del total y se informa en `monedasSinTasa` (ADR-006).
Consolidado consolidar({
  required List<SaldoCuenta> saldos,
  required List<TasaCambio> tasas,
  required String monedaBase,
  DateTime? hoy,
}) {
  int total = 0;
  final List<String> sinTasa = <String>[];

  for (final SaldoCuenta saldo in saldos) {
    final String moneda = saldo.cuenta.moneda;
    if (moneda == monedaBase) {
      total += saldo.saldoCentavos;
      continue;
    }
    final double? tasa = tasaVigente(tasas, moneda, monedaBase, hoy: hoy);
    if (tasa == null) {
      if (!sinTasa.contains(moneda)) {
        sinTasa.add(moneda);
      }
      continue;
    }
    total += (saldo.saldoCentavos * tasa).round();
  }

  return Consolidado(
    monedaBase: monedaBase,
    totalCentavos: total,
    monedasSinTasa: List<String>.unmodifiable(sinTasa),
  );
}
