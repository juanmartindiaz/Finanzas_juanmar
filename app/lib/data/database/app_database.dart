import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'rutas_base_datos.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Base de datos local de "Gestor Finanzas" (SQLite con Drift).
///
/// - `schemaVersion = 2`: Fase 1 + `captura_entrante` (Fase 2 parte 1).
/// - La ruta del archivo se fija con [RutasBaseDatos.ruta] para que la apertura
///   y el respaldo previo a migrar apunten al mismo archivo.
/// - Llaves foráneas activas en cada apertura.
@DriftDatabase(
  tables: <Type>[
    Cuentas,
    Categorias,
    Subcategorias,
    Etiquetas,
    Transacciones,
    TransaccionEtiquetas,
    TasasCambio,
    Configuracion,
    Recibos,
    CapturaEntrante,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase()
    : super(
        driftDatabase(
          name: nombreBaseDatos,
          native: DriftNativeOptions(databasePath: RutasBaseDatos.ruta),
        ),
      );

  /// Constructor para pruebas con un ejecutor propio (archivo o memoria).
  AppDatabase.paraPruebas(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _crearIndices();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // v1 -> v2: solo se agrega la tabla de capturas. No se altera ninguna
        // tabla existente ni se tocan datos (DATA_MODEL.md §8.1).
        await m.createTable(capturaEntrante);
      }
      await _crearIndices();
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Índices que Drift no puede declarar como anotación (únicos parciales).
  Future<void> _crearIndices() async {
    const List<String> sentencias = <String>[
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_cuenta_nombre_vigente '
          'ON cuentas(nombre) WHERE eliminado_en IS NULL',
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_categoria_nombre_vigente '
          'ON categorias(nombre, naturaleza) WHERE eliminado_en IS NULL',
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_subcategoria_nombre_vigente '
          'ON subcategorias(categoria_id, nombre) WHERE eliminado_en IS NULL',
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_etiqueta_nombre_vigente '
          'ON etiquetas(nombre COLLATE NOCASE) WHERE eliminado_en IS NULL',
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_transaccion_recibo '
          'ON transacciones(recibo_id) WHERE recibo_id IS NOT NULL',
      'CREATE INDEX IF NOT EXISTS idx_transaccion_eliminado_fecha '
          'ON transacciones(eliminado_en, fecha)',
      'CREATE INDEX IF NOT EXISTS idx_transaccion_cuenta_fecha '
          'ON transacciones(cuenta_id, fecha)',
      'CREATE INDEX IF NOT EXISTS idx_transaccion_categoria_fecha '
          'ON transacciones(categoria_id, fecha)',
      'CREATE INDEX IF NOT EXISTS idx_transaccion_fecha_hora '
          'ON transacciones(fecha_hora)',
      'CREATE INDEX IF NOT EXISTS idx_transaccion_etiqueta_etiqueta '
          'ON transaccion_etiquetas(etiqueta_id)',
      'CREATE INDEX IF NOT EXISTS idx_subcategoria_categoria '
          'ON subcategorias(categoria_id)',
      'CREATE INDEX IF NOT EXISTS idx_cuenta_activa ON cuentas(activa)',
      'CREATE INDEX IF NOT EXISTS idx_recibo_estado ON recibos(estado)',
      // Fase 2: bandeja de capturas.
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_captura_message_id '
          'ON captura_entrante(message_id_externo) '
          'WHERE message_id_externo IS NOT NULL',
      'CREATE INDEX IF NOT EXISTS idx_captura_estado '
          'ON captura_entrante(estado, created_at)',
      'CREATE INDEX IF NOT EXISTS idx_captura_transaccion '
          'ON captura_entrante(transaccion_id)',
    ];
    for (final String sentencia in sentencias) {
      await customStatement(sentencia);
    }
  }
}
