import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_finanzas/domain/entities/categoria.dart';
import 'package:gestor_finanzas/domain/entities/cuenta.dart';
import 'package:gestor_finanzas/domain/entities/subcategoria.dart';
import 'package:gestor_finanzas/domain/entities/transaccion.dart';
import 'package:gestor_finanzas/domain/usecases/validacion.dart';

import '../support/ayudas.dart';

void main() {
  final cuentas = <Cuenta>[
    crearCuenta(id: 1, moneda: 'COP'),
    crearCuenta(id: 2, nombre: 'Nequi', moneda: 'COP'),
    crearCuenta(id: 3, nombre: 'Dólares', moneda: 'USD'),
  ];
  final categorias = <Categoria>[
    crearCategoria(id: 1, naturaleza: NaturalezaCategoria.gasto),
    crearCategoria(
      id: 2,
      nombre: 'Salario',
      naturaleza: NaturalezaCategoria.ingreso,
    ),
  ];
  final subcategorias = <Subcategoria>[
    crearSubcategoria(id: 1, categoriaId: 1),
    crearSubcategoria(id: 2, categoriaId: 2, nombre: 'Bonos'),
  ];
  final momento = DateTime(2026, 11, 23, 12);

  test('un gasto correcto es válido', () {
    final errores = validarTransaccion(
      tipo: TipoTransaccion.gasto,
      montoCentavos: 1850000,
      moneda: 'COP',
      cuentaId: 1,
      cuentaDestinoId: null,
      montoDestinoCentavos: null,
      monedaDestino: null,
      categoriaId: 1,
      subcategoriaId: 1,
      fechaHora: momento,
      nota: 'Almuerzo',
      cuentas: cuentas,
      categorias: categorias,
      subcategorias: subcategorias,
      ahora: momento,
    );

    expect(errores, isEmpty);
  });

  test('rechaza monto cero o negativo', () {
    final errores = validarTransaccion(
      tipo: TipoTransaccion.gasto,
      montoCentavos: 0,
      moneda: 'COP',
      cuentaId: 1,
      cuentaDestinoId: null,
      montoDestinoCentavos: null,
      monedaDestino: null,
      categoriaId: 1,
      subcategoriaId: null,
      fechaHora: momento,
      nota: null,
      cuentas: cuentas,
      categorias: categorias,
      subcategorias: subcategorias,
      ahora: momento,
    );

    expect(errores.join(' '), contains('mayor que cero'));
  });

  test('exige categoría en ingreso/gasto', () {
    final errores = validarTransaccion(
      tipo: TipoTransaccion.gasto,
      montoCentavos: 1000,
      moneda: 'COP',
      cuentaId: 1,
      cuentaDestinoId: null,
      montoDestinoCentavos: null,
      monedaDestino: null,
      categoriaId: null,
      subcategoriaId: null,
      fechaHora: momento,
      nota: null,
      cuentas: cuentas,
      categorias: categorias,
      subcategorias: subcategorias,
      ahora: momento,
    );

    expect(errores.join(' '), contains('categoría'));
  });

  test('la categoría debe servir para el tipo', () {
    final errores = validarTransaccion(
      tipo: TipoTransaccion.gasto,
      montoCentavos: 1000,
      moneda: 'COP',
      cuentaId: 1,
      cuentaDestinoId: null,
      montoDestinoCentavos: null,
      monedaDestino: null,
      categoriaId: 2,
      subcategoriaId: null,
      fechaHora: momento,
      nota: null,
      cuentas: cuentas,
      categorias: categorias,
      subcategorias: subcategorias,
      ahora: momento,
    );

    expect(errores.join(' '), contains('no sirve'));
  });

  test('la subcategoría debe pertenecer a la categoría', () {
    final errores = validarTransaccion(
      tipo: TipoTransaccion.gasto,
      montoCentavos: 1000,
      moneda: 'COP',
      cuentaId: 1,
      cuentaDestinoId: null,
      montoDestinoCentavos: null,
      monedaDestino: null,
      categoriaId: 1,
      subcategoriaId: 2,
      fechaHora: momento,
      nota: null,
      cuentas: cuentas,
      categorias: categorias,
      subcategorias: subcategorias,
      ahora: momento,
    );

    expect(errores.join(' '), contains('no pertenece'));
  });

  test('rechaza una moneda que no está en el catálogo', () {
    final errores = validarTransaccion(
      tipo: TipoTransaccion.gasto,
      montoCentavos: 1000,
      moneda: 'XYZ',
      cuentaId: 1,
      cuentaDestinoId: null,
      montoDestinoCentavos: null,
      monedaDestino: null,
      categoriaId: 1,
      subcategoriaId: null,
      fechaHora: momento,
      nota: null,
      cuentas: cuentas,
      categorias: categorias,
      subcategorias: subcategorias,
      ahora: momento,
    );

    expect(errores.join(' '), contains('catálogo'));
  });

  test('exige confirmación para una fecha futura', () {
    final errores = validarTransaccion(
      tipo: TipoTransaccion.gasto,
      montoCentavos: 1000,
      moneda: 'COP',
      cuentaId: 1,
      cuentaDestinoId: null,
      montoDestinoCentavos: null,
      monedaDestino: null,
      categoriaId: 1,
      subcategoriaId: null,
      fechaHora: momento.add(const Duration(days: 2)),
      nota: null,
      cuentas: cuentas,
      categorias: categorias,
      subcategorias: subcategorias,
      ahora: momento,
    );

    expect(errores.join(' '), contains('futura'));
  });

  test('una transferencia correcta entre monedas es válida', () {
    final errores = validarTransaccion(
      tipo: TipoTransaccion.transferencia,
      montoCentavos: 40000000,
      moneda: 'COP',
      cuentaId: 1,
      cuentaDestinoId: 3,
      montoDestinoCentavos: 1000000,
      monedaDestino: 'USD',
      categoriaId: null,
      subcategoriaId: null,
      fechaHora: momento,
      nota: null,
      cuentas: cuentas,
      categorias: categorias,
      subcategorias: subcategorias,
      ahora: momento,
    );

    expect(errores, isEmpty);
  });

  test('transferencia a la misma cuenta es inválida', () {
    final errores = validarTransaccion(
      tipo: TipoTransaccion.transferencia,
      montoCentavos: 1000,
      moneda: 'COP',
      cuentaId: 1,
      cuentaDestinoId: 1,
      montoDestinoCentavos: 1000,
      monedaDestino: 'COP',
      categoriaId: null,
      subcategoriaId: null,
      fechaHora: momento,
      nota: null,
      cuentas: cuentas,
      categorias: categorias,
      subcategorias: subcategorias,
      ahora: momento,
    );

    expect(errores.join(' '), contains('distinta'));
  });

  test('transferencia con misma moneda exige montos iguales', () {
    final errores = validarTransaccion(
      tipo: TipoTransaccion.transferencia,
      montoCentavos: 1000,
      moneda: 'COP',
      cuentaId: 1,
      cuentaDestinoId: 2,
      montoDestinoCentavos: 900,
      monedaDestino: 'COP',
      categoriaId: null,
      subcategoriaId: null,
      fechaHora: momento,
      nota: null,
      cuentas: cuentas,
      categorias: categorias,
      subcategorias: subcategorias,
      ahora: momento,
    );

    expect(errores.join(' '), contains('igual'));
  });
}
