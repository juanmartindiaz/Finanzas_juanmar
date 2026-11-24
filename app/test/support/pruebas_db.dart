import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:gestor_finanzas/data/database/app_database.dart';
import 'package:gestor_finanzas/data/repositories/categorias_repository.dart';
import 'package:gestor_finanzas/data/repositories/cuentas_repository.dart';
import 'package:gestor_finanzas/data/repositories/etiquetas_repository.dart';
import 'package:gestor_finanzas/domain/entities/categoria.dart';
import 'package:gestor_finanzas/domain/entities/cuenta.dart';

/// Base de datos en memoria para pruebas de repositorio y HTTP.
Future<AppDatabase> baseEnMemoria() async {
  final AppDatabase db = AppDatabase.paraPruebas(NativeDatabase.memory());
  await db.customSelect('SELECT 1').getSingle();
  return db;
}

/// Crea una cuenta, categorías y etiquetas mínimas para las pruebas.
Future<void> sembrarDatosDePrueba(AppDatabase db) async {
  final cuentas = CuentasRepository(db);
  await cuentas.crear(
    nombre: 'Efectivo',
    tipo: TipoCuenta.efectivo,
    saldoInicialCentavos: 100000,
    moneda: 'COP',
    activa: true,
  );
  final categorias = CategoriasRepository(db);
  final int alimentacion = await categorias.crearCategoria(
    nombre: 'Alimentación',
    naturaleza: NaturalezaCategoria.gasto,
  );
  await categorias.crearSubcategoria(
    categoriaId: alimentacion,
    nombre: 'Supermercado',
  );
  final int transporte = await categorias.crearCategoria(
    nombre: 'Transporte',
    naturaleza: NaturalezaCategoria.gasto,
  );
  await categorias.crearSubcategoria(
    categoriaId: transporte,
    nombre: 'Taxi/App',
  );
  await categorias.crearCategoria(
    nombre: 'Otros',
    naturaleza: NaturalezaCategoria.gasto,
  );
  await categorias.crearCategoria(
    nombre: 'Salario',
    naturaleza: NaturalezaCategoria.ingreso,
  );
  await categorias.crearCategoria(
    nombre: 'Otros',
    naturaleza: NaturalezaCategoria.ingreso,
  );
  await EtiquetasRepository(db).crear(nombre: 'trabajo');
}

/// Lee un valor entero de una consulta cruda.
Future<int> leerEntero(AppDatabase db, String sql) async {
  final QueryRow fila = await db.customSelect(sql).getSingle();
  return fila.read<int>('valor');
}
