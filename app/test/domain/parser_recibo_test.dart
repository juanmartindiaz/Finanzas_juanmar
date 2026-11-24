import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_finanzas/domain/entities/captura.dart';
import 'package:gestor_finanzas/domain/entities/categoria.dart';
import 'package:gestor_finanzas/domain/parsers/parser_recibo.dart';

import '../support/ayudas.dart';

List<Categoria> _categorias() => <Categoria>[
      crearCategoria(id: 1, nombre: 'Alimentación'),
      crearCategoria(id: 2, nombre: 'Transporte'),
      crearCategoria(id: 3, nombre: 'Salud'),
      crearCategoria(id: 4, nombre: 'Otros'),
      crearCategoria(
        id: 5,
        nombre: 'Salario',
        naturaleza: NaturalezaCategoria.ingreso,
      ),
    ];

PropuestaRecibo _parse(String texto) => parsearRecibo(
      texto,
      fechaRecepcion: DateTime(2026, 11, 24, 18, 30),
      categorias: _categorias(),
    );

void main() {
  test('recibo con TOTAL y comercio de supermercado', () {
    final p = _parse('''
SUPERMERCADO ÉXITO
NIT 890.900.608-9
Fecha: 24/11/2026
Leche 4.500
Pan 3.000
TOTAL 7.500
''');
    expect(p.montoCentavos, 750000);
    expect(p.comercio, 'SUPERMERCADO ÉXITO');
    expect(p.categoriaId, 1);
    expect(p.confianza, ConfianzaPropuesta.alta);
    expect(p.fecha, '2026-11-24');
  });

  test('TOTAL A PAGAR con IVA y propina prioriza el total', () {
    final p = _parse('''
RESTAURANTE EL BUEN SABOR
Subtotal 50.000
IVA 9.500
Propina 5.000
TOTAL A PAGAR 64.500
''');
    expect(p.montoCentavos, 6450000);
    expect(p.categoriaId, 1);
  });

  test('sin palabra TOTAL usa el número más grande', () {
    final p = _parse('''
TIENDA LA ESQUINA
24/11/2026
Producto A 12.000
Producto B 8.500
85.000
''');
    expect(p.montoCentavos, 8500000);
    expect(p.confianza, ConfianzaPropuesta.media);
  });

  test('ignora teléfonos y fechas', () {
    final p = _parse('''
FARMACIA SAN JORGE
Tel: 601 555 1234
Fecha 24/11/2026
Medicamento 25.000
TOTAL 25.000
''');
    expect(p.montoCentavos, 2500000);
    expect(p.categoriaId, 3);
  });

  test('sin monto devuelve faltante y confianza baja', () {
    final p = _parse('''
PANADERÍA
Gracias por su compra
''');
    expect(p.montoCentavos, isNull);
    expect(p.faltantes, contains('monto'));
    expect(p.confianza, ConfianzaPropuesta.baja);
  });

  test('sin categoría reconocible usa Otros y lo marca', () {
    final p = _parse('''
TIENDA XYZ
TOTAL 10.000
''');
    expect(p.montoCentavos, 1000000);
    expect(p.categoriaNombre, 'Otros');
    expect(p.faltantes, contains('categoría'));
  });

  test('fecha en formato ISO', () {
    final p = _parse('''
TIENDA
2026-11-20
TOTAL 15.000
''');
    expect(p.fecha, '2026-11-20');
  });

  test('sin fecha usa la fecha de recepción', () {
    final p = _parse('TIENDA\nTOTAL 15.000');
    expect(p.fecha, '2026-11-24');
  });

  test('monto con centavos', () {
    final p = _parse('TIENDA\nTOTAL 18.500,50');
    expect(p.montoCentavos, 1850050);
  });

  test('monto con puntos de miles sin decimales', () {
    final p = _parse('TIENDA\nTOTAL 1.234.567');
    expect(p.montoCentavos, 123456700);
  });

  test('propina sin total no se toma como monto final', () {
    final p = _parse('''
RESTAURANTE
Consumo 40.000
Propina 4.000
''');
    // Sin línea TOTAL, el mayor número es el consumo.
    expect(p.montoCentavos, 4000000);
  });

  test('detecta comercio de transporte', () {
    final p = _parse('''
UBER TRIP
TOTAL 12.300
''');
    expect(p.categoriaId, 2);
    expect(p.montoCentavos, 1230000);
  });

  test('no confunde el NIT con el total', () {
    final p = _parse('''
SUPERMERCADO
NIT 890900608-9
TOTAL 30.000
''');
    expect(p.montoCentavos, 3000000);
  });

  test('varias líneas TOTAL elige la última', () {
    final p = _parse('''
TIENDA
TOTAL 10.000
TOTAL A PAGAR 25.000
''');
    expect(p.montoCentavos, 2500000);
  });

  test('texto vacío devuelve todo como faltante', () {
    final p = _parse('');
    expect(p.montoCentavos, isNull);
    expect(p.comercio, isNull);
    expect(p.confianza, ConfianzaPropuesta.baja);
    expect(p.faltantes, containsAll(<String>['monto', 'comercio']));
  });
}
