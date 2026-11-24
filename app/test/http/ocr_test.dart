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
    directorio = await Directory.systemTemp.createTemp('gestor_ocr_');
    RutasBaseDatos.directorioOverride = () async => directorio;
    db = await baseEnMemoria();
    await sembrarDatosDePrueba(db);
    final ConfiguracionRepository configuracion = ConfiguracionRepository(db);
    await configuracion.guardarPuerto(0);
    await configuracion.guardarCapturaCuentaId(1);
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

  Future<http.Response> enviarFoto(String messageId) async {
    final http.MultipartRequest peticion = http.MultipartRequest(
      'POST',
      Uri.parse('$base/api/capturas/foto'),
    )
      ..headers['x-bot-token'] = token
      ..fields['message_id'] = messageId
      ..fields['timestamp'] = '1795500000000'
      ..files.add(
        http.MultipartFile.fromBytes(
          'archivo',
          List<int>.filled(100, 7),
          filename: 'recibo.jpg',
        ),
      );
    return http.Response.fromStream(await peticion.send());
  }

  test('foto con OCR se registra automáticamente', () async {
    ocr.texto = '''
SUPERMERCADO ÉXITO
NIT 890.900.608-9
TOTAL 45.000
''';
    final http.Response r = await enviarFoto('ocr-1');
    expect(r.statusCode, 201);
    final Map<String, Object?> json =
        jsonDecode(r.body) as Map<String, Object?>;
    expect(json['estado'], 'confirmado');
    expect(json['monto_centavos'], 4500000);
    expect(json['comercio'], contains('ÉXITO'));
    expect(json['transaccion_id'], isNotNull);

    final CapturaEntrante? captura = await CapturasRepository(
      db,
      TransaccionesRepository(db),
    ).buscarPorMessageId('ocr-1');
    expect(captura!.estado, EstadoCaptura.confirmado);
    expect(captura.transaccionId, isNotNull);
  });

  test('foto sin monto queda esperando el monto', () async {
    ocr.texto = 'RECIBO ILEGIBLE';
    final http.Response r = await enviarFoto('ocr-2');
    expect(r.statusCode, 201);
    final Map<String, Object?> json =
        jsonDecode(r.body) as Map<String, Object?>;
    expect(json['estado'], 'listo');
    expect(
      (json['faltantes']! as List<Object?>).cast<String>(),
      contains('monto'),
    );
    expect(json['transaccion_id'], isNull);
  });

  test('auto-registro con categoría Otros marca incompleta', () async {
    final http.Response r = await http.post(
      Uri.parse('$base/api/capturas/texto'),
      headers: <String, String>{
        'content-type': 'application/json',
        'x-bot-token': token,
      },
      body: jsonEncode(<String, Object?>{
        'message_id': 'inc-1',
        'texto': 'gasté 18.500 en xyz',
        'canal': 'texto',
        'timestamp': 1795500000000,
      }),
    );
    final Map<String, Object?> json =
        jsonDecode(r.body) as Map<String, Object?>;
    expect(json['estado'], 'confirmado');
    expect(json['incompleta'], true);
    final CapturaEntrante? captura = await CapturasRepository(
      db,
      TransaccionesRepository(db),
    ).buscarPorMessageId('inc-1');
    expect(captura!.incompleta, isTrue);
  });
}
