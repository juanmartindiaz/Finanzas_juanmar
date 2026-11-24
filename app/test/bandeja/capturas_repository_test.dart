import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_finanzas/data/repositories/capturas_repository.dart';
import 'package:gestor_finanzas/data/repositories/transacciones_repository.dart';
import 'package:gestor_finanzas/domain/entities/captura.dart';
import 'package:gestor_finanzas/domain/entities/transaccion.dart';

import '../support/pruebas_db.dart';

void main() {
  test('la base en memoria crea el esquema v2 con capturas', () async {
    final db = await baseEnMemoria();
    await sembrarDatosDePrueba(db);

    final capturas = CapturasRepository(db, TransaccionesRepository(db));
    expect(await capturas.contarPendientes(), 0);

    await db.close();
  });

  test('una captura manual confirmada crea transacción manual', () async {
    final db = await baseEnMemoria();
    await sembrarDatosDePrueba(db);
    final capturas = CapturasRepository(db, TransaccionesRepository(db));

    final int id = await capturas.crearManualTexto(
      texto: 'gasté 18.500 en mercado',
      propuesta: const PropuestaCaptura(
        montoCentavos: 1850000,
        moneda: 'COP',
        confianza: ConfianzaPropuesta.alta,
      ),
    );
    final int transaccionId = await capturas.confirmar(
      capturaId: id,
      tipo: TipoTransaccion.gasto,
      montoCentavos: 1850000,
      moneda: 'COP',
      cuentaId: 1,
      fecha: '2026-11-24',
      fechaHora: 1795500000000,
      categoriaId: 1,
      subcategoriaId: 1,
    );

    final Transaccion? transaccion =
        await TransaccionesRepository(db).obtener(transaccionId);
    expect(transaccion, isNotNull);
    expect(transaccion!.origen, OrigenTransaccion.manual);
    final captura = await capturas.obtener(id);
    expect(captura!.estado, EstadoCaptura.confirmado);
    expect(captura.transaccionId, transaccionId);
    await db.close();
  });

  test('una captura del bot confirmada crea transacción con origen bot',
      () async {
    final db = await baseEnMemoria();
    await sembrarDatosDePrueba(db);
    final capturas = CapturasRepository(db, TransaccionesRepository(db));

    final int id = await capturas.crearDesdeCanal(
      messageId: 'wamid.prueba-1',
      canal: CanalCaptura.texto,
      estado: EstadoCaptura.listo,
      origen: OrigenCaptura.mock,
      timestamp: 1795500000000,
      texto: 'taxi 9.800',
    );
    final int transaccionId = await capturas.confirmar(
      capturaId: id,
      tipo: TipoTransaccion.gasto,
      montoCentavos: 980000,
      moneda: 'COP',
      cuentaId: 1,
      fecha: '2026-11-24',
      fechaHora: 1795500000000,
      categoriaId: 2,
    );
    final Transaccion? transaccion =
        await TransaccionesRepository(db).obtener(transaccionId);
    expect(transaccion!.origen, OrigenTransaccion.bot);
    await db.close();
  });

  test('descartar una captura no crea ninguna transacción', () async {
    final db = await baseEnMemoria();
    await sembrarDatosDePrueba(db);
    final capturas = CapturasRepository(db, TransaccionesRepository(db));

    final int id = await capturas.crearManualTexto(
      texto: 'algo',
      propuesta: const PropuestaCaptura(
        moneda: 'COP',
        confianza: ConfianzaPropuesta.baja,
      ),
    );
    await capturas.descartar(id);

    expect(await leerEntero(db, 'SELECT COUNT(*) AS valor FROM transacciones'), 0);
    expect((await capturas.obtener(id))!.estado, EstadoCaptura.descartado);
    await db.close();
  });
}
