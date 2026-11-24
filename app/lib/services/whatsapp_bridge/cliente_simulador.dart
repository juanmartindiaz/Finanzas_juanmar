import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../data/repositories/configuracion_repository.dart';

/// Resultado de una simulación de mensaje.
class ResultadoSimulacion {
  const ResultadoSimulacion({
    required this.codigo,
    required this.cuerpo,
    required this.messageId,
  });

  final int codigo;
  final Map<String, Object?> cuerpo;
  final String messageId;

  bool get ok => codigo >= 200 && codigo < 300;
  int? get capturaId {
    final Object? valor = cuerpo['captura_id'];
    return valor is int ? valor : int.tryParse('$valor');
  }

  String get error {
    final Object? detalle = cuerpo['error'];
    if (detalle is Map && detalle['mensaje'] is String) {
      return detalle['mensaje'] as String;
    }
    return 'Error HTTP $codigo';
  }
}

/// Cliente que usa el **simulador de bot dentro de la app**. Hace peticiones
/// HTTP reales al servidor local con el token, como lo haría el bot
/// (ADR-032).
class ClienteSimulador {
  ClienteSimulador(this._configuracion);

  final ConfiguracionRepository _configuracion;

  Future<String> _token() => _configuracion.obtenerOCrearToken();
  Future<int> _puerto() => _configuracion.obtenerPuerto();

  Uri _url(String ruta, int puerto) =>
      Uri.parse('http://127.0.0.1:$puerto$ruta');

  String _nuevoMessageId() =>
      'sim-${DateTime.now().millisecondsSinceEpoch}';

  Future<ResultadoSimulacion> enviarTexto(
    String texto, {
    String? messageId,
  }) async {
    final String token = await _token();
    final int puerto = await _puerto();
    final String id = messageId ?? _nuevoMessageId();
    final http.Response respuesta = await http
        .post(
          _url('/api/capturas/texto', puerto),
          headers: <String, String>{
            'content-type': 'application/json',
            'x-bot-token': token,
            'x-bot-simulado': '1',
          },
          body: jsonEncode(<String, Object?>{
            'message_id': id,
            'texto': texto,
            'canal': 'texto',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          }),
        )
        .timeout(const Duration(seconds: 15));
    return ResultadoSimulacion(
      codigo: respuesta.statusCode,
      cuerpo: _decodificar(respuesta.body),
      messageId: id,
    );
  }

  Future<ResultadoSimulacion> enviarArchivo(
    File archivo, {
    required bool esAudio,
    String? messageId,
  }) async {
    final String token = await _token();
    final int puerto = await _puerto();
    final String id = messageId ?? _nuevoMessageId();
    final http.MultipartRequest peticion = http.MultipartRequest(
      'POST',
      _url(esAudio ? '/api/audio' : '/api/capturas/foto', puerto),
    )
      ..headers.addAll(<String, String>{
        'x-bot-token': token,
        'x-bot-simulado': '1',
      })
      ..fields['message_id'] = id
      ..fields['timestamp'] = '${DateTime.now().millisecondsSinceEpoch}'
      ..files.add(await http.MultipartFile.fromPath('archivo', archivo.path));

    final http.StreamedResponse flujo =
        await peticion.send().timeout(const Duration(seconds: 30));
    final http.Response respuesta = await http.Response.fromStream(flujo);
    return ResultadoSimulacion(
      codigo: respuesta.statusCode,
      cuerpo: _decodificar(respuesta.body),
      messageId: id,
    );
  }

  Map<String, Object?> _decodificar(String cuerpo) {
    try {
      final Object? decodificado = jsonDecode(cuerpo);
      if (decodificado is Map) {
        return decodificado.map(
          (Object? clave, Object? valor) =>
              MapEntry<String, Object?>('$clave', valor),
        );
      }
    } on FormatException {
      // Se ignora: se devuelve un mapa vacío.
    }
    return <String, Object?>{};
  }
}
