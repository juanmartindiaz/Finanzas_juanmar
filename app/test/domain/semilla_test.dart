import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_finanzas/data/database/semilla_datos.dart';
import 'package:gestor_finanzas/domain/entities/categoria.dart';
import 'package:gestor_finanzas/domain/usecases/semilla.dart';

void main() {
  group('semilla inicial', () {
    test('corre solo si no se ha sembrado y la tabla está vacía', () {
      expect(
        debeSembrarCategorias(yaSeSembro: false, categoriasExistentes: 0),
        isTrue,
      );
      expect(
        debeSembrarCategorias(yaSeSembro: true, categoriasExistentes: 0),
        isFalse,
      );
      expect(
        debeSembrarCategorias(yaSeSembro: false, categoriasExistentes: 16),
        isFalse,
      );
    });

    test('si el usuario borra todas las categorías no se vuelve a sembrar', () {
      // Ya existe la marca de sembrado y quedan filas borradas lógicamente.
      expect(
        debeSembrarCategorias(yaSeSembro: true, categoriasExistentes: 16),
        isFalse,
      );
    });

    test('tiene 10 categorías de gasto y 6 de ingreso', () {
      final gastos = semillaCategorias
          .where((elemento) => elemento.naturaleza == NaturalezaCategoria.gasto)
          .toList();
      final ingresos = semillaCategorias
          .where(
            (elemento) => elemento.naturaleza == NaturalezaCategoria.ingreso,
          )
          .toList();

      expect(gastos, hasLength(10));
      expect(ingresos, hasLength(6));
      expect(semillaCategorias, hasLength(16));
    });

    test('Alimentación y Transporte traen sus subcategorías', () {
      final alimentacion = semillaCategorias.firstWhere(
        (elemento) => elemento.nombre == 'Alimentación',
      );
      final transporte = semillaCategorias.firstWhere(
        (elemento) => elemento.nombre == 'Transporte',
      );

      expect(
        alimentacion.subcategorias,
        <String>['Supermercado', 'Restaurantes', 'Domicilios'],
      );
      expect(
        transporte.subcategorias,
        <String>['Público', 'Gasolina', 'Taxi/App'],
      );
    });

    test('no hay nombres repetidos dentro de la misma naturaleza', () {
      for (final NaturalezaCategoria naturaleza in <NaturalezaCategoria>[
        NaturalezaCategoria.gasto,
        NaturalezaCategoria.ingreso,
      ]) {
        final nombres = semillaCategorias
            .where((elemento) => elemento.naturaleza == naturaleza)
            .map((elemento) => elemento.nombre)
            .toList();
        expect(nombres.toSet().length, nombres.length);
      }
    });
  });
}
