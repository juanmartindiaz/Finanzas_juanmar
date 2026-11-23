import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Base de datos local de "Gestor Finanzas" (SQLite con Drift).
///
/// - `schemaVersion = 1`: esquema de la Fase 1.
/// - Llaves foráneas activas en cada apertura.
/// - Índices únicos parciales para que los nombres se puedan reutilizar después
///   de un borrado lógico (ver `_crearIndices`).
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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'gestor_finanzas'));

  /// Constructor para pruebas con un ejecutor propio (por ejemplo en memoria).
  AppDatabase.paraPruebas(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _crearIndices();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Fase 1: esquema inicial. Cuando exista una migración real, aquí se
      // copia antes el archivo SQLite (DATA_MODEL.md §8.1).
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
    ];
    for (final String sentencia in sentencias) {
      await customStatement(sentencia);
    }
  }
}
