import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_finanzas/domain/entities/dashboard.dart';
import 'package:gestor_finanzas/domain/entities/tasa_cambio.dart';
import 'package:gestor_finanzas/domain/usecases/dashboard.dart';
import 'package:gestor_finanzas/domain/usecases/saldos.dart';
import 'package:gestor_finanzas/domain/usecases/tasas.dart';

import '../support/ayudas.dart';

void main() {
  group('multimoneda', () {
    test('subtotales por moneda suman cuentas de la misma moneda', () {
      final saldos = <SaldoCuenta>[
        SaldoCuenta(
          cuenta: crearCuenta(id: 1, moneda: 'COP'),
          saldoCentavos: 1000000,
        ),
        SaldoCuenta(
          cuenta: crearCuenta(id: 2, nombre: 'Ahorro', moneda: 'COP'),
          saldoCentavos: 500000,
        ),
        SaldoCuenta(
          cuenta: crearCuenta(id: 3, nombre: 'Dólares', moneda: 'USD'),
          saldoCentavos: 5000,
        ),
      ];

      final subtotales = subtotalesPorMoneda(saldos);

      expect(subtotales, hasLength(2));
      expect(
        subtotales.firstWhere((elemento) => elemento.moneda == 'COP').centavos,
        1500000,
      );
      expect(
        subtotales.firstWhere((elemento) => elemento.moneda == 'USD').centavos,
        5000,
      );
    });

    test('consolida en COP con la tasa manual más reciente', () {
      final saldos = <SaldoCuenta>[
        SaldoCuenta(
          cuenta: crearCuenta(id: 1, moneda: 'COP'),
          saldoCentavos: 1000000,
        ),
        SaldoCuenta(
          cuenta: crearCuenta(id: 2, nombre: 'Dólares', moneda: 'USD'),
          saldoCentavos: 5000,
        ),
      ];
      final tasas = <TasaCambio>[
        crearTasa(fecha: '2026-11-20', valor: 3900),
        crearTasa(id: 2, fecha: '2026-11-23', valor: 4000),
      ];

      final consolidado = consolidar(
        saldos: saldos,
        tasas: tasas,
        monedaBase: 'COP',
        hoy: DateTime(2026, 11, 23),
      );

      // 10.000 COP + 50 USD * 4.000 = 210.000 COP (en centavos)
      expect(consolidado.totalCentavos, 21000000);
      expect(consolidado.completo, isTrue);
      expect(consolidado.monedasSinTasa, isEmpty);
    });

    test('ignora tasas futuras', () {
      final saldos = <SaldoCuenta>[
        SaldoCuenta(
          cuenta: crearCuenta(id: 1, moneda: 'USD'),
          saldoCentavos: 5000,
        ),
      ];
      final tasas = <TasaCambio>[
        crearTasa(fecha: '2026-11-24', valor: 5000),
      ];

      final consolidado = consolidar(
        saldos: saldos,
        tasas: tasas,
        monedaBase: 'COP',
        hoy: DateTime(2026, 11, 23),
      );

      expect(consolidado.totalCentavos, 0);
      expect(consolidado.monedasSinTasa, <String>['USD']);
      expect(consolidado.completo, isFalse);
    });

    test('si no hay tasa, la moneda se marca como sin convertir', () {
      final saldos = <SaldoCuenta>[
        SaldoCuenta(
          cuenta: crearCuenta(id: 1, moneda: 'COP'),
          saldoCentavos: 1000000,
        ),
        SaldoCuenta(
          cuenta: crearCuenta(id: 2, nombre: 'Euros', moneda: 'EUR'),
          saldoCentavos: 2000,
        ),
      ];

      final consolidado = consolidar(
        saldos: saldos,
        tasas: const <TasaCambio>[],
        monedaBase: 'COP',
        hoy: DateTime(2026, 11, 23),
      );

      expect(consolidado.totalCentavos, 1000000);
      expect(consolidado.monedasSinTasa, <String>['EUR']);
    });

    test('usa la tasa inversa cuando solo existe el par contrario', () {
      final tasa = tasaVigente(
        <TasaCambio>[crearTasa(origen: 'COP', destino: 'USD', valor: 0.00025)],
        'USD',
        'COP',
        hoy: DateTime(2026, 11, 23),
      );

      expect(tasa, closeTo(4000, 0.0001));
    });

    test('el dashboard ordena los últimos movimientos y respeta el límite', () {
      final cuentas = <dynamic>[
        crearCuenta(id: 1, saldoInicialCentavos: 100000),
      ];
      final transacciones = <dynamic>[
        crearTransaccion(id: 1, fechaHora: 1000, montoCentavos: 100),
        crearTransaccion(id: 2, fechaHora: 3000, montoCentavos: 200),
        crearTransaccion(id: 3, fechaHora: 2000, montoCentavos: 300),
      ];

      final data = construirDashboard(
        cuentas: cuentas.cast(),
        transacciones: transacciones.cast(),
        tasas: const <TasaCambio>[],
        monedaBase: 'COP',
        limiteRecientes: 2,
        ahora: DateTime(2026, 11, 23),
      );

      expect(data.recientes.map((elemento) => elemento.id), <int>[2, 3]);
      expect(data.saldos, hasLength(1));
      expect(data.consolidado.totalCentavos, 100000 - 600);
    });
  });
}
