import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_finanzas/domain/entities/captura.dart';
import 'package:gestor_finanzas/domain/entities/categoria.dart';
import 'package:gestor_finanzas/domain/entities/etiqueta.dart';
import 'package:gestor_finanzas/domain/entities/subcategoria.dart';
import 'package:gestor_finanzas/domain/entities/transaccion.dart';
import 'package:gestor_finanzas/domain/parsers/parser_texto.dart';

import '../support/ayudas.dart';

late ContextoParser contexto;

ContextoParser construirContexto({int? cuentaPorDefecto = 1}) {
  return ContextoParser(
    categorias: <Categoria>[
      crearCategoria(id: 1, nombre: 'Alimentación'),
      crearCategoria(id: 2, nombre: 'Transporte'),
      crearCategoria(id: 3, nombre: 'Ropa'),
      crearCategoria(id: 4, nombre: 'Otros'),
      crearCategoria(
        id: 5,
        nombre: 'Salario',
        naturaleza: NaturalezaCategoria.ingreso,
      ),
      crearCategoria(
        id: 6,
        nombre: 'Ventas',
        naturaleza: NaturalezaCategoria.ingreso,
      ),
      crearCategoria(
        id: 7,
        nombre: 'Otros',
        naturaleza: NaturalezaCategoria.ingreso,
      ),
    ],
    subcategorias: <Subcategoria>[
      crearSubcategoria(id: 1, categoriaId: 1, nombre: 'Supermercado'),
      crearSubcategoria(id: 2, categoriaId: 1, nombre: 'Restaurantes'),
      crearSubcategoria(id: 3, categoriaId: 2, nombre: 'Taxi/App'),
      crearSubcategoria(id: 4, categoriaId: 2, nombre: 'Gasolina'),
    ],
    etiquetas: const <Etiqueta>[Etiqueta(id: 1, nombre: 'trabajo')],
    cuentas: <dynamic>[crearCuenta(id: 1, moneda: 'COP')].cast(),
    monedaBase: 'COP',
    cuentaPorDefectoId: cuentaPorDefecto,
  );
}

void main() {
  setUp(() => contexto = construirContexto());

  test('gasto con monto en miles y subcategoría', () {
    final p = parsearTexto('gasté 18.500 en mercado', contexto);
    expect(p.tipo, TipoTransaccion.gasto);
    expect(p.montoCentavos, 1850000);
    expect(p.categoriaId, 1);
    expect(p.subcategoriaId, 1);
    expect(p.cuentaId, 1);
    expect(p.confianza, ConfianzaPropuesta.alta);
    expect(p.faltantes, isEmpty);
  });

  test('gasto con monto sin separadores', () {
    final p = parsearTexto('pagué 20000 por taxi', contexto);
    expect(p.tipo, TipoTransaccion.gasto);
    expect(p.montoCentavos, 2000000);
    expect(p.subcategoriaId, 3);
  });

  test('gasto con sufijo "mil"', () {
    final p = parsearTexto('compré ropa por 50 mil', contexto);
    expect(p.tipo, TipoTransaccion.gasto);
    expect(p.montoCentavos, 5000000);
    expect(p.categoriaId, 3);
  });

  test('ingreso con salario', () {
    final p = parsearTexto('recibí 2.000.000 de salario', contexto);
    expect(p.tipo, TipoTransaccion.ingreso);
    expect(p.montoCentavos, 200000000);
    expect(p.categoriaId, 5);
  });

  test('ingreso con "me pagaron"', () {
    final p = parsearTexto('me pagaron 500.000 de freelance', contexto);
    expect(p.tipo, TipoTransaccion.ingreso);
    expect(p.montoCentavos, 50000000);
    expect(p.categoriaId, 7, reason: 'cae en Otros de ingreso');
    expect(p.faltantes, contains('categoría'));
  });

  test('ingreso con millones y decimales', () {
    final p = parsearTexto('cobré 1.5 millones de ventas', contexto);
    expect(p.tipo, TipoTransaccion.ingreso);
    expect(p.montoCentavos, 150000000);
    expect(p.categoriaId, 6);
  });

  test('tolera mayúsculas y tildes', () {
    final p = parsearTexto(r'GASTÉ $20.000 EN MERCADO', contexto);
    expect(p.tipo, TipoTransaccion.gasto);
    expect(p.montoCentavos, 2000000);
    expect(p.categoriaId, 1);
  });

  test('monto con sufijo "k"', () {
    final p = parsearTexto('gasté 20k en ropa', contexto);
    expect(p.montoCentavos, 2000000);
    expect(p.categoriaId, 3);
  });

  test('monto con coma decimal y millones', () {
    final p = parsearTexto('gasté 1,5 millones en ropa', contexto);
    expect(p.montoCentavos, 150000000);
  });

  test('monto con centavos explícitos', () {
    final p = parsearTexto('pagué \$ 18.500,50 en mercado', contexto);
    expect(p.montoCentavos, 1850050);
  });

  test('reconoce etiqueta existente', () {
    final p = parsearTexto('gasté 18.500 en mercado #trabajo', contexto);
    expect(p.etiquetaIds, <int>[1]);
    expect(p.etiquetaNombres, <String>['trabajo']);
  });

  test('etiqueta desconocida queda como faltante', () {
    final p = parsearTexto('gasté 18.500 en mercado #viaje', contexto);
    expect(p.faltantes.join(' '), contains('#viaje'));
  });

  test('monto con gasolina usa la subcategoría correcta', () {
    final p = parsearTexto('gasté 30000 en gasolina', contexto);
    expect(p.subcategoriaId, 4);
    expect(p.categoriaId, 2);
  });

  test('sin monto: lo reporta y baja la confianza', () {
    final p = parsearTexto('gasté en mercado', contexto);
    expect(p.montoCentavos, isNull);
    expect(p.faltantes, contains('monto'));
    expect(p.confianza, ConfianzaPropuesta.baja);
  });

  test('sin categoría reconocible propone Otros', () {
    final p = parsearTexto('gasté 18.500 en xyz', contexto);
    expect(p.categoriaId, 4);
    expect(p.categoriaNombre, 'Otros');
    expect(p.faltantes, contains('categoría'));
    expect(p.confianza, ConfianzaPropuesta.media);
  });

  test('sin cuenta por defecto lo reporta', () {
    final p = parsearTexto('gasté 18.500 en mercado', construirContexto(cuentaPorDefecto: null));
    expect(p.cuentaId, isNull);
    expect(p.faltantes, contains('cuenta'));
    expect(p.confianza, ConfianzaPropuesta.media);
  });

  test('texto ambiguo deja tipo nulo y confianza baja', () {
    final p = parsearTexto('recibí y gasté 1000', contexto);
    expect(p.tipo, isNull);
    expect(p.faltantes, contains('tipo'));
    expect(p.confianza, ConfianzaPropuesta.baja);
  });

  test('texto sin datos devuelve el texto como resumen', () {
    final p = parsearTexto('mensaje cualquiera', contexto);
    expect(p.faltantes, containsAll(<String>['tipo', 'monto']));
    expect(p.resumen, contains('mensaje cualquiera'));
  });
}
