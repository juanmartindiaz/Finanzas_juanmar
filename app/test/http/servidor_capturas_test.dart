import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_finanzas/data/database/app_database.dart';
import 'package:gestor_finanzas/data/database/rutas_base_datos.dart';
import 'package:gestor_finanzas/data/repositories/capturas_repository.dart';
import 'package:gestor_finanzas/data/repositories/categorias_repository.dart';
import 'package:gestor_finanzas/data/repositories/configuracion_repository.dart';
import 'package:gestor_finanzas/data/repositories/cuentas_repository.dart';
import 'package:gestor_finanzas/data/repositories/etiquetas_repository.dart';
import 'package:gestor_finanzas/data/repositories/transacciones_repository.dart';
import 'package:gestor_finanzas/services/whatsapp_bridge/almacen_adjuntos.dart';
import 'package:gestor_finanzas/services/whatsapp_bridge/servidor_capturas.dart';
import 'package:http/http.dart' as http;

import '../support/pruebas_db.dart';

void main() {
  late Directory directorio;
  late AppDatabase db;
  late ServidorCapturas servidor;
  late String token;
  late String base;

  setUp(() async {
    directorio = await Directory.systemTemp.createTemp('gestor_http_');
    RutasBaseDatos.directorioOverride = () async => directorio;
    db = await baseEnMemoria();
    await sembrarDatosDePrueba(db);
    final ConfiguracionRepository configuracion = ConfiguracionRepository(db);
    await configuracion.guardarPuerto(0);
    await configuracion.obtenerOCrearToken();
    token = await configuracion.obtenerOCrearToken();
    servidor = ServidorCapturas(
      configuracion: configuracion,
      capturas: CapturasRepository(db, TransaccionesRepository(db)),
      categorias: CategoriasRepository(db),
      etiquetas: EtiquetasRepository(db),
      cuentas: CuentasRepository(db),
      almacen: AlmacenAdjuntos(),
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

  test('GET /api/salud responde sin token', () async {
    final http.Response r = await http.get(Uri.parse('$base/api/salud'));
    expect(r.statusCode, 200);
    final Map<String, Object?> json =
        jsonDecode(r.body) as Map<String, Object?>;
    expect(json['ok'], true);
    expect(json['version'], isNotEmpty);
  });

  test('GET /api/pendientes sin token responde 401', () async {
    final http.Response r = await http.get(Uri.parse('$base/api/pendientes'));
    expect(r.statusCode, 401);
  });

  test('POST texto sin token responde 401', () async {
    final http.Response r = await http.post(
      Uri.parse('$base/api/capturas/texto'),
      headers: <String, String>{'content-type': 'application/json'},
      body: jsonEncode(<String, Object?>{
        'message_id': 'm-1',
        'texto': 'gasté 18.500 en mercado',
        'canal': 'texto',
        'timestamp': 1795500000000,
      }),
    );
    expect(r.statusCode, 401);
  });

  test('POST texto con token crea captura y propuesta', () async {
    final http.Response r = await http.post(
      Uri.parse('$base/api/capturas/texto'),
      headers: <String, String>{
        'content-type': 'application/json',
        'x-bot-token': token,
      },
      body: jsonEncode(<String, Object?>{
        'message_id': 'm-2',
        'texto': 'gasté 18.500 en mercado',
        'canal': 'texto',
        'timestamp': 1795500000000,
      }),
    );
    expect(r.statusCode, 201);
    final Map<String, Object?> json =
        jsonDecode(r.body) as Map<String, Object?>;
    expect(json['estado'], 'confirmado');
    final int id = json['captura_id']! as int;
    final captura =
        await CapturasRepository(db, TransaccionesRepository(db)).obtener(id);
    expect(captura, isNotNull);
    expect(captura!.messageIdExterno, 'm-2');
    expect(captura.propuesta, isNotNull);
  });

  test('duplicado por message_id responde 409 con captura_id', () async {
    Future<http.Response> enviar() => http.post(
          Uri.parse('$base/api/capturas/texto'),
          headers: <String, String>{
            'content-type': 'application/json',
            'x-bot-token': token,
          },
          body: jsonEncode(<String, Object?>{
            'message_id': 'm-dup',
            'texto': 'taxi 9.800',
            'canal': 'texto',
            'timestamp': 1795500000000,
          }),
        );
    final http.Response primera = await enviar();
    expect(primera.statusCode, 201);
    final int id = (jsonDecode(primera.body) as Map<String, Object?>)['captura_id']!
        as int;
    final http.Response segunda = await enviar();
    expect(segunda.statusCode, 409);
    final Map<String, Object?> json =
        jsonDecode(segunda.body) as Map<String, Object?>;
    expect(json['captura_id'], id);
  });

  test('GET /api/pendientes con token cuenta las capturas', () async {
    await http.post(
      Uri.parse('$base/api/capturas/texto'),
      headers: <String, String>{
        'content-type': 'application/json',
        'x-bot-token': token,
      },
      body: jsonEncode(<String, Object?>{
        'message_id': 'm-pend',
        'texto': '10.000 en mercado',
        'canal': 'texto',
        'timestamp': 1795500000000,
      }),
    );
    final http.Response r = await http.get(
      Uri.parse('$base/api/pendientes'),
      headers: <String, String>{'x-bot-token': token},
    );
    expect(r.statusCode, 200);
    final Map<String, Object?> json =
        jsonDecode(r.body) as Map<String, Object?>;
    expect(json['total'], 1);
    expect(json['listos'], 1);
  });

  test('archivo de más de 8 MB responde 413', () async {
    final http.MultipartRequest peticion = http.MultipartRequest(
      'POST',
      Uri.parse('$base/api/capturas/foto'),
    )
      ..headers['x-bot-token'] = token
      ..fields['message_id'] = 'm-grande'
      ..fields['timestamp'] = '1795500000000'
      ..files.add(
        http.MultipartFile.fromBytes(
          'archivo',
          Uint8List(9 * 1024 * 1024),
          filename: 'grande.jpg',
        ),
      );
    final http.StreamedResponse flujo = await peticion.send();
    expect(flujo.statusCode, 413);
  });

  test('foto y audio válidos se guardan con estado correcto', () async {
    final AlmacenAdjuntos almacen = AlmacenAdjuntos();

    final http.MultipartRequest foto = http.MultipartRequest(
      'POST',
      Uri.parse('$base/api/capturas/foto'),
    )
      ..headers['x-bot-token'] = token
      ..fields['message_id'] = 'm-foto'
      ..fields['timestamp'] = '1795500000000'
      ..files.add(
        http.MultipartFile.fromBytes(
          'archivo',
          Uint8List.fromList(List<int>.filled(100, 7)),
          filename: 'recibo.jpg',
        ),
      );
    final http.Response respuestaFoto =
        await http.Response.fromStream(await foto.send());
    expect(respuestaFoto.statusCode, 201, reason: respuestaFoto.body);
    expect(
      (jsonDecode(respuestaFoto.body) as Map<String, Object?>)['estado'],
      'listo',
    );
    final String? ruta = (await CapturasRepository(
      db,
      TransaccionesRepository(db),
    )
            .buscarPorMessageId('m-foto'))!
        .adjuntoPath;
    expect(ruta, isNotNull);
    expect(await almacen.existe(ruta!), isTrue);

    final http.MultipartRequest audio = http.MultipartRequest(
      'POST',
      Uri.parse('$base/api/audio'),
    )
      ..headers['x-bot-token'] = token
      ..fields['message_id'] = 'm-audio'
      ..fields['timestamp'] = '1795500000000'
      ..files.add(
        http.MultipartFile.fromBytes(
          'archivo',
          Uint8List.fromList(List<int>.filled(50, 3)),
          filename: 'nota.ogg',
        ),
      );
    final http.Response respuestaAudio =
        await http.Response.fromStream(await audio.send());
    expect(respuestaAudio.statusCode, 201);
    expect(
      (jsonDecode(respuestaAudio.body) as Map<String, Object?>)['estado'],
      'pendiente',
    );
  });
}
