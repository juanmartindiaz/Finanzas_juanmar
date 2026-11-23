import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_finanzas/domain/entities/transaccion.dart';
import 'package:gestor_finanzas/domain/usecases/saldos.dart';

import '../support/ayudas.dart';

void main() {
  group('saldo de una cuenta', () {
    test('suma ingresos y resta gastos', () {
      final cuenta = crearCuenta(saldoInicialCentavos: 20000000);
      final transacciones = <Transaccion>[
        crearTransaccion(tipo: TipoTransaccion.ingreso, montoCentavos: 5000000),
        crearTransaccion(
          id: 2,
          tipo: TipoTransaccion.gasto,
          montoCentavos: 1850000,
        ),
      ];

      expect(saldoDeCuenta(cuenta, transacciones), 23150000);
    });

    test('resta transferencias enviadas y suma las recibidas', () {
      final origen = crearCuenta(id: 1, saldoInicialCentavos: 20000000);
      final destino = crearCuenta(id: 2, nombre: 'Nequi', saldoInicialCentavos: 0);
      final transferencia = crearTransaccion(
        tipo: TipoTransaccion.transferencia,
        montoCentavos: 3000000,
        cuentaDestinoId: 2,
        montoDestinoCentavos: 3000000,
        monedaDestino: 'COP',
      );

      expect(saldoDeCuenta(origen, <Transaccion>[transferencia]), 17000000);
      expect(saldoDeCuenta(destino, <Transaccion>[transferencia]), 3000000);
    });

    test('transferencia entre monedas usa el monto de destino', () {
      final origen = crearCuenta(id: 1, moneda: 'COP', saldoInicialCentavos: 0);
      final destino = crearCuenta(
        id: 2,
        nombre: 'Dólares',
        moneda: 'USD',
        saldoInicialCentavos: 0,
      );
      final transferencia = crearTransaccion(
        tipo: TipoTransaccion.transferencia,
        montoCentavos: 40000000,
        moneda: 'COP',
        cuentaDestinoId: 2,
        montoDestinoCentavos: 1000000,
        monedaDestino: 'USD',
        tasaCambio: 0.025,
      );

      expect(saldoDeCuenta(origen, <Transaccion>[transferencia]), -40000000);
      expect(saldoDeCuenta(destino, <Transaccion>[transferencia]), 1000000);
    });

    test('una transacción borrada (fuera de la lista) no afecta el saldo', () {
      final cuenta = crearCuenta(saldoInicialCentavos: 1000000);
      final gasto = crearTransaccion(montoCentavos: 100000);

      expect(saldoDeCuenta(cuenta, <Transaccion>[gasto]), 900000);
      // Simula el borrado lógico: el repositorio deja de devolverla.
      expect(saldoDeCuenta(cuenta, <Transaccion>[]), 1000000);
    });

    test('editar un monto recalcula el saldo', () {
      final cuenta = crearCuenta(saldoInicialCentavos: 1000000);
      final gasto = crearTransaccion(montoCentavos: 100000);
      final gastoEditado = crearTransaccion(montoCentavos: 250000);

      expect(saldoDeCuenta(cuenta, <Transaccion>[gasto]), 900000);
      expect(saldoDeCuenta(cuenta, <Transaccion>[gastoEditado]), 750000);
    });

    test('los movimientos de otra cuenta no cambian el saldo', () {
      final cuenta = crearCuenta(id: 1, saldoInicialCentavos: 500000);
      final ajeno = crearTransaccion(
        id: 9,
        cuentaId: 2,
        montoCentavos: 999999,
      );

      expect(saldoDeCuenta(cuenta, <Transaccion>[ajeno]), 500000);
    });

    test('calcularSaldos devuelve una entrada por cuenta', () {
      final cuentas = <dynamic>[
        crearCuenta(id: 1, saldoInicialCentavos: 100000),
        crearCuenta(id: 2, nombre: 'Banco', saldoInicialCentavos: 200000),
      ];
      final saldos = calcularSaldos(cuentas.cast(), <Transaccion>[]);

      expect(saldos, hasLength(2));
      expect(saldos[0].saldoCentavos, 100000);
      expect(saldos[1].saldoCentavos, 200000);
    });
  });
}
