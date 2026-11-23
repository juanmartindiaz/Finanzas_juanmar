/// Datos fijos de la semilla inicial de categorías (Fase 1).
///
/// El usuario puede editarlas, archivarlas o borrarlas después; la semilla solo
/// corre una vez (ver `domain/usecases/semilla.dart`).
library;

import '../../domain/entities/categoria.dart';

/// Categoría de la semilla con sus subcategorías.
class SemillaCategoria {
  const SemillaCategoria({
    required this.nombre,
    required this.naturaleza,
    required this.icono,
    required this.color,
    this.subcategorias = const <String>[],
  });

  final String nombre;
  final NaturalezaCategoria naturaleza;
  final String icono;
  final String color;
  final List<String> subcategorias;
}

/// Semilla aprobada en la Fase 1: 10 categorías de gasto y 6 de ingreso.
const List<SemillaCategoria> semillaCategorias = <SemillaCategoria>[
  // ---------- Gastos ----------
  SemillaCategoria(
    nombre: 'Alimentación',
    naturaleza: NaturalezaCategoria.gasto,
    icono: 'restaurant',
    color: '#E53935',
    subcategorias: <String>['Supermercado', 'Restaurantes', 'Domicilios'],
  ),
  SemillaCategoria(
    nombre: 'Transporte',
    naturaleza: NaturalezaCategoria.gasto,
    icono: 'directions_bus',
    color: '#1E88E5',
    subcategorias: <String>['Público', 'Gasolina', 'Taxi/App'],
  ),
  SemillaCategoria(
    nombre: 'Hogar y Servicios',
    naturaleza: NaturalezaCategoria.gasto,
    icono: 'home',
    color: '#FB8C00',
  ),
  SemillaCategoria(
    nombre: 'Salud',
    naturaleza: NaturalezaCategoria.gasto,
    icono: 'local_hospital',
    color: '#43A047',
  ),
  SemillaCategoria(
    nombre: 'Educación',
    naturaleza: NaturalezaCategoria.gasto,
    icono: 'school',
    color: '#3949AB',
  ),
  SemillaCategoria(
    nombre: 'Ocio',
    naturaleza: NaturalezaCategoria.gasto,
    icono: 'movie',
    color: '#8E24AA',
  ),
  SemillaCategoria(
    nombre: 'Ropa',
    naturaleza: NaturalezaCategoria.gasto,
    icono: 'checkroom',
    color: '#F4511E',
  ),
  SemillaCategoria(
    nombre: 'Compras',
    naturaleza: NaturalezaCategoria.gasto,
    icono: 'shopping_bag',
    color: '#00897B',
  ),
  SemillaCategoria(
    nombre: 'Mascotas',
    naturaleza: NaturalezaCategoria.gasto,
    icono: 'pets',
    color: '#6D4C41',
  ),
  SemillaCategoria(
    nombre: 'Otros',
    naturaleza: NaturalezaCategoria.gasto,
    icono: 'category',
    color: '#546E7A',
  ),
  // ---------- Ingresos ----------
  SemillaCategoria(
    nombre: 'Salario',
    naturaleza: NaturalezaCategoria.ingreso,
    icono: 'payments',
    color: '#43A047',
  ),
  SemillaCategoria(
    nombre: 'Freelance/Honorarios',
    naturaleza: NaturalezaCategoria.ingreso,
    icono: 'work',
    color: '#1E88E5',
  ),
  SemillaCategoria(
    nombre: 'Ventas',
    naturaleza: NaturalezaCategoria.ingreso,
    icono: 'store',
    color: '#FB8C00',
  ),
  SemillaCategoria(
    nombre: 'Regalos',
    naturaleza: NaturalezaCategoria.ingreso,
    icono: 'card_giftcard',
    color: '#8E24AA',
  ),
  SemillaCategoria(
    nombre: 'Rendimientos',
    naturaleza: NaturalezaCategoria.ingreso,
    icono: 'trending_up',
    color: '#00897B',
  ),
  SemillaCategoria(
    nombre: 'Otros',
    naturaleza: NaturalezaCategoria.ingreso,
    icono: 'category',
    color: '#546E7A',
  ),
];
