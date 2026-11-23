import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_finanzas/domain/entities/transaccion.dart';
import 'package:gestor_finanzas/domain/usecases/saldos.dart';

import '../support/ayudas.dart';

void main() {
  test('una transferencia no altera los totales de ingresos ni de gastos', () {
    final transacciones = <Transaccion>[
      crearTransaccion(
        id: 1,
        tipo: TipoTransaccion.ingreso,
        montoCentavos: 5000000,
      ),
      crearTransaccion(
        id: 2,
        tipo: TipoTransaccion.gasto,
        montoCentavos: 1850000,
      ),
      crearTransaccion(
        id: 3,
        tipo: TipoTransaccion.transferencia,
        montoCentavos: 3000000,
        cuentaDestinoId: 2,
        montoDestinoCentavos: 3000000,
        monedaDestino: 'COP',
      ),
    ];

    final totales = calcularTotalesAgregados(transacciones);

    expect(totales.ingresosCentavos, 5000000);
    expect(totales.gastosCentavos, 1850000);
    expect(totales.netoCentavos, 3150000);
  });

  test('el patrimonio total no cambia con una transferencia entre cuentas', () {
    final cuentaA = crearCuenta(id: 1, saldoInicialCentavos: 1000000);
    final cuentaB = crearCuenta(id: 2, nombre: 'Nequi', saldoInicialCentavos: 0);
    final transferencia = crearTransaccion(
      tipo: TipoTransaccion.transferencia,
      montoCentavos: 400000,
      cuentaDestinoId: 2,
      montoDestinoCentavos: 400000,
      monedaDestino: 'COP',
    );

    final sinTransferencia =
        saldoDeCuenta(cuentaA, <Transaccion>[]) +
            saldoDeCuenta(cuentaB, <Transaccion>[]);
    final conTransferencia =
        saldoDeCuenta(cuentaA, <Transaccion>[transferencia]) +
            saldoDeCuenta(cuentaB, <Transaccion>[transferencia]);

    expect(conTransferencia, sinTransferencia);
  });
}
