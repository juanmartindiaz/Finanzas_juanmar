import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_finanzas/data/database/app_database.dart';
import 'package:gestor_finanzas/data/database/rutas_base_datos.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory directorio;

  setUp(() async {
    directorio = await Directory.systemTemp.createTemp('gestor_migracion_');
    RutasBaseDatos.directorioOverride = () async => directorio;
  });

  tearDown(() async {
    await RutasBaseDatos.borrar();
    if (await directorio.exists()) {
      await directorio.delete(recursive: true);
    }
  });

  test('v1 -> v3 conserva los datos y crea captura_entrante', () async {
    final String ruta = await RutasBaseDatos.ruta();

    // 1. Crear el esquema v2 y sembrar datos con Drift.
    AppDatabase db = AppDatabase.paraPruebas(NativeDatabase(File(ruta)));
    await db.customSelect('SELECT 1').getSingle();
    final int categoriaId = await db.into(db.categorias).insert(
          CategoriasCompanion.insert(
            nombre: 'Alimentación',
            naturaleza: 'gasto',
            creadoEn: 1,
            actualizadoEn: 1,
          ),
        );
    final int cuentaId = await db.into(db.cuentas).insert(
          CuentasCompanion.insert(
            nombre: 'Efectivo',
            tipo: 'efectivo',
            creadoEn: 1,
            actualizadoEn: 1,
          ),
        );
    await db.into(db.transacciones).insert(
          TransaccionesCompanion.insert(
            tipo: 'gasto',
            montoCentavos: 1850000,
            moneda: 'COP',
            cuentaId: cuentaId,
            categoriaId: Value<int>(categoriaId),
            fecha: '2026-11-24',
            fechaHora: 1,
            creadoEn: 1,
            actualizadoEn: 1,
          ),
        );
    await db.close();

    // 2. Dejar la base como v1: sin captura_entrante y user_version = 1.
    final Database crudo = sqlite3.open(ruta);
    crudo.execute('DROP TABLE captura_entrante;');
    crudo.execute('PRAGMA user_version = 1;');
    final int cuentasAntes =
        crudo.select('SELECT COUNT(*) AS c FROM cuentas').first['c'] as int;
    final int transaccionesAntes =
        crudo.select('SELECT COUNT(*) AS c FROM transacciones').first['c'] as int;
    final int categoriasAntes =
        crudo.select('SELECT COUNT(*) AS c FROM categorias').first['c'] as int;
    expect(
      crudo.select('PRAGMA user_version').first['user_version'],
      1,
    );
    crudo.close();

    // 3. Copia de seguridad en la MISMA ruta que la base.
    expect(await RutasBaseDatos.copiarAResplado(), isTrue);
    expect(await File(await RutasBaseDatos.rutaRespaldo()).exists(), isTrue);

    // 4. Abrir de nuevo: debe migrar a v2 sin perder datos.
    db = AppDatabase.paraPruebas(NativeDatabase(File(ruta)));
    await db.customSelect('SELECT 1').getSingle();
    final int version = (await db
            .customSelect('PRAGMA user_version')
            .getSingle())
        .read<int>('user_version');
    expect(version, 3);
    expect(
      (await db.select(db.cuentas).get()).length,
      cuentasAntes,
    );
    expect(
      (await db.select(db.transacciones).get()).length,
      transaccionesAntes,
    );
    expect(
      (await db.select(db.categorias).get()).length,
      categoriasAntes,
    );

    // 5. La tabla nueva existe y se puede usar.
    await db.into(db.capturaEntrante).insert(
          CapturaEntranteCompanion.insert(
            canal: 'texto',
            origen: 'bot',
            estado: Value<String>('listo'),
            createdAt: 1,
          ),
        );
    expect((await db.select(db.capturaEntrante).get()).length, 1);
    await db.close();
  });
}
