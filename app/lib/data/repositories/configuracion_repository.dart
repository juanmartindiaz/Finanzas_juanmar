import 'dart:math';

import '../../core/utils/dinero.dart';
import '../../core/utils/fechas.dart';
import '../database/app_database.dart';

/// Acceso a la configuración clave/valor.
class ConfiguracionRepository {
  ConfiguracionRepository(this._db);

  final AppDatabase _db;

  static const String claveMonedaBase = 'moneda_base';
  static const String claveToken = 'bot_token';
  static const String clavePuerto = 'bot_puerto_app';
  static const String claveModoMock = 'bot_modo_mock';
  static const String claveCapturaCuenta = 'captura_cuenta_id';

  static const int puertoPorDefecto = 8787;

  // ---------- moneda base ----------

  Stream<String> watchMonedaBase() {
    return watchValor(claveMonedaBase).map(
      (String? valor) => valor ?? monedaBasePorDefecto,
    );
  }

  Future<String> obtenerMonedaBase() async {
    return await obtenerValor(claveMonedaBase) ?? monedaBasePorDefecto;
  }

  Future<void> guardarMonedaBase(String codigo) =>
      guardarValor(claveMonedaBase, codigo);

  // ---------- canal bot ----------

  Stream<String> watchToken() {
    return watchValor(claveToken).map((String? valor) => valor ?? '');
  }

  /// Devuelve el token; si no existe, genera uno de 64 caracteres hex.
  Future<String> obtenerOCrearToken() async {
    final String? existente = await obtenerValor(claveToken);
    if (existente != null && existente.length >= 32) {
      return existente;
    }
    final String nuevo = generarToken();
    await guardarValor(claveToken, nuevo);
    return nuevo;
  }

  Future<String> regenerarToken() async {
    final String nuevo = generarToken();
    await guardarValor(claveToken, nuevo);
    return nuevo;
  }

  Stream<int> watchPuerto() {
    return watchValor(clavePuerto).map(
      (String? valor) => int.tryParse(valor ?? '') ?? puertoPorDefecto,
    );
  }

  Future<int> obtenerPuerto() async {
    final String? valor = await obtenerValor(clavePuerto);
    return int.tryParse(valor ?? '') ?? puertoPorDefecto;
  }

  Future<void> guardarPuerto(int puerto) =>
      guardarValor(clavePuerto, '$puerto');

  Stream<bool> watchModoMock() {
    return watchValor(claveModoMock).map(
      (String? valor) => valor == null ? true : valor == '1',
    );
  }

  Future<bool> obtenerModoMock() async {
    final String? valor = await obtenerValor(claveModoMock);
    return valor == null ? true : valor == '1';
  }

  Future<void> guardarModoMock(bool activo) =>
      guardarValor(claveModoMock, activo ? '1' : '0');

  Stream<int?> watchCapturaCuentaId() {
    return watchValor(claveCapturaCuenta).map(
      (String? valor) => int.tryParse(valor ?? ''),
    );
  }

  Future<int?> obtenerCapturaCuentaId() async {
    return int.tryParse(await obtenerValor(claveCapturaCuenta) ?? '');
  }

  Future<void> guardarCapturaCuentaId(int? cuentaId) async {
    if (cuentaId == null) {
      await (_db.delete(_db.configuracion)
            ..where((t) => t.clave.equals(claveCapturaCuenta)))
          .go();
      return;
    }
    await guardarValor(claveCapturaCuenta, '$cuentaId');
  }

  /// Crea los valores que deben existir desde el primer arranque de la Fase 2.
  Future<void> asegurarValoresIniciales() async {
    await obtenerOCrearToken();
    if (await obtenerValor(clavePuerto) == null) {
      await guardarPuerto(puertoPorDefecto);
    }
    if (await obtenerValor(claveModoMock) == null) {
      await guardarModoMock(true);
    }
    if (await obtenerValor(claveMonedaBase) == null) {
      await guardarMonedaBase(monedaBasePorDefecto);
    }
  }

  // ---------- genéricos ----------

  Stream<String?> watchValor(String clave) {
    return (_db.select(_db.configuracion)
          ..where((t) => t.clave.equals(clave)))
        .watchSingleOrNull()
        .map((ConfiguracionRow? fila) => fila?.valor);
  }

  Future<String?> obtenerValor(String clave) async {
    final ConfiguracionRow? fila = await (_db.select(_db.configuracion)
          ..where((t) => t.clave.equals(clave)))
        .getSingleOrNull();
    return fila?.valor;
  }

  Future<void> guardarValor(String clave, String valor) {
    return _db.into(_db.configuracion).insertOnConflictUpdate(
      ConfiguracionCompanion.insert(
        clave: clave,
        valor: valor,
        actualizadoEn: ahoraMs(),
      ),
    );
  }

  /// Token aleatorio de 64 caracteres hexadecimales.
  static String generarToken() {
    final Random random = Random.secure();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < 32; i++) {
      buffer.write(random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
