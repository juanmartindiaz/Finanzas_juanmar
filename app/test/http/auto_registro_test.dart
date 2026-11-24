import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_finanzas/data/database/app_database.dart';
import 'package:gestor_finanzas/data/database/rutas_base_datos.dart';
import 'package:gestor_finanzas/data/repositories/capturas_repository.dart';
import 'package:gestor_finanzas/data/repositories/categorias_repository.dart';
import 'package:gestor_finanzas/data/repositories/configuracion_repository.dart';
import 'package:gestor_finanzas/data/repositories/cuentas_repository.dart';
import 'package:gestor_finanzas/data/repositories/etiquetas_repository.dart';
import 'package:gestor_finanzas/data/repositories/transacciones_repository.dart';
import 'package:gestor_finanzas/domain/entities/captura.dart';
import 'package:gestor_finanzas/domain/entities/transaccion.dart';
import 'package:gestor_finanzas/services/ocr/servicio_ocr.dart';
import 'package:gestor_finanzas/services/whatsapp_bridge/almacen_adjuntos.dart';
import 'package:gestor_finanzas/services/whatsapp_bridge/servidor_capturas.dart';
import 'package:http/http.dart' as http;

import '../support/pruebas_db.dart';

class FakeOcr implements ServicioOcr {
  String texto = '';

  @override
  Future<String> reconocerTexto(String rutaAbsoluta) async => texto;
}

void main() {
  late Directory directorio;
  late AppDatabase db;
  late ServidorCapturas servidor;
  late String token;
  late String base;
  late FakeOcr ocr;

  setUp(() async {
    directorio = await Directory.systemTemp.createTemp('gestor_auto_');
    RutasBaseDatos.directorioOverride = () async => directorio;
    db = await baseEnMemoria();
    await sembrarDatosDePrueba(db);
    final ConfiguracionRepository configuracion = ConfiguracionRepository(db);
    await configuracion.guardarPuerto(0);
    token = await configuracion.obtenerOCrearToken();
    ocr = FakeOcr();
    servidor = ServidorCapturas(
      configuracion: configuracion,
      capturas: CapturasRepository(db, TransaccionesRepository(db)),
      categorias: CategoriasRepository(db),
      etiquetas: EtiquetasRepository(db),
      cuentas: CuentasRepository(db),
      almacen: AlmacenAdjuntos(),
      ocr: ocr,
    );
    await servidor.iniciar();
    base = 'http://127.0.0.1:${servidor.puerto}';
  });

  tearDown(() async {
    await servidor.detener();
    await db.close();
    RutasBaseDatos.directorioOverride = null;
    if (await directorio.exists()) {
      await directorio.delete(recursive: true);
    }
  });

  Future<http.Response> enviarTexto(String texto, String messageId) {
    return http.post(
      Uri.parse('$base/api/capturas/texto'),
      headers: <String, String>{
        'content-type': 'application/json',
        'x-bot-token': token,
      },
      body: jsonEncode(<String, Object?>{
        'message_id': messageId,
        'texto': texto,
        'canal': 'texto',
        'timestamp': 1795500000000,
      }),
    );
  }

  test('GET /api/cuentas devuelve las cuentas activas', () async {
    final http.Response r = await http.get(
      Uri.parse('$base/api/cuentas'),
      headers: <String, String>{'x-bot-token': token},
    );
    expect(r.statusCode, 200);
    final Map<String, Object?> json =
        jsonDecode(r.body) as Map<String, Object?>;
    final List<Object?> cuentas = json['cuentas']! as List<Object?>;
    expect(cuentas, isNotEmpty);
    expect((cuentas.first! as Map<String, Object?>)['nombre'], 'Efectivo');
  });

  test('texto con cuenta explícita se registra automáticamente', () async {
    final http.Response r = await enviarTexto(
      'gasté 18.500 en mercado en efectivo',
      'auto-1',
    );
    expect(r.statusCode, 201);
    final Map<String, Object?> json =
        jsonDecode(r.body) as Map<String, Object?>;
    expect(json['estado'], 'confirmado');
    expect(json['transaccion_id'], isNotNull);
    expect(json['faltantes'], isEmpty);

    final CapturasRepository capturas =
        CapturasRepository(db, TransaccionesRepository(db));
    final CapturaEntrante? captura =
        await capturas.obtener(json['captura_id']! as int);
    expect(captura!.estado, EstadoCaptura.confirmado);
    final Transaccion? transaccion = await TransaccionesRepository(db)
        .obtener(json['transaccion_id']! as int);
    expect(transaccion, isNotNull);
    expect(transaccion!.origen, OrigenTransaccion.bot);
  });

  test('texto incompleto se completa con /confirmar', () async {
    final http.Response inicial =
        await enviarTexto('18.500 en mercado', 'auto-2');
    expect(inicial.statusCode, 201);
    final Map<String, Object?> jsonInicial =
        jsonDecode(inicial.body) as Map<String, Object?>;
    expect(jsonInicial['estado'], 'listo');
    expect(
      (jsonInicial['faltantes']! as List<Object?>).cast<String>(),
      contains('tipo'),
    );
    final int capturaId = jsonInicial['captura_id']! as int;

    final http.Response confirmada = await http.post(
      Uri.parse('$base/api/capturas/$capturaId/confirmar'),
      headers: <String, String>{
        'content-type': 'application/json',
        'x-bot-token': token,
      },
      body: jsonEncode(<String, Object?>{'tipo': 'gasto'}),
    );
    expect(confirmada.statusCode, 200);
    final Map<String, Object?> json =
        jsonDecode(confirmada.body) as Map<String, Object?>;
    expect(json['estado'], 'confirmado');
    expect(json['transaccion_id'], isNotNull);
    expect(
      (await CapturasRepository(db, TransaccionesRepository(db))
              .obtener(capturaId))!
          .estado,
      EstadoCaptura.confirmado,
    );
  });

  test('confirmar sin datos devuelve 400 con faltantes', () async {
    final http.Response inicial =
        await enviarTexto('18.500 en mercado', 'auto-3');
    final int capturaId =
        (jsonDecode(inicial.body) as Map<String, Object?>)['captura_id']! as int;
    final http.Response r = await http.post(
      Uri.parse('$base/api/capturas/$capturaId/confirmar'),
      headers: <String, String>{
        'content-type': 'application/json',
        'x-bot-token': token,
      },
      body: jsonEncode(<String, Object?>{}),
    );
    expect(r.statusCode, 400);
    final Map<String, Object?> json =
        jsonDecode(r.body) as Map<String, Object?>;
    expect(json['faltantes'], contains('tipo'));
  });
}

