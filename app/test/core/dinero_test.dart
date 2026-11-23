import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_finanzas/core/utils/dinero.dart';

void main() {
  group('parsearMonto', () {
    test('lee miles con punto', () {
      expect(parsearMonto('18.500'), 1850000);
      expect(parsearMonto(r'$ 1.234.567'), 123456700);
    });

    test('lee decimales con coma o punto', () {
      expect(parsearMonto('18.500,50'), 1850050);
      expect(parsearMonto('18500.50'), 1850050);
      expect(parsearMonto('0,50'), 50);
    });

    test('devuelve null si no hay dígitos', () {
      expect(parsearMonto(''), isNull);
      expect(parsearMonto('abc'), isNull);
    });
  });

  group('formatearMonto', () {
    test('usa punto de miles y sin decimales cuando son cero', () {
      expect(formatearMonto(1850000, 'COP'), r'$ 18.500');
      expect(formatearMonto(123456700, 'COP'), r'$ 1.234.567');
    });

    test('muestra dos decimales cuando hay centavos', () {
      expect(formatearMonto(1850050, 'COP'), r'$ 18.500,50');
    });

    test('usa el símbolo de cada moneda', () {
      expect(formatearMonto(5000, 'USD'), r'US$ 50');
    });
  });

  test('el catálogo contiene las monedas principales', () {
    for (final String codigo in <String>['COP', 'USD', 'EUR', 'GBP', 'BRL']) {
      expect(monedaSoportada(codigo), isTrue);
      expect(monedaPorCodigo(codigo).codigo, codigo);
    }
    expect(monedaSoportada('XYZ'), isFalse);
  });
}
