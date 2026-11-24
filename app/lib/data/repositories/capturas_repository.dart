import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/utils/fechas.dart';
import '../../domain/entities/captura.dart';
import '../../domain/entities/transaccion.dart';
import '../database/app_database.dart';
import 'transacciones_repository.dart';

/// Acceso a datos de la bandeja de capturas.
class CapturasRepository {
  CapturasRepository(this._db, this._transacciones);

  final AppDatabase _db;
  final TransaccionesRepository _transacciones;

  Stream<List<CapturaEntrante>> watchTodas() {
    final query = _db.select(_db.capturaEntrante)
      ..orderBy(<OrderingTerm Function($CapturaEntranteTable)>[
        ($CapturaEntranteTable t) =>
            OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
      (List<CapturaRow> filas) => filas.map(_aDominio).toList(),
    );
  }

  /// Capturas pendientes o listas (las que el usuario todavía no atendió).
  Stream<int> watchPendientes() {
    return _db
        .customSelect(
          "SELECT COUNT(*) AS total FROM captura_entrante "
          "WHERE estado IN ('pendiente','listo')",
          readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
            _db.capturaEntrante,
          },
        )
        .watchSingle()
        .map((QueryRow fila) => fila.read<int>('total'));
  }

  Future<List<CapturaEntrante>> obtenerTodas() async {
    final List<CapturaRow> filas = await (_db.select(
      _db.capturaEntrante,
    )..orderBy(<OrderingTerm Function($CapturaEntranteTable)>[
        ($CapturaEntranteTable t) =>
            OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]))
        .get();
    return filas.map(_aDominio).toList();
  }

  Future<CapturaEntrante?> obtener(int id) async {
    final CapturaRow? fila = await (_db.select(_db.capturaEntrante)
          ..where(($CapturaEntranteTable t) => t.id.equals(id)))
        .getSingleOrNull();
    return fila == null ? null : _aDominio(fila);
  }

  Future<CapturaEntrante?> buscarPorMessageId(String messageId) async {
    final CapturaRow? fila = await (_db.select(_db.capturaEntrante)
          ..where(
            ($CapturaEntranteTable t) => t.messageIdExterno.equals(messageId),
          ))
        .getSingleOrNull();
    return fila == null ? null : _aDominio(fila);
  }

  /// Captura manual desde la app; ya lleva propuesta del parser.
  Future<int> crearManualTexto({
    required String texto,
    required PropuestaCaptura propuesta,
    CanalCaptura canal = CanalCaptura.app,
    OrigenCaptura origen = OrigenCaptura.manual,
  }) {
    return _db.into(_db.capturaEntrante).insert(
          CapturaEntranteCompanion.insert(
            canal: canal.valorDb,
            origen: origen.valorDb,
            textoCrudo: Value<String>(texto),
            estado: Value<String>(EstadoCaptura.listo.valorDb),
            propuestaJson: Value<String>(jsonEncode(propuesta.toJson())),
            createdAt: ahoraMs(),
            procesadaAt: Value<int>(ahoraMs()),
          ),
        );
  }

  /// Captura que llega por el canal HTTP (bot o simulador).
  Future<int> crearDesdeCanal({
    required String messageId,
    required CanalCaptura canal,
    required EstadoCaptura estado,
    required OrigenCaptura origen,
    required int timestamp,
    String? texto,
    String? adjuntoPath,
    PropuestaCaptura? propuesta,
    bool incompleta = false,
  }) {
    return _db.into(_db.capturaEntrante).insert(
          CapturaEntranteCompanion.insert(
            canal: canal.valorDb,
            origen: origen.valorDb,
            messageIdExterno: Value<String>(messageId),
            textoCrudo: Value<String?>(texto),
            adjuntoPath: Value<String?>(adjuntoPath),
            estado: Value<String>(estado.valorDb),
            propuestaJson: Value<String?>(
              propuesta == null ? null : jsonEncode(propuesta.toJson()),
            ),
            incompleta: Value<bool>(incompleta),
            createdAt: timestamp,
            procesadaAt: Value<int?>(
              estado == EstadoCaptura.pendiente ? null : ahoraMs(),
            ),
          ),
        );
  }

  Future<void> actualizarPropuesta(int id, PropuestaCaptura propuesta) {
    return (_db.update(_db.capturaEntrante)
          ..where(($CapturaEntranteTable t) => t.id.equals(id)))
        .write(
      CapturaEntranteCompanion(
        propuestaJson: Value<String>(jsonEncode(propuesta.toJson())),
        estado: Value<String>(EstadoCaptura.listo.valorDb),
        procesadaAt: Value<int>(ahoraMs()),
      ),
    );
  }

  Future<void> marcarError(int id, String detalle) {
    return (_db.update(_db.capturaEntrante)
          ..where(($CapturaEntranteTable t) => t.id.equals(id)))
        .write(
      CapturaEntranteCompanion(
        estado: Value<String>(EstadoCaptura.error.valorDb),
        errorDetalle: Value<String>(detalle),
        procesadaAt: Value<int>(ahoraMs()),
      ),
    );
  }

  /// Confirma la captura creando la transacción real.
  ///
  /// Devuelve el id de la transacción. La transacción hereda `origen = bot`
  /// cuando la captura vino del bot o del simulador, y `manual` cuando se
  /// creó dentro de la app.
  Future<int> confirmar({
    required int capturaId,
    required TipoTransaccion tipo,
    required int montoCentavos,
    required String moneda,
    required int cuentaId,
    required String fecha,
    required int fechaHora,
    int? cuentaDestinoId,
    int? montoDestinoCentavos,
    String? monedaDestino,
    int? categoriaId,
    int? subcategoriaId,
    String? nota,
    double? tasaCambio,
    List<int> etiquetaIds = const <int>[],
    bool incompleta = false,
  }) async {
    final CapturaEntrante? captura = await obtener(capturaId);
    if (captura == null) {
      throw StateError('La captura $capturaId no existe.');
    }
    if (captura.estado == EstadoCaptura.confirmado) {
      throw StateError('La captura ya fue confirmada.');
    }
    final OrigenTransaccion origen = captura.origen == OrigenCaptura.manual
        ? OrigenTransaccion.manual
        : OrigenTransaccion.bot;

    final int transaccionId = await _db.transaction(() async {
      final int id = await _transacciones.crear(
        tipo: tipo,
        montoCentavos: montoCentavos,
        moneda: moneda,
        cuentaId: cuentaId,
        fecha: fecha,
        fechaHora: fechaHora,
        etiquetaIds: etiquetaIds,
        cuentaDestinoId: cuentaDestinoId,
        montoDestinoCentavos: montoDestinoCentavos,
        monedaDestino: monedaDestino,
        categoriaId: categoriaId,
        subcategoriaId: subcategoriaId,
        nota: nota,
        tasaCambio: tasaCambio,
        origen: origen,
      );
      await (_db.update(_db.capturaEntrante)
            ..where(($CapturaEntranteTable t) => t.id.equals(capturaId)))
          .write(
        CapturaEntranteCompanion(
          estado: Value<String>(EstadoCaptura.confirmado.valorDb),
          transaccionId: Value<int>(id),
          incompleta: Value<bool>(incompleta),
          procesadaAt: Value<int>(ahoraMs()),
        ),
      );
      return id;
    });
    return transaccionId;
  }

  Future<void> descartar(int id) {
    return (_db.update(_db.capturaEntrante)
          ..where(($CapturaEntranteTable t) => t.id.equals(id)))
        .write(
      CapturaEntranteCompanion(
        estado: Value<String>(EstadoCaptura.descartado.valorDb),
        procesadaAt: Value<int>(ahoraMs()),
      ),
    );
  }

  /// Cuenta de capturas abiertas (pendientes + listas).
  Future<int> contarPendientes() async {
    final QueryRow fila = await _db.customSelect(
      "SELECT COUNT(*) AS total FROM captura_entrante "
      "WHERE estado IN ('pendiente','listo')",
    ).getSingle();
    return fila.read<int>('total');
  }

  Future<int> contarPorEstado(EstadoCaptura estado) async {
    final QueryRow fila = await _db.customSelect(
      'SELECT COUNT(*) AS total FROM captura_entrante WHERE estado = ?1',
      variables: <Variable<Object>>[Variable.withString(estado.valorDb)],
    ).getSingle();
    return fila.read<int>('total');
  }
}

CapturaEntrante _aDominio(CapturaRow fila) {
  PropuestaCaptura? propuesta;
  final String? json = fila.propuestaJson;
  if (json != null && json.isNotEmpty) {
    try {
      final Object? decodificado = jsonDecode(json);
      if (decodificado is Map<String, Object?>) {
        propuesta = PropuestaCaptura.desdeJson(decodificado);
      } else if (decodificado is Map) {
        propuesta = PropuestaCaptura.desdeJson(
          decodificado.map(
            (Object? clave, Object? valor) => MapEntry<String, Object?>('$clave', valor),
          ),
        );
      }
    } on FormatException {
      propuesta = null;
    }
  }
  return CapturaEntrante(
    id: fila.id,
    canal: CanalCaptura.desdeDb(fila.canal),
    origen: OrigenCaptura.desdeDb(fila.origen),
    messageIdExterno: fila.messageIdExterno,
    textoCrudo: fila.textoCrudo,
    adjuntoPath: fila.adjuntoPath,
    estado: EstadoCaptura.desdeDb(fila.estado),
    propuesta: propuesta,
    errorDetalle: fila.errorDetalle,
    transaccionId: fila.transaccionId,
    createdAt: fila.createdAt,
    procesadaAt: fila.procesadaAt,
    incompleta: fila.incompleta,
  );
}
