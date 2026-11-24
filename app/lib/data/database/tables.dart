import 'package:drift/drift.dart';

/// Tablas de la Fase 1 (DATA_MODEL.md, §3 y §7).
///
/// Convenciones: montos en centavos enteros, fechas de calendario TEXT
/// `YYYY-MM-DD`, instantes INTEGER epoch ms, borrado lógico con `eliminadoEn`.

@DataClassName('CuentaRow')
class Cuentas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 60)();
  TextColumn get tipo => text().customConstraint(
    "NOT NULL CHECK (tipo IN ('efectivo','banco','nequi','daviplata',"
    "'tarjeta_credito','ahorro','inversion'))",
  )();
  IntColumn get saldoInicialCentavos =>
      integer().withDefault(const Constant(0))();
  TextColumn get moneda =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('COP'))();
  BoolColumn get activa => boolean().withDefault(const Constant(true))();
  TextColumn get nota => text().nullable()();
  IntColumn get creadoEn => integer()();
  IntColumn get actualizadoEn => integer()();
  IntColumn get eliminadoEn => integer().nullable()();
}

@DataClassName('CategoriaRow')
class Categorias extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 80)();
  TextColumn get naturaleza => text().customConstraint(
    "NOT NULL CHECK (naturaleza IN ('ingreso','gasto','ambos'))",
  )();
  TextColumn get icono => text().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get predefinida => boolean().withDefault(const Constant(false))();
  IntColumn get orden => integer().withDefault(const Constant(0))();
  BoolColumn get archivada => boolean().withDefault(const Constant(false))();
  IntColumn get creadoEn => integer()();
  IntColumn get actualizadoEn => integer()();
  IntColumn get eliminadoEn => integer().nullable()();
}

@DataClassName('SubcategoriaRow')
class Subcategorias extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoriaId => integer().references(Categorias, #id)();
  TextColumn get nombre => text().withLength(min: 1, max: 80)();
  BoolColumn get predefinida => boolean().withDefault(const Constant(false))();
  BoolColumn get archivada => boolean().withDefault(const Constant(false))();
  IntColumn get creadoEn => integer()();
  IntColumn get actualizadoEn => integer()();
  IntColumn get eliminadoEn => integer().nullable()();
}

@DataClassName('EtiquetaRow')
class Etiquetas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 40)();
  TextColumn get color => text().nullable()();
  IntColumn get creadoEn => integer()();
  IntColumn get actualizadoEn => integer()();
  IntColumn get eliminadoEn => integer().nullable()();
}

@DataClassName('TransaccionRow')
class Transacciones extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tipo => text().customConstraint(
    "NOT NULL CHECK (tipo IN ('ingreso','gasto','transferencia'))",
  )();
  IntColumn get montoCentavos =>
      integer().customConstraint('NOT NULL CHECK (monto_centavos > 0)')();
  TextColumn get moneda => text().withLength(min: 3, max: 3)();
  IntColumn get cuentaId => integer().references(Cuentas, #id)();
  IntColumn get cuentaDestinoId =>
      integer().nullable().references(Cuentas, #id)();
  IntColumn get montoDestinoCentavos => integer().nullable()();
  TextColumn get monedaDestino =>
      text().withLength(min: 3, max: 3).nullable()();
  IntColumn get categoriaId => integer().nullable().references(Categorias, #id)();
  IntColumn get subcategoriaId =>
      integer().nullable().references(Subcategorias, #id)();
  TextColumn get fecha => text()();
  IntColumn get fechaHora => integer()();
  TextColumn get nota => text().nullable()();
  IntColumn get reciboId => integer().nullable().references(Recibos, #id)();
  RealColumn get tasaCambio => real()
      .nullable()
      .customConstraint('CHECK (tasa_cambio IS NULL OR tasa_cambio > 0)')();
  TextColumn get estado => text().withDefault(const Constant('confirmada'))();
  TextColumn get origen => text().withDefault(const Constant('manual'))();
  IntColumn get creadoEn => integer()();
  IntColumn get actualizadoEn => integer()();
  IntColumn get eliminadoEn => integer().nullable()();

  @override
  List<String> get customConstraints => <String>[
    "CHECK (estado IN ('confirmada','pendiente'))",
    "CHECK (origen IN ('manual','bot','importado'))",
    'CHECK ('
        "(tipo = 'transferencia'"
        ' AND cuenta_destino_id IS NOT NULL'
        ' AND cuenta_destino_id <> cuenta_id'
        ' AND categoria_id IS NULL'
        ' AND monto_destino_centavos IS NOT NULL'
        ' AND monto_destino_centavos > 0'
        ' AND moneda_destino IS NOT NULL)'
        ' OR '
        "(tipo IN ('ingreso','gasto')"
        ' AND cuenta_destino_id IS NULL'
        ' AND monto_destino_centavos IS NULL'
        ' AND moneda_destino IS NULL'
        ' AND categoria_id IS NOT NULL))',
  ];
}

@DataClassName('TransaccionEtiquetaRow')
class TransaccionEtiquetas extends Table {
  IntColumn get transaccionId => integer().references(
    Transacciones,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get etiquetaId =>
      integer().references(Etiquetas, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{
    transaccionId,
    etiquetaId,
  };
}

@DataClassName('TasaCambioRow')
class TasasCambio extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get monedaOrigen => text().withLength(min: 3, max: 3)();
  TextColumn get monedaDestino => text().withLength(min: 3, max: 3)();
  RealColumn get valor =>
      real().customConstraint('NOT NULL CHECK (valor > 0)')();
  TextColumn get fecha => text()();
  TextColumn get fuente => text().customConstraint(
    "NOT NULL CHECK (fuente IN ('manual','trm','api_abierta'))",
  )();
  IntColumn get creadoEn => integer()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{monedaOrigen, monedaDestino, fecha},
  ];
}

@DataClassName('ConfiguracionRow')
class Configuracion extends Table {
  TextColumn get clave => text()();
  TextColumn get valor => text()();
  IntColumn get actualizadoEn => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{clave};
}

@DataClassName('ReciboRow')
class Recibos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get archivoPath => text()();
  TextColumn get archivoHash => text()();
  TextColumn get mime => text()();
  TextColumn get ocrTexto => text().nullable()();
  TextColumn get ocrJson => text().nullable()();
  TextColumn get estado => text().customConstraint(
    "NOT NULL CHECK (estado IN ('pendiente','confirmado','descartado'))",
  )();
  IntColumn get transaccionId =>
      integer().nullable().references(Transacciones, #id)();
  IntColumn get creadoEn => integer()();
  IntColumn get procesadoEn => integer().nullable()();
}

@DataClassName('CapturaRow')
class CapturaEntrante extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get canal => text().customConstraint(
    "NOT NULL CHECK (canal IN ('texto','audio','foto','app'))",
  )();
  TextColumn get origen => text().customConstraint(
    "NOT NULL CHECK (origen IN ('mock','bot','manual'))",
  )();
  TextColumn get messageIdExterno => text().nullable()();
  TextColumn get textoCrudo => text().nullable()();
  TextColumn get adjuntoPath => text().nullable()();
  TextColumn get estado => text().customConstraint(
    "NOT NULL DEFAULT 'pendiente' "
    "CHECK (estado IN ('pendiente','procesando','listo','confirmado',"
    "'descartado','error'))",
  )();
  TextColumn get propuestaJson => text().nullable()();
  TextColumn get errorDetalle => text().nullable()();
  IntColumn get transaccionId =>
      integer().nullable().references(Transacciones, #id)();
  /// `true` si se auto-registró usando valores por defecto (cuenta/categoría).
  BoolColumn get incompleta => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get procesadaAt => integer().nullable()();
}
