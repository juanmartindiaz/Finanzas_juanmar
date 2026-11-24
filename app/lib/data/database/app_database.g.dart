// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CuentasTable extends Cuentas with TableInfo<$CuentasTable, CuentaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CuentasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (tipo IN (\'efectivo\',\'banco\',\'nequi\',\'daviplata\',\'tarjeta_credito\',\'ahorro\',\'inversion\'))',
  );
  static const VerificationMeta _saldoInicialCentavosMeta =
      const VerificationMeta('saldoInicialCentavos');
  @override
  late final GeneratedColumn<int> saldoInicialCentavos = GeneratedColumn<int>(
    'saldo_inicial_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _monedaMeta = const VerificationMeta('moneda');
  @override
  late final GeneratedColumn<String> moneda = GeneratedColumn<String>(
    'moneda',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('COP'),
  );
  static const VerificationMeta _activaMeta = const VerificationMeta('activa');
  @override
  late final GeneratedColumn<bool> activa = GeneratedColumn<bool>(
    'activa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activa" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<int> creadoEn = GeneratedColumn<int>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<int> actualizadoEn = GeneratedColumn<int>(
    'actualizado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eliminadoEnMeta = const VerificationMeta(
    'eliminadoEn',
  );
  @override
  late final GeneratedColumn<int> eliminadoEn = GeneratedColumn<int>(
    'eliminado_en',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    tipo,
    saldoInicialCentavos,
    moneda,
    activa,
    nota,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cuentas';
  @override
  VerificationContext validateIntegrity(
    Insertable<CuentaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('saldo_inicial_centavos')) {
      context.handle(
        _saldoInicialCentavosMeta,
        saldoInicialCentavos.isAcceptableOrUnknown(
          data['saldo_inicial_centavos']!,
          _saldoInicialCentavosMeta,
        ),
      );
    }
    if (data.containsKey('moneda')) {
      context.handle(
        _monedaMeta,
        moneda.isAcceptableOrUnknown(data['moneda']!, _monedaMeta),
      );
    }
    if (data.containsKey('activa')) {
      context.handle(
        _activaMeta,
        activa.isAcceptableOrUnknown(data['activa']!, _activaMeta),
      );
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadoEnMeta);
    }
    if (data.containsKey('eliminado_en')) {
      context.handle(
        _eliminadoEnMeta,
        eliminadoEn.isAcceptableOrUnknown(
          data['eliminado_en']!,
          _eliminadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CuentaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CuentaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      saldoInicialCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saldo_inicial_centavos'],
      )!,
      moneda: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moneda'],
      )!,
      activa: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activa'],
      )!,
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actualizado_en'],
      )!,
      eliminadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eliminado_en'],
      ),
    );
  }

  @override
  $CuentasTable createAlias(String alias) {
    return $CuentasTable(attachedDatabase, alias);
  }
}

class CuentaRow extends DataClass implements Insertable<CuentaRow> {
  final int id;
  final String nombre;
  final String tipo;
  final int saldoInicialCentavos;
  final String moneda;
  final bool activa;
  final String? nota;
  final int creadoEn;
  final int actualizadoEn;
  final int? eliminadoEn;
  const CuentaRow({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.saldoInicialCentavos,
    required this.moneda,
    required this.activa,
    this.nota,
    required this.creadoEn,
    required this.actualizadoEn,
    this.eliminadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['tipo'] = Variable<String>(tipo);
    map['saldo_inicial_centavos'] = Variable<int>(saldoInicialCentavos);
    map['moneda'] = Variable<String>(moneda);
    map['activa'] = Variable<bool>(activa);
    if (!nullToAbsent || nota != null) {
      map['nota'] = Variable<String>(nota);
    }
    map['creado_en'] = Variable<int>(creadoEn);
    map['actualizado_en'] = Variable<int>(actualizadoEn);
    if (!nullToAbsent || eliminadoEn != null) {
      map['eliminado_en'] = Variable<int>(eliminadoEn);
    }
    return map;
  }

  CuentasCompanion toCompanion(bool nullToAbsent) {
    return CuentasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      tipo: Value(tipo),
      saldoInicialCentavos: Value(saldoInicialCentavos),
      moneda: Value(moneda),
      activa: Value(activa),
      nota: nota == null && nullToAbsent ? const Value.absent() : Value(nota),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
      eliminadoEn: eliminadoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(eliminadoEn),
    );
  }

  factory CuentaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CuentaRow(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      tipo: serializer.fromJson<String>(json['tipo']),
      saldoInicialCentavos: serializer.fromJson<int>(
        json['saldoInicialCentavos'],
      ),
      moneda: serializer.fromJson<String>(json['moneda']),
      activa: serializer.fromJson<bool>(json['activa']),
      nota: serializer.fromJson<String?>(json['nota']),
      creadoEn: serializer.fromJson<int>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<int>(json['actualizadoEn']),
      eliminadoEn: serializer.fromJson<int?>(json['eliminadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'tipo': serializer.toJson<String>(tipo),
      'saldoInicialCentavos': serializer.toJson<int>(saldoInicialCentavos),
      'moneda': serializer.toJson<String>(moneda),
      'activa': serializer.toJson<bool>(activa),
      'nota': serializer.toJson<String?>(nota),
      'creadoEn': serializer.toJson<int>(creadoEn),
      'actualizadoEn': serializer.toJson<int>(actualizadoEn),
      'eliminadoEn': serializer.toJson<int?>(eliminadoEn),
    };
  }

  CuentaRow copyWith({
    int? id,
    String? nombre,
    String? tipo,
    int? saldoInicialCentavos,
    String? moneda,
    bool? activa,
    Value<String?> nota = const Value.absent(),
    int? creadoEn,
    int? actualizadoEn,
    Value<int?> eliminadoEn = const Value.absent(),
  }) => CuentaRow(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    tipo: tipo ?? this.tipo,
    saldoInicialCentavos: saldoInicialCentavos ?? this.saldoInicialCentavos,
    moneda: moneda ?? this.moneda,
    activa: activa ?? this.activa,
    nota: nota.present ? nota.value : this.nota,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    eliminadoEn: eliminadoEn.present ? eliminadoEn.value : this.eliminadoEn,
  );
  CuentaRow copyWithCompanion(CuentasCompanion data) {
    return CuentaRow(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      saldoInicialCentavos: data.saldoInicialCentavos.present
          ? data.saldoInicialCentavos.value
          : this.saldoInicialCentavos,
      moneda: data.moneda.present ? data.moneda.value : this.moneda,
      activa: data.activa.present ? data.activa.value : this.activa,
      nota: data.nota.present ? data.nota.value : this.nota,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
      eliminadoEn: data.eliminadoEn.present
          ? data.eliminadoEn.value
          : this.eliminadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CuentaRow(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('tipo: $tipo, ')
          ..write('saldoInicialCentavos: $saldoInicialCentavos, ')
          ..write('moneda: $moneda, ')
          ..write('activa: $activa, ')
          ..write('nota: $nota, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    tipo,
    saldoInicialCentavos,
    moneda,
    activa,
    nota,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CuentaRow &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.tipo == this.tipo &&
          other.saldoInicialCentavos == this.saldoInicialCentavos &&
          other.moneda == this.moneda &&
          other.activa == this.activa &&
          other.nota == this.nota &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn &&
          other.eliminadoEn == this.eliminadoEn);
}

class CuentasCompanion extends UpdateCompanion<CuentaRow> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String> tipo;
  final Value<int> saldoInicialCentavos;
  final Value<String> moneda;
  final Value<bool> activa;
  final Value<String?> nota;
  final Value<int> creadoEn;
  final Value<int> actualizadoEn;
  final Value<int?> eliminadoEn;
  const CuentasCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.tipo = const Value.absent(),
    this.saldoInicialCentavos = const Value.absent(),
    this.moneda = const Value.absent(),
    this.activa = const Value.absent(),
    this.nota = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.eliminadoEn = const Value.absent(),
  });
  CuentasCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required String tipo,
    this.saldoInicialCentavos = const Value.absent(),
    this.moneda = const Value.absent(),
    this.activa = const Value.absent(),
    this.nota = const Value.absent(),
    required int creadoEn,
    required int actualizadoEn,
    this.eliminadoEn = const Value.absent(),
  }) : nombre = Value(nombre),
       tipo = Value(tipo),
       creadoEn = Value(creadoEn),
       actualizadoEn = Value(actualizadoEn);
  static Insertable<CuentaRow> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? tipo,
    Expression<int>? saldoInicialCentavos,
    Expression<String>? moneda,
    Expression<bool>? activa,
    Expression<String>? nota,
    Expression<int>? creadoEn,
    Expression<int>? actualizadoEn,
    Expression<int>? eliminadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (tipo != null) 'tipo': tipo,
      if (saldoInicialCentavos != null)
        'saldo_inicial_centavos': saldoInicialCentavos,
      if (moneda != null) 'moneda': moneda,
      if (activa != null) 'activa': activa,
      if (nota != null) 'nota': nota,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (eliminadoEn != null) 'eliminado_en': eliminadoEn,
    });
  }

  CuentasCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String>? tipo,
    Value<int>? saldoInicialCentavos,
    Value<String>? moneda,
    Value<bool>? activa,
    Value<String?>? nota,
    Value<int>? creadoEn,
    Value<int>? actualizadoEn,
    Value<int?>? eliminadoEn,
  }) {
    return CuentasCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      saldoInicialCentavos: saldoInicialCentavos ?? this.saldoInicialCentavos,
      moneda: moneda ?? this.moneda,
      activa: activa ?? this.activa,
      nota: nota ?? this.nota,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      eliminadoEn: eliminadoEn ?? this.eliminadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (saldoInicialCentavos.present) {
      map['saldo_inicial_centavos'] = Variable<int>(saldoInicialCentavos.value);
    }
    if (moneda.present) {
      map['moneda'] = Variable<String>(moneda.value);
    }
    if (activa.present) {
      map['activa'] = Variable<bool>(activa.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<int>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<int>(actualizadoEn.value);
    }
    if (eliminadoEn.present) {
      map['eliminado_en'] = Variable<int>(eliminadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CuentasCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('tipo: $tipo, ')
          ..write('saldoInicialCentavos: $saldoInicialCentavos, ')
          ..write('moneda: $moneda, ')
          ..write('activa: $activa, ')
          ..write('nota: $nota, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }
}

class $CategoriasTable extends Categorias
    with TableInfo<$CategoriasTable, CategoriaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _naturalezaMeta = const VerificationMeta(
    'naturaleza',
  );
  @override
  late final GeneratedColumn<String> naturaleza = GeneratedColumn<String>(
    'naturaleza',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (naturaleza IN (\'ingreso\',\'gasto\',\'ambos\'))',
  );
  static const VerificationMeta _iconoMeta = const VerificationMeta('icono');
  @override
  late final GeneratedColumn<String> icono = GeneratedColumn<String>(
    'icono',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _predefinidaMeta = const VerificationMeta(
    'predefinida',
  );
  @override
  late final GeneratedColumn<bool> predefinida = GeneratedColumn<bool>(
    'predefinida',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("predefinida" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _archivadaMeta = const VerificationMeta(
    'archivada',
  );
  @override
  late final GeneratedColumn<bool> archivada = GeneratedColumn<bool>(
    'archivada',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archivada" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<int> creadoEn = GeneratedColumn<int>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<int> actualizadoEn = GeneratedColumn<int>(
    'actualizado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eliminadoEnMeta = const VerificationMeta(
    'eliminadoEn',
  );
  @override
  late final GeneratedColumn<int> eliminadoEn = GeneratedColumn<int>(
    'eliminado_en',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    naturaleza,
    icono,
    color,
    predefinida,
    orden,
    archivada,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorias';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoriaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('naturaleza')) {
      context.handle(
        _naturalezaMeta,
        naturaleza.isAcceptableOrUnknown(data['naturaleza']!, _naturalezaMeta),
      );
    } else if (isInserting) {
      context.missing(_naturalezaMeta);
    }
    if (data.containsKey('icono')) {
      context.handle(
        _iconoMeta,
        icono.isAcceptableOrUnknown(data['icono']!, _iconoMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('predefinida')) {
      context.handle(
        _predefinidaMeta,
        predefinida.isAcceptableOrUnknown(
          data['predefinida']!,
          _predefinidaMeta,
        ),
      );
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    }
    if (data.containsKey('archivada')) {
      context.handle(
        _archivadaMeta,
        archivada.isAcceptableOrUnknown(data['archivada']!, _archivadaMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadoEnMeta);
    }
    if (data.containsKey('eliminado_en')) {
      context.handle(
        _eliminadoEnMeta,
        eliminadoEn.isAcceptableOrUnknown(
          data['eliminado_en']!,
          _eliminadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoriaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoriaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      naturaleza: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naturaleza'],
      )!,
      icono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icono'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      predefinida: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}predefinida'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      archivada: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archivada'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actualizado_en'],
      )!,
      eliminadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eliminado_en'],
      ),
    );
  }

  @override
  $CategoriasTable createAlias(String alias) {
    return $CategoriasTable(attachedDatabase, alias);
  }
}

class CategoriaRow extends DataClass implements Insertable<CategoriaRow> {
  final int id;
  final String nombre;
  final String naturaleza;
  final String? icono;
  final String? color;
  final bool predefinida;
  final int orden;
  final bool archivada;
  final int creadoEn;
  final int actualizadoEn;
  final int? eliminadoEn;
  const CategoriaRow({
    required this.id,
    required this.nombre,
    required this.naturaleza,
    this.icono,
    this.color,
    required this.predefinida,
    required this.orden,
    required this.archivada,
    required this.creadoEn,
    required this.actualizadoEn,
    this.eliminadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['naturaleza'] = Variable<String>(naturaleza);
    if (!nullToAbsent || icono != null) {
      map['icono'] = Variable<String>(icono);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['predefinida'] = Variable<bool>(predefinida);
    map['orden'] = Variable<int>(orden);
    map['archivada'] = Variable<bool>(archivada);
    map['creado_en'] = Variable<int>(creadoEn);
    map['actualizado_en'] = Variable<int>(actualizadoEn);
    if (!nullToAbsent || eliminadoEn != null) {
      map['eliminado_en'] = Variable<int>(eliminadoEn);
    }
    return map;
  }

  CategoriasCompanion toCompanion(bool nullToAbsent) {
    return CategoriasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      naturaleza: Value(naturaleza),
      icono: icono == null && nullToAbsent
          ? const Value.absent()
          : Value(icono),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      predefinida: Value(predefinida),
      orden: Value(orden),
      archivada: Value(archivada),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
      eliminadoEn: eliminadoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(eliminadoEn),
    );
  }

  factory CategoriaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoriaRow(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      naturaleza: serializer.fromJson<String>(json['naturaleza']),
      icono: serializer.fromJson<String?>(json['icono']),
      color: serializer.fromJson<String?>(json['color']),
      predefinida: serializer.fromJson<bool>(json['predefinida']),
      orden: serializer.fromJson<int>(json['orden']),
      archivada: serializer.fromJson<bool>(json['archivada']),
      creadoEn: serializer.fromJson<int>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<int>(json['actualizadoEn']),
      eliminadoEn: serializer.fromJson<int?>(json['eliminadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'naturaleza': serializer.toJson<String>(naturaleza),
      'icono': serializer.toJson<String?>(icono),
      'color': serializer.toJson<String?>(color),
      'predefinida': serializer.toJson<bool>(predefinida),
      'orden': serializer.toJson<int>(orden),
      'archivada': serializer.toJson<bool>(archivada),
      'creadoEn': serializer.toJson<int>(creadoEn),
      'actualizadoEn': serializer.toJson<int>(actualizadoEn),
      'eliminadoEn': serializer.toJson<int?>(eliminadoEn),
    };
  }

  CategoriaRow copyWith({
    int? id,
    String? nombre,
    String? naturaleza,
    Value<String?> icono = const Value.absent(),
    Value<String?> color = const Value.absent(),
    bool? predefinida,
    int? orden,
    bool? archivada,
    int? creadoEn,
    int? actualizadoEn,
    Value<int?> eliminadoEn = const Value.absent(),
  }) => CategoriaRow(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    naturaleza: naturaleza ?? this.naturaleza,
    icono: icono.present ? icono.value : this.icono,
    color: color.present ? color.value : this.color,
    predefinida: predefinida ?? this.predefinida,
    orden: orden ?? this.orden,
    archivada: archivada ?? this.archivada,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    eliminadoEn: eliminadoEn.present ? eliminadoEn.value : this.eliminadoEn,
  );
  CategoriaRow copyWithCompanion(CategoriasCompanion data) {
    return CategoriaRow(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      naturaleza: data.naturaleza.present
          ? data.naturaleza.value
          : this.naturaleza,
      icono: data.icono.present ? data.icono.value : this.icono,
      color: data.color.present ? data.color.value : this.color,
      predefinida: data.predefinida.present
          ? data.predefinida.value
          : this.predefinida,
      orden: data.orden.present ? data.orden.value : this.orden,
      archivada: data.archivada.present ? data.archivada.value : this.archivada,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
      eliminadoEn: data.eliminadoEn.present
          ? data.eliminadoEn.value
          : this.eliminadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoriaRow(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('naturaleza: $naturaleza, ')
          ..write('icono: $icono, ')
          ..write('color: $color, ')
          ..write('predefinida: $predefinida, ')
          ..write('orden: $orden, ')
          ..write('archivada: $archivada, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    naturaleza,
    icono,
    color,
    predefinida,
    orden,
    archivada,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoriaRow &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.naturaleza == this.naturaleza &&
          other.icono == this.icono &&
          other.color == this.color &&
          other.predefinida == this.predefinida &&
          other.orden == this.orden &&
          other.archivada == this.archivada &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn &&
          other.eliminadoEn == this.eliminadoEn);
}

class CategoriasCompanion extends UpdateCompanion<CategoriaRow> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String> naturaleza;
  final Value<String?> icono;
  final Value<String?> color;
  final Value<bool> predefinida;
  final Value<int> orden;
  final Value<bool> archivada;
  final Value<int> creadoEn;
  final Value<int> actualizadoEn;
  final Value<int?> eliminadoEn;
  const CategoriasCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.naturaleza = const Value.absent(),
    this.icono = const Value.absent(),
    this.color = const Value.absent(),
    this.predefinida = const Value.absent(),
    this.orden = const Value.absent(),
    this.archivada = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.eliminadoEn = const Value.absent(),
  });
  CategoriasCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required String naturaleza,
    this.icono = const Value.absent(),
    this.color = const Value.absent(),
    this.predefinida = const Value.absent(),
    this.orden = const Value.absent(),
    this.archivada = const Value.absent(),
    required int creadoEn,
    required int actualizadoEn,
    this.eliminadoEn = const Value.absent(),
  }) : nombre = Value(nombre),
       naturaleza = Value(naturaleza),
       creadoEn = Value(creadoEn),
       actualizadoEn = Value(actualizadoEn);
  static Insertable<CategoriaRow> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? naturaleza,
    Expression<String>? icono,
    Expression<String>? color,
    Expression<bool>? predefinida,
    Expression<int>? orden,
    Expression<bool>? archivada,
    Expression<int>? creadoEn,
    Expression<int>? actualizadoEn,
    Expression<int>? eliminadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (naturaleza != null) 'naturaleza': naturaleza,
      if (icono != null) 'icono': icono,
      if (color != null) 'color': color,
      if (predefinida != null) 'predefinida': predefinida,
      if (orden != null) 'orden': orden,
      if (archivada != null) 'archivada': archivada,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (eliminadoEn != null) 'eliminado_en': eliminadoEn,
    });
  }

  CategoriasCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String>? naturaleza,
    Value<String?>? icono,
    Value<String?>? color,
    Value<bool>? predefinida,
    Value<int>? orden,
    Value<bool>? archivada,
    Value<int>? creadoEn,
    Value<int>? actualizadoEn,
    Value<int?>? eliminadoEn,
  }) {
    return CategoriasCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      naturaleza: naturaleza ?? this.naturaleza,
      icono: icono ?? this.icono,
      color: color ?? this.color,
      predefinida: predefinida ?? this.predefinida,
      orden: orden ?? this.orden,
      archivada: archivada ?? this.archivada,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      eliminadoEn: eliminadoEn ?? this.eliminadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (naturaleza.present) {
      map['naturaleza'] = Variable<String>(naturaleza.value);
    }
    if (icono.present) {
      map['icono'] = Variable<String>(icono.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (predefinida.present) {
      map['predefinida'] = Variable<bool>(predefinida.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (archivada.present) {
      map['archivada'] = Variable<bool>(archivada.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<int>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<int>(actualizadoEn.value);
    }
    if (eliminadoEn.present) {
      map['eliminado_en'] = Variable<int>(eliminadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriasCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('naturaleza: $naturaleza, ')
          ..write('icono: $icono, ')
          ..write('color: $color, ')
          ..write('predefinida: $predefinida, ')
          ..write('orden: $orden, ')
          ..write('archivada: $archivada, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }
}

class $SubcategoriasTable extends Subcategorias
    with TableInfo<$SubcategoriasTable, SubcategoriaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubcategoriasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
    'categoria_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categorias (id)',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _predefinidaMeta = const VerificationMeta(
    'predefinida',
  );
  @override
  late final GeneratedColumn<bool> predefinida = GeneratedColumn<bool>(
    'predefinida',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("predefinida" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivadaMeta = const VerificationMeta(
    'archivada',
  );
  @override
  late final GeneratedColumn<bool> archivada = GeneratedColumn<bool>(
    'archivada',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archivada" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<int> creadoEn = GeneratedColumn<int>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<int> actualizadoEn = GeneratedColumn<int>(
    'actualizado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eliminadoEnMeta = const VerificationMeta(
    'eliminadoEn',
  );
  @override
  late final GeneratedColumn<int> eliminadoEn = GeneratedColumn<int>(
    'eliminado_en',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoriaId,
    nombre,
    predefinida,
    archivada,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subcategorias';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubcategoriaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoriaIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('predefinida')) {
      context.handle(
        _predefinidaMeta,
        predefinida.isAcceptableOrUnknown(
          data['predefinida']!,
          _predefinidaMeta,
        ),
      );
    }
    if (data.containsKey('archivada')) {
      context.handle(
        _archivadaMeta,
        archivada.isAcceptableOrUnknown(data['archivada']!, _archivadaMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadoEnMeta);
    }
    if (data.containsKey('eliminado_en')) {
      context.handle(
        _eliminadoEnMeta,
        eliminadoEn.isAcceptableOrUnknown(
          data['eliminado_en']!,
          _eliminadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubcategoriaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubcategoriaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      predefinida: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}predefinida'],
      )!,
      archivada: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archivada'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actualizado_en'],
      )!,
      eliminadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eliminado_en'],
      ),
    );
  }

  @override
  $SubcategoriasTable createAlias(String alias) {
    return $SubcategoriasTable(attachedDatabase, alias);
  }
}

class SubcategoriaRow extends DataClass implements Insertable<SubcategoriaRow> {
  final int id;
  final int categoriaId;
  final String nombre;
  final bool predefinida;
  final bool archivada;
  final int creadoEn;
  final int actualizadoEn;
  final int? eliminadoEn;
  const SubcategoriaRow({
    required this.id,
    required this.categoriaId,
    required this.nombre,
    required this.predefinida,
    required this.archivada,
    required this.creadoEn,
    required this.actualizadoEn,
    this.eliminadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['categoria_id'] = Variable<int>(categoriaId);
    map['nombre'] = Variable<String>(nombre);
    map['predefinida'] = Variable<bool>(predefinida);
    map['archivada'] = Variable<bool>(archivada);
    map['creado_en'] = Variable<int>(creadoEn);
    map['actualizado_en'] = Variable<int>(actualizadoEn);
    if (!nullToAbsent || eliminadoEn != null) {
      map['eliminado_en'] = Variable<int>(eliminadoEn);
    }
    return map;
  }

  SubcategoriasCompanion toCompanion(bool nullToAbsent) {
    return SubcategoriasCompanion(
      id: Value(id),
      categoriaId: Value(categoriaId),
      nombre: Value(nombre),
      predefinida: Value(predefinida),
      archivada: Value(archivada),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
      eliminadoEn: eliminadoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(eliminadoEn),
    );
  }

  factory SubcategoriaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubcategoriaRow(
      id: serializer.fromJson<int>(json['id']),
      categoriaId: serializer.fromJson<int>(json['categoriaId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      predefinida: serializer.fromJson<bool>(json['predefinida']),
      archivada: serializer.fromJson<bool>(json['archivada']),
      creadoEn: serializer.fromJson<int>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<int>(json['actualizadoEn']),
      eliminadoEn: serializer.fromJson<int?>(json['eliminadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoriaId': serializer.toJson<int>(categoriaId),
      'nombre': serializer.toJson<String>(nombre),
      'predefinida': serializer.toJson<bool>(predefinida),
      'archivada': serializer.toJson<bool>(archivada),
      'creadoEn': serializer.toJson<int>(creadoEn),
      'actualizadoEn': serializer.toJson<int>(actualizadoEn),
      'eliminadoEn': serializer.toJson<int?>(eliminadoEn),
    };
  }

  SubcategoriaRow copyWith({
    int? id,
    int? categoriaId,
    String? nombre,
    bool? predefinida,
    bool? archivada,
    int? creadoEn,
    int? actualizadoEn,
    Value<int?> eliminadoEn = const Value.absent(),
  }) => SubcategoriaRow(
    id: id ?? this.id,
    categoriaId: categoriaId ?? this.categoriaId,
    nombre: nombre ?? this.nombre,
    predefinida: predefinida ?? this.predefinida,
    archivada: archivada ?? this.archivada,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    eliminadoEn: eliminadoEn.present ? eliminadoEn.value : this.eliminadoEn,
  );
  SubcategoriaRow copyWithCompanion(SubcategoriasCompanion data) {
    return SubcategoriaRow(
      id: data.id.present ? data.id.value : this.id,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      predefinida: data.predefinida.present
          ? data.predefinida.value
          : this.predefinida,
      archivada: data.archivada.present ? data.archivada.value : this.archivada,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
      eliminadoEn: data.eliminadoEn.present
          ? data.eliminadoEn.value
          : this.eliminadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubcategoriaRow(')
          ..write('id: $id, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('nombre: $nombre, ')
          ..write('predefinida: $predefinida, ')
          ..write('archivada: $archivada, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoriaId,
    nombre,
    predefinida,
    archivada,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubcategoriaRow &&
          other.id == this.id &&
          other.categoriaId == this.categoriaId &&
          other.nombre == this.nombre &&
          other.predefinida == this.predefinida &&
          other.archivada == this.archivada &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn &&
          other.eliminadoEn == this.eliminadoEn);
}

class SubcategoriasCompanion extends UpdateCompanion<SubcategoriaRow> {
  final Value<int> id;
  final Value<int> categoriaId;
  final Value<String> nombre;
  final Value<bool> predefinida;
  final Value<bool> archivada;
  final Value<int> creadoEn;
  final Value<int> actualizadoEn;
  final Value<int?> eliminadoEn;
  const SubcategoriasCompanion({
    this.id = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.predefinida = const Value.absent(),
    this.archivada = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.eliminadoEn = const Value.absent(),
  });
  SubcategoriasCompanion.insert({
    this.id = const Value.absent(),
    required int categoriaId,
    required String nombre,
    this.predefinida = const Value.absent(),
    this.archivada = const Value.absent(),
    required int creadoEn,
    required int actualizadoEn,
    this.eliminadoEn = const Value.absent(),
  }) : categoriaId = Value(categoriaId),
       nombre = Value(nombre),
       creadoEn = Value(creadoEn),
       actualizadoEn = Value(actualizadoEn);
  static Insertable<SubcategoriaRow> custom({
    Expression<int>? id,
    Expression<int>? categoriaId,
    Expression<String>? nombre,
    Expression<bool>? predefinida,
    Expression<bool>? archivada,
    Expression<int>? creadoEn,
    Expression<int>? actualizadoEn,
    Expression<int>? eliminadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (nombre != null) 'nombre': nombre,
      if (predefinida != null) 'predefinida': predefinida,
      if (archivada != null) 'archivada': archivada,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (eliminadoEn != null) 'eliminado_en': eliminadoEn,
    });
  }

  SubcategoriasCompanion copyWith({
    Value<int>? id,
    Value<int>? categoriaId,
    Value<String>? nombre,
    Value<bool>? predefinida,
    Value<bool>? archivada,
    Value<int>? creadoEn,
    Value<int>? actualizadoEn,
    Value<int?>? eliminadoEn,
  }) {
    return SubcategoriasCompanion(
      id: id ?? this.id,
      categoriaId: categoriaId ?? this.categoriaId,
      nombre: nombre ?? this.nombre,
      predefinida: predefinida ?? this.predefinida,
      archivada: archivada ?? this.archivada,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      eliminadoEn: eliminadoEn ?? this.eliminadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (predefinida.present) {
      map['predefinida'] = Variable<bool>(predefinida.value);
    }
    if (archivada.present) {
      map['archivada'] = Variable<bool>(archivada.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<int>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<int>(actualizadoEn.value);
    }
    if (eliminadoEn.present) {
      map['eliminado_en'] = Variable<int>(eliminadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubcategoriasCompanion(')
          ..write('id: $id, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('nombre: $nombre, ')
          ..write('predefinida: $predefinida, ')
          ..write('archivada: $archivada, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }
}

class $EtiquetasTable extends Etiquetas
    with TableInfo<$EtiquetasTable, EtiquetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EtiquetasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<int> creadoEn = GeneratedColumn<int>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<int> actualizadoEn = GeneratedColumn<int>(
    'actualizado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eliminadoEnMeta = const VerificationMeta(
    'eliminadoEn',
  );
  @override
  late final GeneratedColumn<int> eliminadoEn = GeneratedColumn<int>(
    'eliminado_en',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    color,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'etiquetas';
  @override
  VerificationContext validateIntegrity(
    Insertable<EtiquetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadoEnMeta);
    }
    if (data.containsKey('eliminado_en')) {
      context.handle(
        _eliminadoEnMeta,
        eliminadoEn.isAcceptableOrUnknown(
          data['eliminado_en']!,
          _eliminadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EtiquetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EtiquetaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actualizado_en'],
      )!,
      eliminadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eliminado_en'],
      ),
    );
  }

  @override
  $EtiquetasTable createAlias(String alias) {
    return $EtiquetasTable(attachedDatabase, alias);
  }
}

class EtiquetaRow extends DataClass implements Insertable<EtiquetaRow> {
  final int id;
  final String nombre;
  final String? color;
  final int creadoEn;
  final int actualizadoEn;
  final int? eliminadoEn;
  const EtiquetaRow({
    required this.id,
    required this.nombre,
    this.color,
    required this.creadoEn,
    required this.actualizadoEn,
    this.eliminadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['creado_en'] = Variable<int>(creadoEn);
    map['actualizado_en'] = Variable<int>(actualizadoEn);
    if (!nullToAbsent || eliminadoEn != null) {
      map['eliminado_en'] = Variable<int>(eliminadoEn);
    }
    return map;
  }

  EtiquetasCompanion toCompanion(bool nullToAbsent) {
    return EtiquetasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
      eliminadoEn: eliminadoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(eliminadoEn),
    );
  }

  factory EtiquetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EtiquetaRow(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      color: serializer.fromJson<String?>(json['color']),
      creadoEn: serializer.fromJson<int>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<int>(json['actualizadoEn']),
      eliminadoEn: serializer.fromJson<int?>(json['eliminadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'color': serializer.toJson<String?>(color),
      'creadoEn': serializer.toJson<int>(creadoEn),
      'actualizadoEn': serializer.toJson<int>(actualizadoEn),
      'eliminadoEn': serializer.toJson<int?>(eliminadoEn),
    };
  }

  EtiquetaRow copyWith({
    int? id,
    String? nombre,
    Value<String?> color = const Value.absent(),
    int? creadoEn,
    int? actualizadoEn,
    Value<int?> eliminadoEn = const Value.absent(),
  }) => EtiquetaRow(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    color: color.present ? color.value : this.color,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    eliminadoEn: eliminadoEn.present ? eliminadoEn.value : this.eliminadoEn,
  );
  EtiquetaRow copyWithCompanion(EtiquetasCompanion data) {
    return EtiquetaRow(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      color: data.color.present ? data.color.value : this.color,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
      eliminadoEn: data.eliminadoEn.present
          ? data.eliminadoEn.value
          : this.eliminadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EtiquetaRow(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('color: $color, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nombre, color, creadoEn, actualizadoEn, eliminadoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EtiquetaRow &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.color == this.color &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn &&
          other.eliminadoEn == this.eliminadoEn);
}

class EtiquetasCompanion extends UpdateCompanion<EtiquetaRow> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String?> color;
  final Value<int> creadoEn;
  final Value<int> actualizadoEn;
  final Value<int?> eliminadoEn;
  const EtiquetasCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.color = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.eliminadoEn = const Value.absent(),
  });
  EtiquetasCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.color = const Value.absent(),
    required int creadoEn,
    required int actualizadoEn,
    this.eliminadoEn = const Value.absent(),
  }) : nombre = Value(nombre),
       creadoEn = Value(creadoEn),
       actualizadoEn = Value(actualizadoEn);
  static Insertable<EtiquetaRow> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? color,
    Expression<int>? creadoEn,
    Expression<int>? actualizadoEn,
    Expression<int>? eliminadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (color != null) 'color': color,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (eliminadoEn != null) 'eliminado_en': eliminadoEn,
    });
  }

  EtiquetasCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String?>? color,
    Value<int>? creadoEn,
    Value<int>? actualizadoEn,
    Value<int?>? eliminadoEn,
  }) {
    return EtiquetasCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      color: color ?? this.color,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      eliminadoEn: eliminadoEn ?? this.eliminadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<int>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<int>(actualizadoEn.value);
    }
    if (eliminadoEn.present) {
      map['eliminado_en'] = Variable<int>(eliminadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EtiquetasCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('color: $color, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }
}

class $RecibosTable extends Recibos with TableInfo<$RecibosTable, ReciboRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecibosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _archivoPathMeta = const VerificationMeta(
    'archivoPath',
  );
  @override
  late final GeneratedColumn<String> archivoPath = GeneratedColumn<String>(
    'archivo_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivoHashMeta = const VerificationMeta(
    'archivoHash',
  );
  @override
  late final GeneratedColumn<String> archivoHash = GeneratedColumn<String>(
    'archivo_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ocrTextoMeta = const VerificationMeta(
    'ocrTexto',
  );
  @override
  late final GeneratedColumn<String> ocrTexto = GeneratedColumn<String>(
    'ocr_texto',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrJsonMeta = const VerificationMeta(
    'ocrJson',
  );
  @override
  late final GeneratedColumn<String> ocrJson = GeneratedColumn<String>(
    'ocr_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (estado IN (\'pendiente\',\'confirmado\',\'descartado\'))',
  );
  static const VerificationMeta _transaccionIdMeta = const VerificationMeta(
    'transaccionId',
  );
  @override
  late final GeneratedColumn<int> transaccionId = GeneratedColumn<int>(
    'transaccion_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transacciones (id)',
    ),
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<int> creadoEn = GeneratedColumn<int>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _procesadoEnMeta = const VerificationMeta(
    'procesadoEn',
  );
  @override
  late final GeneratedColumn<int> procesadoEn = GeneratedColumn<int>(
    'procesado_en',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    archivoPath,
    archivoHash,
    mime,
    ocrTexto,
    ocrJson,
    estado,
    transaccionId,
    creadoEn,
    procesadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recibos';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReciboRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('archivo_path')) {
      context.handle(
        _archivoPathMeta,
        archivoPath.isAcceptableOrUnknown(
          data['archivo_path']!,
          _archivoPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_archivoPathMeta);
    }
    if (data.containsKey('archivo_hash')) {
      context.handle(
        _archivoHashMeta,
        archivoHash.isAcceptableOrUnknown(
          data['archivo_hash']!,
          _archivoHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_archivoHashMeta);
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeMeta);
    }
    if (data.containsKey('ocr_texto')) {
      context.handle(
        _ocrTextoMeta,
        ocrTexto.isAcceptableOrUnknown(data['ocr_texto']!, _ocrTextoMeta),
      );
    }
    if (data.containsKey('ocr_json')) {
      context.handle(
        _ocrJsonMeta,
        ocrJson.isAcceptableOrUnknown(data['ocr_json']!, _ocrJsonMeta),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('transaccion_id')) {
      context.handle(
        _transaccionIdMeta,
        transaccionId.isAcceptableOrUnknown(
          data['transaccion_id']!,
          _transaccionIdMeta,
        ),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('procesado_en')) {
      context.handle(
        _procesadoEnMeta,
        procesadoEn.isAcceptableOrUnknown(
          data['procesado_en']!,
          _procesadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReciboRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReciboRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      archivoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archivo_path'],
      )!,
      archivoHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archivo_hash'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      )!,
      ocrTexto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_texto'],
      ),
      ocrJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_json'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      transaccionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaccion_id'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creado_en'],
      )!,
      procesadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}procesado_en'],
      ),
    );
  }

  @override
  $RecibosTable createAlias(String alias) {
    return $RecibosTable(attachedDatabase, alias);
  }
}

class ReciboRow extends DataClass implements Insertable<ReciboRow> {
  final int id;
  final String archivoPath;
  final String archivoHash;
  final String mime;
  final String? ocrTexto;
  final String? ocrJson;
  final String estado;
  final int? transaccionId;
  final int creadoEn;
  final int? procesadoEn;
  const ReciboRow({
    required this.id,
    required this.archivoPath,
    required this.archivoHash,
    required this.mime,
    this.ocrTexto,
    this.ocrJson,
    required this.estado,
    this.transaccionId,
    required this.creadoEn,
    this.procesadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['archivo_path'] = Variable<String>(archivoPath);
    map['archivo_hash'] = Variable<String>(archivoHash);
    map['mime'] = Variable<String>(mime);
    if (!nullToAbsent || ocrTexto != null) {
      map['ocr_texto'] = Variable<String>(ocrTexto);
    }
    if (!nullToAbsent || ocrJson != null) {
      map['ocr_json'] = Variable<String>(ocrJson);
    }
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || transaccionId != null) {
      map['transaccion_id'] = Variable<int>(transaccionId);
    }
    map['creado_en'] = Variable<int>(creadoEn);
    if (!nullToAbsent || procesadoEn != null) {
      map['procesado_en'] = Variable<int>(procesadoEn);
    }
    return map;
  }

  RecibosCompanion toCompanion(bool nullToAbsent) {
    return RecibosCompanion(
      id: Value(id),
      archivoPath: Value(archivoPath),
      archivoHash: Value(archivoHash),
      mime: Value(mime),
      ocrTexto: ocrTexto == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrTexto),
      ocrJson: ocrJson == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrJson),
      estado: Value(estado),
      transaccionId: transaccionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transaccionId),
      creadoEn: Value(creadoEn),
      procesadoEn: procesadoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(procesadoEn),
    );
  }

  factory ReciboRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReciboRow(
      id: serializer.fromJson<int>(json['id']),
      archivoPath: serializer.fromJson<String>(json['archivoPath']),
      archivoHash: serializer.fromJson<String>(json['archivoHash']),
      mime: serializer.fromJson<String>(json['mime']),
      ocrTexto: serializer.fromJson<String?>(json['ocrTexto']),
      ocrJson: serializer.fromJson<String?>(json['ocrJson']),
      estado: serializer.fromJson<String>(json['estado']),
      transaccionId: serializer.fromJson<int?>(json['transaccionId']),
      creadoEn: serializer.fromJson<int>(json['creadoEn']),
      procesadoEn: serializer.fromJson<int?>(json['procesadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'archivoPath': serializer.toJson<String>(archivoPath),
      'archivoHash': serializer.toJson<String>(archivoHash),
      'mime': serializer.toJson<String>(mime),
      'ocrTexto': serializer.toJson<String?>(ocrTexto),
      'ocrJson': serializer.toJson<String?>(ocrJson),
      'estado': serializer.toJson<String>(estado),
      'transaccionId': serializer.toJson<int?>(transaccionId),
      'creadoEn': serializer.toJson<int>(creadoEn),
      'procesadoEn': serializer.toJson<int?>(procesadoEn),
    };
  }

  ReciboRow copyWith({
    int? id,
    String? archivoPath,
    String? archivoHash,
    String? mime,
    Value<String?> ocrTexto = const Value.absent(),
    Value<String?> ocrJson = const Value.absent(),
    String? estado,
    Value<int?> transaccionId = const Value.absent(),
    int? creadoEn,
    Value<int?> procesadoEn = const Value.absent(),
  }) => ReciboRow(
    id: id ?? this.id,
    archivoPath: archivoPath ?? this.archivoPath,
    archivoHash: archivoHash ?? this.archivoHash,
    mime: mime ?? this.mime,
    ocrTexto: ocrTexto.present ? ocrTexto.value : this.ocrTexto,
    ocrJson: ocrJson.present ? ocrJson.value : this.ocrJson,
    estado: estado ?? this.estado,
    transaccionId: transaccionId.present
        ? transaccionId.value
        : this.transaccionId,
    creadoEn: creadoEn ?? this.creadoEn,
    procesadoEn: procesadoEn.present ? procesadoEn.value : this.procesadoEn,
  );
  ReciboRow copyWithCompanion(RecibosCompanion data) {
    return ReciboRow(
      id: data.id.present ? data.id.value : this.id,
      archivoPath: data.archivoPath.present
          ? data.archivoPath.value
          : this.archivoPath,
      archivoHash: data.archivoHash.present
          ? data.archivoHash.value
          : this.archivoHash,
      mime: data.mime.present ? data.mime.value : this.mime,
      ocrTexto: data.ocrTexto.present ? data.ocrTexto.value : this.ocrTexto,
      ocrJson: data.ocrJson.present ? data.ocrJson.value : this.ocrJson,
      estado: data.estado.present ? data.estado.value : this.estado,
      transaccionId: data.transaccionId.present
          ? data.transaccionId.value
          : this.transaccionId,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      procesadoEn: data.procesadoEn.present
          ? data.procesadoEn.value
          : this.procesadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReciboRow(')
          ..write('id: $id, ')
          ..write('archivoPath: $archivoPath, ')
          ..write('archivoHash: $archivoHash, ')
          ..write('mime: $mime, ')
          ..write('ocrTexto: $ocrTexto, ')
          ..write('ocrJson: $ocrJson, ')
          ..write('estado: $estado, ')
          ..write('transaccionId: $transaccionId, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('procesadoEn: $procesadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    archivoPath,
    archivoHash,
    mime,
    ocrTexto,
    ocrJson,
    estado,
    transaccionId,
    creadoEn,
    procesadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReciboRow &&
          other.id == this.id &&
          other.archivoPath == this.archivoPath &&
          other.archivoHash == this.archivoHash &&
          other.mime == this.mime &&
          other.ocrTexto == this.ocrTexto &&
          other.ocrJson == this.ocrJson &&
          other.estado == this.estado &&
          other.transaccionId == this.transaccionId &&
          other.creadoEn == this.creadoEn &&
          other.procesadoEn == this.procesadoEn);
}

class RecibosCompanion extends UpdateCompanion<ReciboRow> {
  final Value<int> id;
  final Value<String> archivoPath;
  final Value<String> archivoHash;
  final Value<String> mime;
  final Value<String?> ocrTexto;
  final Value<String?> ocrJson;
  final Value<String> estado;
  final Value<int?> transaccionId;
  final Value<int> creadoEn;
  final Value<int?> procesadoEn;
  const RecibosCompanion({
    this.id = const Value.absent(),
    this.archivoPath = const Value.absent(),
    this.archivoHash = const Value.absent(),
    this.mime = const Value.absent(),
    this.ocrTexto = const Value.absent(),
    this.ocrJson = const Value.absent(),
    this.estado = const Value.absent(),
    this.transaccionId = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.procesadoEn = const Value.absent(),
  });
  RecibosCompanion.insert({
    this.id = const Value.absent(),
    required String archivoPath,
    required String archivoHash,
    required String mime,
    this.ocrTexto = const Value.absent(),
    this.ocrJson = const Value.absent(),
    required String estado,
    this.transaccionId = const Value.absent(),
    required int creadoEn,
    this.procesadoEn = const Value.absent(),
  }) : archivoPath = Value(archivoPath),
       archivoHash = Value(archivoHash),
       mime = Value(mime),
       estado = Value(estado),
       creadoEn = Value(creadoEn);
  static Insertable<ReciboRow> custom({
    Expression<int>? id,
    Expression<String>? archivoPath,
    Expression<String>? archivoHash,
    Expression<String>? mime,
    Expression<String>? ocrTexto,
    Expression<String>? ocrJson,
    Expression<String>? estado,
    Expression<int>? transaccionId,
    Expression<int>? creadoEn,
    Expression<int>? procesadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (archivoPath != null) 'archivo_path': archivoPath,
      if (archivoHash != null) 'archivo_hash': archivoHash,
      if (mime != null) 'mime': mime,
      if (ocrTexto != null) 'ocr_texto': ocrTexto,
      if (ocrJson != null) 'ocr_json': ocrJson,
      if (estado != null) 'estado': estado,
      if (transaccionId != null) 'transaccion_id': transaccionId,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (procesadoEn != null) 'procesado_en': procesadoEn,
    });
  }

  RecibosCompanion copyWith({
    Value<int>? id,
    Value<String>? archivoPath,
    Value<String>? archivoHash,
    Value<String>? mime,
    Value<String?>? ocrTexto,
    Value<String?>? ocrJson,
    Value<String>? estado,
    Value<int?>? transaccionId,
    Value<int>? creadoEn,
    Value<int?>? procesadoEn,
  }) {
    return RecibosCompanion(
      id: id ?? this.id,
      archivoPath: archivoPath ?? this.archivoPath,
      archivoHash: archivoHash ?? this.archivoHash,
      mime: mime ?? this.mime,
      ocrTexto: ocrTexto ?? this.ocrTexto,
      ocrJson: ocrJson ?? this.ocrJson,
      estado: estado ?? this.estado,
      transaccionId: transaccionId ?? this.transaccionId,
      creadoEn: creadoEn ?? this.creadoEn,
      procesadoEn: procesadoEn ?? this.procesadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (archivoPath.present) {
      map['archivo_path'] = Variable<String>(archivoPath.value);
    }
    if (archivoHash.present) {
      map['archivo_hash'] = Variable<String>(archivoHash.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (ocrTexto.present) {
      map['ocr_texto'] = Variable<String>(ocrTexto.value);
    }
    if (ocrJson.present) {
      map['ocr_json'] = Variable<String>(ocrJson.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (transaccionId.present) {
      map['transaccion_id'] = Variable<int>(transaccionId.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<int>(creadoEn.value);
    }
    if (procesadoEn.present) {
      map['procesado_en'] = Variable<int>(procesadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecibosCompanion(')
          ..write('id: $id, ')
          ..write('archivoPath: $archivoPath, ')
          ..write('archivoHash: $archivoHash, ')
          ..write('mime: $mime, ')
          ..write('ocrTexto: $ocrTexto, ')
          ..write('ocrJson: $ocrJson, ')
          ..write('estado: $estado, ')
          ..write('transaccionId: $transaccionId, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('procesadoEn: $procesadoEn')
          ..write(')'))
        .toString();
  }
}

class $TransaccionesTable extends Transacciones
    with TableInfo<$TransaccionesTable, TransaccionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransaccionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (tipo IN (\'ingreso\',\'gasto\',\'transferencia\'))',
  );
  static const VerificationMeta _montoCentavosMeta = const VerificationMeta(
    'montoCentavos',
  );
  @override
  late final GeneratedColumn<int> montoCentavos = GeneratedColumn<int>(
    'monto_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (monto_centavos > 0)',
  );
  static const VerificationMeta _monedaMeta = const VerificationMeta('moneda');
  @override
  late final GeneratedColumn<String> moneda = GeneratedColumn<String>(
    'moneda',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cuentaIdMeta = const VerificationMeta(
    'cuentaId',
  );
  @override
  late final GeneratedColumn<int> cuentaId = GeneratedColumn<int>(
    'cuenta_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cuentas (id)',
    ),
  );
  static const VerificationMeta _cuentaDestinoIdMeta = const VerificationMeta(
    'cuentaDestinoId',
  );
  @override
  late final GeneratedColumn<int> cuentaDestinoId = GeneratedColumn<int>(
    'cuenta_destino_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cuentas (id)',
    ),
  );
  static const VerificationMeta _montoDestinoCentavosMeta =
      const VerificationMeta('montoDestinoCentavos');
  @override
  late final GeneratedColumn<int> montoDestinoCentavos = GeneratedColumn<int>(
    'monto_destino_centavos',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monedaDestinoMeta = const VerificationMeta(
    'monedaDestino',
  );
  @override
  late final GeneratedColumn<String> monedaDestino = GeneratedColumn<String>(
    'moneda_destino',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
    'categoria_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categorias (id)',
    ),
  );
  static const VerificationMeta _subcategoriaIdMeta = const VerificationMeta(
    'subcategoriaId',
  );
  @override
  late final GeneratedColumn<int> subcategoriaId = GeneratedColumn<int>(
    'subcategoria_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subcategorias (id)',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaHoraMeta = const VerificationMeta(
    'fechaHora',
  );
  @override
  late final GeneratedColumn<int> fechaHora = GeneratedColumn<int>(
    'fecha_hora',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reciboIdMeta = const VerificationMeta(
    'reciboId',
  );
  @override
  late final GeneratedColumn<int> reciboId = GeneratedColumn<int>(
    'recibo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recibos (id)',
    ),
  );
  static const VerificationMeta _tasaCambioMeta = const VerificationMeta(
    'tasaCambio',
  );
  @override
  late final GeneratedColumn<double> tasaCambio = GeneratedColumn<double>(
    'tasa_cambio',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (tasa_cambio IS NULL OR tasa_cambio > 0)',
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('confirmada'),
  );
  static const VerificationMeta _origenMeta = const VerificationMeta('origen');
  @override
  late final GeneratedColumn<String> origen = GeneratedColumn<String>(
    'origen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<int> creadoEn = GeneratedColumn<int>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<int> actualizadoEn = GeneratedColumn<int>(
    'actualizado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eliminadoEnMeta = const VerificationMeta(
    'eliminadoEn',
  );
  @override
  late final GeneratedColumn<int> eliminadoEn = GeneratedColumn<int>(
    'eliminado_en',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tipo,
    montoCentavos,
    moneda,
    cuentaId,
    cuentaDestinoId,
    montoDestinoCentavos,
    monedaDestino,
    categoriaId,
    subcategoriaId,
    fecha,
    fechaHora,
    nota,
    reciboId,
    tasaCambio,
    estado,
    origen,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transacciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransaccionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('monto_centavos')) {
      context.handle(
        _montoCentavosMeta,
        montoCentavos.isAcceptableOrUnknown(
          data['monto_centavos']!,
          _montoCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_montoCentavosMeta);
    }
    if (data.containsKey('moneda')) {
      context.handle(
        _monedaMeta,
        moneda.isAcceptableOrUnknown(data['moneda']!, _monedaMeta),
      );
    } else if (isInserting) {
      context.missing(_monedaMeta);
    }
    if (data.containsKey('cuenta_id')) {
      context.handle(
        _cuentaIdMeta,
        cuentaId.isAcceptableOrUnknown(data['cuenta_id']!, _cuentaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cuentaIdMeta);
    }
    if (data.containsKey('cuenta_destino_id')) {
      context.handle(
        _cuentaDestinoIdMeta,
        cuentaDestinoId.isAcceptableOrUnknown(
          data['cuenta_destino_id']!,
          _cuentaDestinoIdMeta,
        ),
      );
    }
    if (data.containsKey('monto_destino_centavos')) {
      context.handle(
        _montoDestinoCentavosMeta,
        montoDestinoCentavos.isAcceptableOrUnknown(
          data['monto_destino_centavos']!,
          _montoDestinoCentavosMeta,
        ),
      );
    }
    if (data.containsKey('moneda_destino')) {
      context.handle(
        _monedaDestinoMeta,
        monedaDestino.isAcceptableOrUnknown(
          data['moneda_destino']!,
          _monedaDestinoMeta,
        ),
      );
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    }
    if (data.containsKey('subcategoria_id')) {
      context.handle(
        _subcategoriaIdMeta,
        subcategoriaId.isAcceptableOrUnknown(
          data['subcategoria_id']!,
          _subcategoriaIdMeta,
        ),
      );
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('fecha_hora')) {
      context.handle(
        _fechaHoraMeta,
        fechaHora.isAcceptableOrUnknown(data['fecha_hora']!, _fechaHoraMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaHoraMeta);
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    }
    if (data.containsKey('recibo_id')) {
      context.handle(
        _reciboIdMeta,
        reciboId.isAcceptableOrUnknown(data['recibo_id']!, _reciboIdMeta),
      );
    }
    if (data.containsKey('tasa_cambio')) {
      context.handle(
        _tasaCambioMeta,
        tasaCambio.isAcceptableOrUnknown(data['tasa_cambio']!, _tasaCambioMeta),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('origen')) {
      context.handle(
        _origenMeta,
        origen.isAcceptableOrUnknown(data['origen']!, _origenMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadoEnMeta);
    }
    if (data.containsKey('eliminado_en')) {
      context.handle(
        _eliminadoEnMeta,
        eliminadoEn.isAcceptableOrUnknown(
          data['eliminado_en']!,
          _eliminadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransaccionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransaccionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      montoCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto_centavos'],
      )!,
      moneda: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moneda'],
      )!,
      cuentaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cuenta_id'],
      )!,
      cuentaDestinoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cuenta_destino_id'],
      ),
      montoDestinoCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto_destino_centavos'],
      ),
      monedaDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moneda_destino'],
      ),
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_id'],
      ),
      subcategoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subcategoria_id'],
      ),
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha'],
      )!,
      fechaHora: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_hora'],
      )!,
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      ),
      reciboId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recibo_id'],
      ),
      tasaCambio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tasa_cambio'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      origen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origen'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actualizado_en'],
      )!,
      eliminadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eliminado_en'],
      ),
    );
  }

  @override
  $TransaccionesTable createAlias(String alias) {
    return $TransaccionesTable(attachedDatabase, alias);
  }
}

class TransaccionRow extends DataClass implements Insertable<TransaccionRow> {
  final int id;
  final String tipo;
  final int montoCentavos;
  final String moneda;
  final int cuentaId;
  final int? cuentaDestinoId;
  final int? montoDestinoCentavos;
  final String? monedaDestino;
  final int? categoriaId;
  final int? subcategoriaId;
  final String fecha;
  final int fechaHora;
  final String? nota;
  final int? reciboId;
  final double? tasaCambio;
  final String estado;
  final String origen;
  final int creadoEn;
  final int actualizadoEn;
  final int? eliminadoEn;
  const TransaccionRow({
    required this.id,
    required this.tipo,
    required this.montoCentavos,
    required this.moneda,
    required this.cuentaId,
    this.cuentaDestinoId,
    this.montoDestinoCentavos,
    this.monedaDestino,
    this.categoriaId,
    this.subcategoriaId,
    required this.fecha,
    required this.fechaHora,
    this.nota,
    this.reciboId,
    this.tasaCambio,
    required this.estado,
    required this.origen,
    required this.creadoEn,
    required this.actualizadoEn,
    this.eliminadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tipo'] = Variable<String>(tipo);
    map['monto_centavos'] = Variable<int>(montoCentavos);
    map['moneda'] = Variable<String>(moneda);
    map['cuenta_id'] = Variable<int>(cuentaId);
    if (!nullToAbsent || cuentaDestinoId != null) {
      map['cuenta_destino_id'] = Variable<int>(cuentaDestinoId);
    }
    if (!nullToAbsent || montoDestinoCentavos != null) {
      map['monto_destino_centavos'] = Variable<int>(montoDestinoCentavos);
    }
    if (!nullToAbsent || monedaDestino != null) {
      map['moneda_destino'] = Variable<String>(monedaDestino);
    }
    if (!nullToAbsent || categoriaId != null) {
      map['categoria_id'] = Variable<int>(categoriaId);
    }
    if (!nullToAbsent || subcategoriaId != null) {
      map['subcategoria_id'] = Variable<int>(subcategoriaId);
    }
    map['fecha'] = Variable<String>(fecha);
    map['fecha_hora'] = Variable<int>(fechaHora);
    if (!nullToAbsent || nota != null) {
      map['nota'] = Variable<String>(nota);
    }
    if (!nullToAbsent || reciboId != null) {
      map['recibo_id'] = Variable<int>(reciboId);
    }
    if (!nullToAbsent || tasaCambio != null) {
      map['tasa_cambio'] = Variable<double>(tasaCambio);
    }
    map['estado'] = Variable<String>(estado);
    map['origen'] = Variable<String>(origen);
    map['creado_en'] = Variable<int>(creadoEn);
    map['actualizado_en'] = Variable<int>(actualizadoEn);
    if (!nullToAbsent || eliminadoEn != null) {
      map['eliminado_en'] = Variable<int>(eliminadoEn);
    }
    return map;
  }

  TransaccionesCompanion toCompanion(bool nullToAbsent) {
    return TransaccionesCompanion(
      id: Value(id),
      tipo: Value(tipo),
      montoCentavos: Value(montoCentavos),
      moneda: Value(moneda),
      cuentaId: Value(cuentaId),
      cuentaDestinoId: cuentaDestinoId == null && nullToAbsent
          ? const Value.absent()
          : Value(cuentaDestinoId),
      montoDestinoCentavos: montoDestinoCentavos == null && nullToAbsent
          ? const Value.absent()
          : Value(montoDestinoCentavos),
      monedaDestino: monedaDestino == null && nullToAbsent
          ? const Value.absent()
          : Value(monedaDestino),
      categoriaId: categoriaId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaId),
      subcategoriaId: subcategoriaId == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategoriaId),
      fecha: Value(fecha),
      fechaHora: Value(fechaHora),
      nota: nota == null && nullToAbsent ? const Value.absent() : Value(nota),
      reciboId: reciboId == null && nullToAbsent
          ? const Value.absent()
          : Value(reciboId),
      tasaCambio: tasaCambio == null && nullToAbsent
          ? const Value.absent()
          : Value(tasaCambio),
      estado: Value(estado),
      origen: Value(origen),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
      eliminadoEn: eliminadoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(eliminadoEn),
    );
  }

  factory TransaccionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransaccionRow(
      id: serializer.fromJson<int>(json['id']),
      tipo: serializer.fromJson<String>(json['tipo']),
      montoCentavos: serializer.fromJson<int>(json['montoCentavos']),
      moneda: serializer.fromJson<String>(json['moneda']),
      cuentaId: serializer.fromJson<int>(json['cuentaId']),
      cuentaDestinoId: serializer.fromJson<int?>(json['cuentaDestinoId']),
      montoDestinoCentavos: serializer.fromJson<int?>(
        json['montoDestinoCentavos'],
      ),
      monedaDestino: serializer.fromJson<String?>(json['monedaDestino']),
      categoriaId: serializer.fromJson<int?>(json['categoriaId']),
      subcategoriaId: serializer.fromJson<int?>(json['subcategoriaId']),
      fecha: serializer.fromJson<String>(json['fecha']),
      fechaHora: serializer.fromJson<int>(json['fechaHora']),
      nota: serializer.fromJson<String?>(json['nota']),
      reciboId: serializer.fromJson<int?>(json['reciboId']),
      tasaCambio: serializer.fromJson<double?>(json['tasaCambio']),
      estado: serializer.fromJson<String>(json['estado']),
      origen: serializer.fromJson<String>(json['origen']),
      creadoEn: serializer.fromJson<int>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<int>(json['actualizadoEn']),
      eliminadoEn: serializer.fromJson<int?>(json['eliminadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tipo': serializer.toJson<String>(tipo),
      'montoCentavos': serializer.toJson<int>(montoCentavos),
      'moneda': serializer.toJson<String>(moneda),
      'cuentaId': serializer.toJson<int>(cuentaId),
      'cuentaDestinoId': serializer.toJson<int?>(cuentaDestinoId),
      'montoDestinoCentavos': serializer.toJson<int?>(montoDestinoCentavos),
      'monedaDestino': serializer.toJson<String?>(monedaDestino),
      'categoriaId': serializer.toJson<int?>(categoriaId),
      'subcategoriaId': serializer.toJson<int?>(subcategoriaId),
      'fecha': serializer.toJson<String>(fecha),
      'fechaHora': serializer.toJson<int>(fechaHora),
      'nota': serializer.toJson<String?>(nota),
      'reciboId': serializer.toJson<int?>(reciboId),
      'tasaCambio': serializer.toJson<double?>(tasaCambio),
      'estado': serializer.toJson<String>(estado),
      'origen': serializer.toJson<String>(origen),
      'creadoEn': serializer.toJson<int>(creadoEn),
      'actualizadoEn': serializer.toJson<int>(actualizadoEn),
      'eliminadoEn': serializer.toJson<int?>(eliminadoEn),
    };
  }

  TransaccionRow copyWith({
    int? id,
    String? tipo,
    int? montoCentavos,
    String? moneda,
    int? cuentaId,
    Value<int?> cuentaDestinoId = const Value.absent(),
    Value<int?> montoDestinoCentavos = const Value.absent(),
    Value<String?> monedaDestino = const Value.absent(),
    Value<int?> categoriaId = const Value.absent(),
    Value<int?> subcategoriaId = const Value.absent(),
    String? fecha,
    int? fechaHora,
    Value<String?> nota = const Value.absent(),
    Value<int?> reciboId = const Value.absent(),
    Value<double?> tasaCambio = const Value.absent(),
    String? estado,
    String? origen,
    int? creadoEn,
    int? actualizadoEn,
    Value<int?> eliminadoEn = const Value.absent(),
  }) => TransaccionRow(
    id: id ?? this.id,
    tipo: tipo ?? this.tipo,
    montoCentavos: montoCentavos ?? this.montoCentavos,
    moneda: moneda ?? this.moneda,
    cuentaId: cuentaId ?? this.cuentaId,
    cuentaDestinoId: cuentaDestinoId.present
        ? cuentaDestinoId.value
        : this.cuentaDestinoId,
    montoDestinoCentavos: montoDestinoCentavos.present
        ? montoDestinoCentavos.value
        : this.montoDestinoCentavos,
    monedaDestino: monedaDestino.present
        ? monedaDestino.value
        : this.monedaDestino,
    categoriaId: categoriaId.present ? categoriaId.value : this.categoriaId,
    subcategoriaId: subcategoriaId.present
        ? subcategoriaId.value
        : this.subcategoriaId,
    fecha: fecha ?? this.fecha,
    fechaHora: fechaHora ?? this.fechaHora,
    nota: nota.present ? nota.value : this.nota,
    reciboId: reciboId.present ? reciboId.value : this.reciboId,
    tasaCambio: tasaCambio.present ? tasaCambio.value : this.tasaCambio,
    estado: estado ?? this.estado,
    origen: origen ?? this.origen,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    eliminadoEn: eliminadoEn.present ? eliminadoEn.value : this.eliminadoEn,
  );
  TransaccionRow copyWithCompanion(TransaccionesCompanion data) {
    return TransaccionRow(
      id: data.id.present ? data.id.value : this.id,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      montoCentavos: data.montoCentavos.present
          ? data.montoCentavos.value
          : this.montoCentavos,
      moneda: data.moneda.present ? data.moneda.value : this.moneda,
      cuentaId: data.cuentaId.present ? data.cuentaId.value : this.cuentaId,
      cuentaDestinoId: data.cuentaDestinoId.present
          ? data.cuentaDestinoId.value
          : this.cuentaDestinoId,
      montoDestinoCentavos: data.montoDestinoCentavos.present
          ? data.montoDestinoCentavos.value
          : this.montoDestinoCentavos,
      monedaDestino: data.monedaDestino.present
          ? data.monedaDestino.value
          : this.monedaDestino,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      subcategoriaId: data.subcategoriaId.present
          ? data.subcategoriaId.value
          : this.subcategoriaId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      fechaHora: data.fechaHora.present ? data.fechaHora.value : this.fechaHora,
      nota: data.nota.present ? data.nota.value : this.nota,
      reciboId: data.reciboId.present ? data.reciboId.value : this.reciboId,
      tasaCambio: data.tasaCambio.present
          ? data.tasaCambio.value
          : this.tasaCambio,
      estado: data.estado.present ? data.estado.value : this.estado,
      origen: data.origen.present ? data.origen.value : this.origen,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
      eliminadoEn: data.eliminadoEn.present
          ? data.eliminadoEn.value
          : this.eliminadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransaccionRow(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('montoCentavos: $montoCentavos, ')
          ..write('moneda: $moneda, ')
          ..write('cuentaId: $cuentaId, ')
          ..write('cuentaDestinoId: $cuentaDestinoId, ')
          ..write('montoDestinoCentavos: $montoDestinoCentavos, ')
          ..write('monedaDestino: $monedaDestino, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('subcategoriaId: $subcategoriaId, ')
          ..write('fecha: $fecha, ')
          ..write('fechaHora: $fechaHora, ')
          ..write('nota: $nota, ')
          ..write('reciboId: $reciboId, ')
          ..write('tasaCambio: $tasaCambio, ')
          ..write('estado: $estado, ')
          ..write('origen: $origen, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tipo,
    montoCentavos,
    moneda,
    cuentaId,
    cuentaDestinoId,
    montoDestinoCentavos,
    monedaDestino,
    categoriaId,
    subcategoriaId,
    fecha,
    fechaHora,
    nota,
    reciboId,
    tasaCambio,
    estado,
    origen,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransaccionRow &&
          other.id == this.id &&
          other.tipo == this.tipo &&
          other.montoCentavos == this.montoCentavos &&
          other.moneda == this.moneda &&
          other.cuentaId == this.cuentaId &&
          other.cuentaDestinoId == this.cuentaDestinoId &&
          other.montoDestinoCentavos == this.montoDestinoCentavos &&
          other.monedaDestino == this.monedaDestino &&
          other.categoriaId == this.categoriaId &&
          other.subcategoriaId == this.subcategoriaId &&
          other.fecha == this.fecha &&
          other.fechaHora == this.fechaHora &&
          other.nota == this.nota &&
          other.reciboId == this.reciboId &&
          other.tasaCambio == this.tasaCambio &&
          other.estado == this.estado &&
          other.origen == this.origen &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn &&
          other.eliminadoEn == this.eliminadoEn);
}

class TransaccionesCompanion extends UpdateCompanion<TransaccionRow> {
  final Value<int> id;
  final Value<String> tipo;
  final Value<int> montoCentavos;
  final Value<String> moneda;
  final Value<int> cuentaId;
  final Value<int?> cuentaDestinoId;
  final Value<int?> montoDestinoCentavos;
  final Value<String?> monedaDestino;
  final Value<int?> categoriaId;
  final Value<int?> subcategoriaId;
  final Value<String> fecha;
  final Value<int> fechaHora;
  final Value<String?> nota;
  final Value<int?> reciboId;
  final Value<double?> tasaCambio;
  final Value<String> estado;
  final Value<String> origen;
  final Value<int> creadoEn;
  final Value<int> actualizadoEn;
  final Value<int?> eliminadoEn;
  const TransaccionesCompanion({
    this.id = const Value.absent(),
    this.tipo = const Value.absent(),
    this.montoCentavos = const Value.absent(),
    this.moneda = const Value.absent(),
    this.cuentaId = const Value.absent(),
    this.cuentaDestinoId = const Value.absent(),
    this.montoDestinoCentavos = const Value.absent(),
    this.monedaDestino = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.subcategoriaId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.fechaHora = const Value.absent(),
    this.nota = const Value.absent(),
    this.reciboId = const Value.absent(),
    this.tasaCambio = const Value.absent(),
    this.estado = const Value.absent(),
    this.origen = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.eliminadoEn = const Value.absent(),
  });
  TransaccionesCompanion.insert({
    this.id = const Value.absent(),
    required String tipo,
    required int montoCentavos,
    required String moneda,
    required int cuentaId,
    this.cuentaDestinoId = const Value.absent(),
    this.montoDestinoCentavos = const Value.absent(),
    this.monedaDestino = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.subcategoriaId = const Value.absent(),
    required String fecha,
    required int fechaHora,
    this.nota = const Value.absent(),
    this.reciboId = const Value.absent(),
    this.tasaCambio = const Value.absent(),
    this.estado = const Value.absent(),
    this.origen = const Value.absent(),
    required int creadoEn,
    required int actualizadoEn,
    this.eliminadoEn = const Value.absent(),
  }) : tipo = Value(tipo),
       montoCentavos = Value(montoCentavos),
       moneda = Value(moneda),
       cuentaId = Value(cuentaId),
       fecha = Value(fecha),
       fechaHora = Value(fechaHora),
       creadoEn = Value(creadoEn),
       actualizadoEn = Value(actualizadoEn);
  static Insertable<TransaccionRow> custom({
    Expression<int>? id,
    Expression<String>? tipo,
    Expression<int>? montoCentavos,
    Expression<String>? moneda,
    Expression<int>? cuentaId,
    Expression<int>? cuentaDestinoId,
    Expression<int>? montoDestinoCentavos,
    Expression<String>? monedaDestino,
    Expression<int>? categoriaId,
    Expression<int>? subcategoriaId,
    Expression<String>? fecha,
    Expression<int>? fechaHora,
    Expression<String>? nota,
    Expression<int>? reciboId,
    Expression<double>? tasaCambio,
    Expression<String>? estado,
    Expression<String>? origen,
    Expression<int>? creadoEn,
    Expression<int>? actualizadoEn,
    Expression<int>? eliminadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipo != null) 'tipo': tipo,
      if (montoCentavos != null) 'monto_centavos': montoCentavos,
      if (moneda != null) 'moneda': moneda,
      if (cuentaId != null) 'cuenta_id': cuentaId,
      if (cuentaDestinoId != null) 'cuenta_destino_id': cuentaDestinoId,
      if (montoDestinoCentavos != null)
        'monto_destino_centavos': montoDestinoCentavos,
      if (monedaDestino != null) 'moneda_destino': monedaDestino,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (subcategoriaId != null) 'subcategoria_id': subcategoriaId,
      if (fecha != null) 'fecha': fecha,
      if (fechaHora != null) 'fecha_hora': fechaHora,
      if (nota != null) 'nota': nota,
      if (reciboId != null) 'recibo_id': reciboId,
      if (tasaCambio != null) 'tasa_cambio': tasaCambio,
      if (estado != null) 'estado': estado,
      if (origen != null) 'origen': origen,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (eliminadoEn != null) 'eliminado_en': eliminadoEn,
    });
  }

  TransaccionesCompanion copyWith({
    Value<int>? id,
    Value<String>? tipo,
    Value<int>? montoCentavos,
    Value<String>? moneda,
    Value<int>? cuentaId,
    Value<int?>? cuentaDestinoId,
    Value<int?>? montoDestinoCentavos,
    Value<String?>? monedaDestino,
    Value<int?>? categoriaId,
    Value<int?>? subcategoriaId,
    Value<String>? fecha,
    Value<int>? fechaHora,
    Value<String?>? nota,
    Value<int?>? reciboId,
    Value<double?>? tasaCambio,
    Value<String>? estado,
    Value<String>? origen,
    Value<int>? creadoEn,
    Value<int>? actualizadoEn,
    Value<int?>? eliminadoEn,
  }) {
    return TransaccionesCompanion(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      montoCentavos: montoCentavos ?? this.montoCentavos,
      moneda: moneda ?? this.moneda,
      cuentaId: cuentaId ?? this.cuentaId,
      cuentaDestinoId: cuentaDestinoId ?? this.cuentaDestinoId,
      montoDestinoCentavos: montoDestinoCentavos ?? this.montoDestinoCentavos,
      monedaDestino: monedaDestino ?? this.monedaDestino,
      categoriaId: categoriaId ?? this.categoriaId,
      subcategoriaId: subcategoriaId ?? this.subcategoriaId,
      fecha: fecha ?? this.fecha,
      fechaHora: fechaHora ?? this.fechaHora,
      nota: nota ?? this.nota,
      reciboId: reciboId ?? this.reciboId,
      tasaCambio: tasaCambio ?? this.tasaCambio,
      estado: estado ?? this.estado,
      origen: origen ?? this.origen,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      eliminadoEn: eliminadoEn ?? this.eliminadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (montoCentavos.present) {
      map['monto_centavos'] = Variable<int>(montoCentavos.value);
    }
    if (moneda.present) {
      map['moneda'] = Variable<String>(moneda.value);
    }
    if (cuentaId.present) {
      map['cuenta_id'] = Variable<int>(cuentaId.value);
    }
    if (cuentaDestinoId.present) {
      map['cuenta_destino_id'] = Variable<int>(cuentaDestinoId.value);
    }
    if (montoDestinoCentavos.present) {
      map['monto_destino_centavos'] = Variable<int>(montoDestinoCentavos.value);
    }
    if (monedaDestino.present) {
      map['moneda_destino'] = Variable<String>(monedaDestino.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (subcategoriaId.present) {
      map['subcategoria_id'] = Variable<int>(subcategoriaId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (fechaHora.present) {
      map['fecha_hora'] = Variable<int>(fechaHora.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    if (reciboId.present) {
      map['recibo_id'] = Variable<int>(reciboId.value);
    }
    if (tasaCambio.present) {
      map['tasa_cambio'] = Variable<double>(tasaCambio.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (origen.present) {
      map['origen'] = Variable<String>(origen.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<int>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<int>(actualizadoEn.value);
    }
    if (eliminadoEn.present) {
      map['eliminado_en'] = Variable<int>(eliminadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransaccionesCompanion(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('montoCentavos: $montoCentavos, ')
          ..write('moneda: $moneda, ')
          ..write('cuentaId: $cuentaId, ')
          ..write('cuentaDestinoId: $cuentaDestinoId, ')
          ..write('montoDestinoCentavos: $montoDestinoCentavos, ')
          ..write('monedaDestino: $monedaDestino, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('subcategoriaId: $subcategoriaId, ')
          ..write('fecha: $fecha, ')
          ..write('fechaHora: $fechaHora, ')
          ..write('nota: $nota, ')
          ..write('reciboId: $reciboId, ')
          ..write('tasaCambio: $tasaCambio, ')
          ..write('estado: $estado, ')
          ..write('origen: $origen, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }
}

class $TransaccionEtiquetasTable extends TransaccionEtiquetas
    with TableInfo<$TransaccionEtiquetasTable, TransaccionEtiquetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransaccionEtiquetasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _transaccionIdMeta = const VerificationMeta(
    'transaccionId',
  );
  @override
  late final GeneratedColumn<int> transaccionId = GeneratedColumn<int>(
    'transaccion_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transacciones (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _etiquetaIdMeta = const VerificationMeta(
    'etiquetaId',
  );
  @override
  late final GeneratedColumn<int> etiquetaId = GeneratedColumn<int>(
    'etiqueta_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES etiquetas (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [transaccionId, etiquetaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaccion_etiquetas';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransaccionEtiquetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transaccion_id')) {
      context.handle(
        _transaccionIdMeta,
        transaccionId.isAcceptableOrUnknown(
          data['transaccion_id']!,
          _transaccionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transaccionIdMeta);
    }
    if (data.containsKey('etiqueta_id')) {
      context.handle(
        _etiquetaIdMeta,
        etiquetaId.isAcceptableOrUnknown(data['etiqueta_id']!, _etiquetaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_etiquetaIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transaccionId, etiquetaId};
  @override
  TransaccionEtiquetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransaccionEtiquetaRow(
      transaccionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaccion_id'],
      )!,
      etiquetaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}etiqueta_id'],
      )!,
    );
  }

  @override
  $TransaccionEtiquetasTable createAlias(String alias) {
    return $TransaccionEtiquetasTable(attachedDatabase, alias);
  }
}

class TransaccionEtiquetaRow extends DataClass
    implements Insertable<TransaccionEtiquetaRow> {
  final int transaccionId;
  final int etiquetaId;
  const TransaccionEtiquetaRow({
    required this.transaccionId,
    required this.etiquetaId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['transaccion_id'] = Variable<int>(transaccionId);
    map['etiqueta_id'] = Variable<int>(etiquetaId);
    return map;
  }

  TransaccionEtiquetasCompanion toCompanion(bool nullToAbsent) {
    return TransaccionEtiquetasCompanion(
      transaccionId: Value(transaccionId),
      etiquetaId: Value(etiquetaId),
    );
  }

  factory TransaccionEtiquetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransaccionEtiquetaRow(
      transaccionId: serializer.fromJson<int>(json['transaccionId']),
      etiquetaId: serializer.fromJson<int>(json['etiquetaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transaccionId': serializer.toJson<int>(transaccionId),
      'etiquetaId': serializer.toJson<int>(etiquetaId),
    };
  }

  TransaccionEtiquetaRow copyWith({int? transaccionId, int? etiquetaId}) =>
      TransaccionEtiquetaRow(
        transaccionId: transaccionId ?? this.transaccionId,
        etiquetaId: etiquetaId ?? this.etiquetaId,
      );
  TransaccionEtiquetaRow copyWithCompanion(TransaccionEtiquetasCompanion data) {
    return TransaccionEtiquetaRow(
      transaccionId: data.transaccionId.present
          ? data.transaccionId.value
          : this.transaccionId,
      etiquetaId: data.etiquetaId.present
          ? data.etiquetaId.value
          : this.etiquetaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransaccionEtiquetaRow(')
          ..write('transaccionId: $transaccionId, ')
          ..write('etiquetaId: $etiquetaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(transaccionId, etiquetaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransaccionEtiquetaRow &&
          other.transaccionId == this.transaccionId &&
          other.etiquetaId == this.etiquetaId);
}

class TransaccionEtiquetasCompanion
    extends UpdateCompanion<TransaccionEtiquetaRow> {
  final Value<int> transaccionId;
  final Value<int> etiquetaId;
  final Value<int> rowid;
  const TransaccionEtiquetasCompanion({
    this.transaccionId = const Value.absent(),
    this.etiquetaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransaccionEtiquetasCompanion.insert({
    required int transaccionId,
    required int etiquetaId,
    this.rowid = const Value.absent(),
  }) : transaccionId = Value(transaccionId),
       etiquetaId = Value(etiquetaId);
  static Insertable<TransaccionEtiquetaRow> custom({
    Expression<int>? transaccionId,
    Expression<int>? etiquetaId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (transaccionId != null) 'transaccion_id': transaccionId,
      if (etiquetaId != null) 'etiqueta_id': etiquetaId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransaccionEtiquetasCompanion copyWith({
    Value<int>? transaccionId,
    Value<int>? etiquetaId,
    Value<int>? rowid,
  }) {
    return TransaccionEtiquetasCompanion(
      transaccionId: transaccionId ?? this.transaccionId,
      etiquetaId: etiquetaId ?? this.etiquetaId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transaccionId.present) {
      map['transaccion_id'] = Variable<int>(transaccionId.value);
    }
    if (etiquetaId.present) {
      map['etiqueta_id'] = Variable<int>(etiquetaId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransaccionEtiquetasCompanion(')
          ..write('transaccionId: $transaccionId, ')
          ..write('etiquetaId: $etiquetaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasasCambioTable extends TasasCambio
    with TableInfo<$TasasCambioTable, TasaCambioRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasasCambioTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _monedaOrigenMeta = const VerificationMeta(
    'monedaOrigen',
  );
  @override
  late final GeneratedColumn<String> monedaOrigen = GeneratedColumn<String>(
    'moneda_origen',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monedaDestinoMeta = const VerificationMeta(
    'monedaDestino',
  );
  @override
  late final GeneratedColumn<String> monedaDestino = GeneratedColumn<String>(
    'moneda_destino',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<double> valor = GeneratedColumn<double>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (valor > 0)',
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fuenteMeta = const VerificationMeta('fuente');
  @override
  late final GeneratedColumn<String> fuente = GeneratedColumn<String>(
    'fuente',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (fuente IN (\'manual\',\'trm\',\'api_abierta\'))',
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<int> creadoEn = GeneratedColumn<int>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    monedaOrigen,
    monedaDestino,
    valor,
    fecha,
    fuente,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasas_cambio';
  @override
  VerificationContext validateIntegrity(
    Insertable<TasaCambioRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('moneda_origen')) {
      context.handle(
        _monedaOrigenMeta,
        monedaOrigen.isAcceptableOrUnknown(
          data['moneda_origen']!,
          _monedaOrigenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monedaOrigenMeta);
    }
    if (data.containsKey('moneda_destino')) {
      context.handle(
        _monedaDestinoMeta,
        monedaDestino.isAcceptableOrUnknown(
          data['moneda_destino']!,
          _monedaDestinoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monedaDestinoMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('fuente')) {
      context.handle(
        _fuenteMeta,
        fuente.isAcceptableOrUnknown(data['fuente']!, _fuenteMeta),
      );
    } else if (isInserting) {
      context.missing(_fuenteMeta);
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {monedaOrigen, monedaDestino, fecha},
  ];
  @override
  TasaCambioRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TasaCambioRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      monedaOrigen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moneda_origen'],
      )!,
      monedaDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moneda_destino'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha'],
      )!,
      fuente: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fuente'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creado_en'],
      )!,
    );
  }

  @override
  $TasasCambioTable createAlias(String alias) {
    return $TasasCambioTable(attachedDatabase, alias);
  }
}

class TasaCambioRow extends DataClass implements Insertable<TasaCambioRow> {
  final int id;
  final String monedaOrigen;
  final String monedaDestino;
  final double valor;
  final String fecha;
  final String fuente;
  final int creadoEn;
  const TasaCambioRow({
    required this.id,
    required this.monedaOrigen,
    required this.monedaDestino,
    required this.valor,
    required this.fecha,
    required this.fuente,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['moneda_origen'] = Variable<String>(monedaOrigen);
    map['moneda_destino'] = Variable<String>(monedaDestino);
    map['valor'] = Variable<double>(valor);
    map['fecha'] = Variable<String>(fecha);
    map['fuente'] = Variable<String>(fuente);
    map['creado_en'] = Variable<int>(creadoEn);
    return map;
  }

  TasasCambioCompanion toCompanion(bool nullToAbsent) {
    return TasasCambioCompanion(
      id: Value(id),
      monedaOrigen: Value(monedaOrigen),
      monedaDestino: Value(monedaDestino),
      valor: Value(valor),
      fecha: Value(fecha),
      fuente: Value(fuente),
      creadoEn: Value(creadoEn),
    );
  }

  factory TasaCambioRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TasaCambioRow(
      id: serializer.fromJson<int>(json['id']),
      monedaOrigen: serializer.fromJson<String>(json['monedaOrigen']),
      monedaDestino: serializer.fromJson<String>(json['monedaDestino']),
      valor: serializer.fromJson<double>(json['valor']),
      fecha: serializer.fromJson<String>(json['fecha']),
      fuente: serializer.fromJson<String>(json['fuente']),
      creadoEn: serializer.fromJson<int>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'monedaOrigen': serializer.toJson<String>(monedaOrigen),
      'monedaDestino': serializer.toJson<String>(monedaDestino),
      'valor': serializer.toJson<double>(valor),
      'fecha': serializer.toJson<String>(fecha),
      'fuente': serializer.toJson<String>(fuente),
      'creadoEn': serializer.toJson<int>(creadoEn),
    };
  }

  TasaCambioRow copyWith({
    int? id,
    String? monedaOrigen,
    String? monedaDestino,
    double? valor,
    String? fecha,
    String? fuente,
    int? creadoEn,
  }) => TasaCambioRow(
    id: id ?? this.id,
    monedaOrigen: monedaOrigen ?? this.monedaOrigen,
    monedaDestino: monedaDestino ?? this.monedaDestino,
    valor: valor ?? this.valor,
    fecha: fecha ?? this.fecha,
    fuente: fuente ?? this.fuente,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  TasaCambioRow copyWithCompanion(TasasCambioCompanion data) {
    return TasaCambioRow(
      id: data.id.present ? data.id.value : this.id,
      monedaOrigen: data.monedaOrigen.present
          ? data.monedaOrigen.value
          : this.monedaOrigen,
      monedaDestino: data.monedaDestino.present
          ? data.monedaDestino.value
          : this.monedaDestino,
      valor: data.valor.present ? data.valor.value : this.valor,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      fuente: data.fuente.present ? data.fuente.value : this.fuente,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TasaCambioRow(')
          ..write('id: $id, ')
          ..write('monedaOrigen: $monedaOrigen, ')
          ..write('monedaDestino: $monedaDestino, ')
          ..write('valor: $valor, ')
          ..write('fecha: $fecha, ')
          ..write('fuente: $fuente, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    monedaOrigen,
    monedaDestino,
    valor,
    fecha,
    fuente,
    creadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TasaCambioRow &&
          other.id == this.id &&
          other.monedaOrigen == this.monedaOrigen &&
          other.monedaDestino == this.monedaDestino &&
          other.valor == this.valor &&
          other.fecha == this.fecha &&
          other.fuente == this.fuente &&
          other.creadoEn == this.creadoEn);
}

class TasasCambioCompanion extends UpdateCompanion<TasaCambioRow> {
  final Value<int> id;
  final Value<String> monedaOrigen;
  final Value<String> monedaDestino;
  final Value<double> valor;
  final Value<String> fecha;
  final Value<String> fuente;
  final Value<int> creadoEn;
  const TasasCambioCompanion({
    this.id = const Value.absent(),
    this.monedaOrigen = const Value.absent(),
    this.monedaDestino = const Value.absent(),
    this.valor = const Value.absent(),
    this.fecha = const Value.absent(),
    this.fuente = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  TasasCambioCompanion.insert({
    this.id = const Value.absent(),
    required String monedaOrigen,
    required String monedaDestino,
    required double valor,
    required String fecha,
    required String fuente,
    required int creadoEn,
  }) : monedaOrigen = Value(monedaOrigen),
       monedaDestino = Value(monedaDestino),
       valor = Value(valor),
       fecha = Value(fecha),
       fuente = Value(fuente),
       creadoEn = Value(creadoEn);
  static Insertable<TasaCambioRow> custom({
    Expression<int>? id,
    Expression<String>? monedaOrigen,
    Expression<String>? monedaDestino,
    Expression<double>? valor,
    Expression<String>? fecha,
    Expression<String>? fuente,
    Expression<int>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (monedaOrigen != null) 'moneda_origen': monedaOrigen,
      if (monedaDestino != null) 'moneda_destino': monedaDestino,
      if (valor != null) 'valor': valor,
      if (fecha != null) 'fecha': fecha,
      if (fuente != null) 'fuente': fuente,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  TasasCambioCompanion copyWith({
    Value<int>? id,
    Value<String>? monedaOrigen,
    Value<String>? monedaDestino,
    Value<double>? valor,
    Value<String>? fecha,
    Value<String>? fuente,
    Value<int>? creadoEn,
  }) {
    return TasasCambioCompanion(
      id: id ?? this.id,
      monedaOrigen: monedaOrigen ?? this.monedaOrigen,
      monedaDestino: monedaDestino ?? this.monedaDestino,
      valor: valor ?? this.valor,
      fecha: fecha ?? this.fecha,
      fuente: fuente ?? this.fuente,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (monedaOrigen.present) {
      map['moneda_origen'] = Variable<String>(monedaOrigen.value);
    }
    if (monedaDestino.present) {
      map['moneda_destino'] = Variable<String>(monedaDestino.value);
    }
    if (valor.present) {
      map['valor'] = Variable<double>(valor.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (fuente.present) {
      map['fuente'] = Variable<String>(fuente.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<int>(creadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasasCambioCompanion(')
          ..write('id: $id, ')
          ..write('monedaOrigen: $monedaOrigen, ')
          ..write('monedaDestino: $monedaDestino, ')
          ..write('valor: $valor, ')
          ..write('fecha: $fecha, ')
          ..write('fuente: $fuente, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

class $ConfiguracionTable extends Configuracion
    with TableInfo<$ConfiguracionTable, ConfiguracionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfiguracionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _claveMeta = const VerificationMeta('clave');
  @override
  late final GeneratedColumn<String> clave = GeneratedColumn<String>(
    'clave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<int> actualizadoEn = GeneratedColumn<int>(
    'actualizado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [clave, valor, actualizadoEn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'configuracion';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConfiguracionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('clave')) {
      context.handle(
        _claveMeta,
        clave.isAcceptableOrUnknown(data['clave']!, _claveMeta),
      );
    } else if (isInserting) {
      context.missing(_claveMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadoEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clave};
  @override
  ConfiguracionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfiguracionRow(
      clave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clave'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actualizado_en'],
      )!,
    );
  }

  @override
  $ConfiguracionTable createAlias(String alias) {
    return $ConfiguracionTable(attachedDatabase, alias);
  }
}

class ConfiguracionRow extends DataClass
    implements Insertable<ConfiguracionRow> {
  final String clave;
  final String valor;
  final int actualizadoEn;
  const ConfiguracionRow({
    required this.clave,
    required this.valor,
    required this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['clave'] = Variable<String>(clave);
    map['valor'] = Variable<String>(valor);
    map['actualizado_en'] = Variable<int>(actualizadoEn);
    return map;
  }

  ConfiguracionCompanion toCompanion(bool nullToAbsent) {
    return ConfiguracionCompanion(
      clave: Value(clave),
      valor: Value(valor),
      actualizadoEn: Value(actualizadoEn),
    );
  }

  factory ConfiguracionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfiguracionRow(
      clave: serializer.fromJson<String>(json['clave']),
      valor: serializer.fromJson<String>(json['valor']),
      actualizadoEn: serializer.fromJson<int>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clave': serializer.toJson<String>(clave),
      'valor': serializer.toJson<String>(valor),
      'actualizadoEn': serializer.toJson<int>(actualizadoEn),
    };
  }

  ConfiguracionRow copyWith({
    String? clave,
    String? valor,
    int? actualizadoEn,
  }) => ConfiguracionRow(
    clave: clave ?? this.clave,
    valor: valor ?? this.valor,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
  );
  ConfiguracionRow copyWithCompanion(ConfiguracionCompanion data) {
    return ConfiguracionRow(
      clave: data.clave.present ? data.clave.value : this.clave,
      valor: data.valor.present ? data.valor.value : this.valor,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracionRow(')
          ..write('clave: $clave, ')
          ..write('valor: $valor, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clave, valor, actualizadoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfiguracionRow &&
          other.clave == this.clave &&
          other.valor == this.valor &&
          other.actualizadoEn == this.actualizadoEn);
}

class ConfiguracionCompanion extends UpdateCompanion<ConfiguracionRow> {
  final Value<String> clave;
  final Value<String> valor;
  final Value<int> actualizadoEn;
  final Value<int> rowid;
  const ConfiguracionCompanion({
    this.clave = const Value.absent(),
    this.valor = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConfiguracionCompanion.insert({
    required String clave,
    required String valor,
    required int actualizadoEn,
    this.rowid = const Value.absent(),
  }) : clave = Value(clave),
       valor = Value(valor),
       actualizadoEn = Value(actualizadoEn);
  static Insertable<ConfiguracionRow> custom({
    Expression<String>? clave,
    Expression<String>? valor,
    Expression<int>? actualizadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clave != null) 'clave': clave,
      if (valor != null) 'valor': valor,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConfiguracionCompanion copyWith({
    Value<String>? clave,
    Value<String>? valor,
    Value<int>? actualizadoEn,
    Value<int>? rowid,
  }) {
    return ConfiguracionCompanion(
      clave: clave ?? this.clave,
      valor: valor ?? this.valor,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clave.present) {
      map['clave'] = Variable<String>(clave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<int>(actualizadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracionCompanion(')
          ..write('clave: $clave, ')
          ..write('valor: $valor, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CapturaEntranteTable extends CapturaEntrante
    with TableInfo<$CapturaEntranteTable, CapturaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CapturaEntranteTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _canalMeta = const VerificationMeta('canal');
  @override
  late final GeneratedColumn<String> canal = GeneratedColumn<String>(
    'canal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (canal IN (\'texto\',\'audio\',\'foto\',\'app\'))',
  );
  static const VerificationMeta _origenMeta = const VerificationMeta('origen');
  @override
  late final GeneratedColumn<String> origen = GeneratedColumn<String>(
    'origen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (origen IN (\'mock\',\'bot\',\'manual\'))',
  );
  static const VerificationMeta _messageIdExternoMeta = const VerificationMeta(
    'messageIdExterno',
  );
  @override
  late final GeneratedColumn<String> messageIdExterno = GeneratedColumn<String>(
    'message_id_externo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _textoCrudoMeta = const VerificationMeta(
    'textoCrudo',
  );
  @override
  late final GeneratedColumn<String> textoCrudo = GeneratedColumn<String>(
    'texto_crudo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _adjuntoPathMeta = const VerificationMeta(
    'adjuntoPath',
  );
  @override
  late final GeneratedColumn<String> adjuntoPath = GeneratedColumn<String>(
    'adjunto_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'pendiente\' CHECK (estado IN (\'pendiente\',\'procesando\',\'listo\',\'confirmado\',\'descartado\',\'error\'))',
    defaultValue: const CustomExpression('\'pendiente\''),
  );
  static const VerificationMeta _propuestaJsonMeta = const VerificationMeta(
    'propuestaJson',
  );
  @override
  late final GeneratedColumn<String> propuestaJson = GeneratedColumn<String>(
    'propuesta_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorDetalleMeta = const VerificationMeta(
    'errorDetalle',
  );
  @override
  late final GeneratedColumn<String> errorDetalle = GeneratedColumn<String>(
    'error_detalle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transaccionIdMeta = const VerificationMeta(
    'transaccionId',
  );
  @override
  late final GeneratedColumn<int> transaccionId = GeneratedColumn<int>(
    'transaccion_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transacciones (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _procesadaAtMeta = const VerificationMeta(
    'procesadaAt',
  );
  @override
  late final GeneratedColumn<int> procesadaAt = GeneratedColumn<int>(
    'procesada_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    canal,
    origen,
    messageIdExterno,
    textoCrudo,
    adjuntoPath,
    estado,
    propuestaJson,
    errorDetalle,
    transaccionId,
    createdAt,
    procesadaAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'captura_entrante';
  @override
  VerificationContext validateIntegrity(
    Insertable<CapturaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('canal')) {
      context.handle(
        _canalMeta,
        canal.isAcceptableOrUnknown(data['canal']!, _canalMeta),
      );
    } else if (isInserting) {
      context.missing(_canalMeta);
    }
    if (data.containsKey('origen')) {
      context.handle(
        _origenMeta,
        origen.isAcceptableOrUnknown(data['origen']!, _origenMeta),
      );
    } else if (isInserting) {
      context.missing(_origenMeta);
    }
    if (data.containsKey('message_id_externo')) {
      context.handle(
        _messageIdExternoMeta,
        messageIdExterno.isAcceptableOrUnknown(
          data['message_id_externo']!,
          _messageIdExternoMeta,
        ),
      );
    }
    if (data.containsKey('texto_crudo')) {
      context.handle(
        _textoCrudoMeta,
        textoCrudo.isAcceptableOrUnknown(data['texto_crudo']!, _textoCrudoMeta),
      );
    }
    if (data.containsKey('adjunto_path')) {
      context.handle(
        _adjuntoPathMeta,
        adjuntoPath.isAcceptableOrUnknown(
          data['adjunto_path']!,
          _adjuntoPathMeta,
        ),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('propuesta_json')) {
      context.handle(
        _propuestaJsonMeta,
        propuestaJson.isAcceptableOrUnknown(
          data['propuesta_json']!,
          _propuestaJsonMeta,
        ),
      );
    }
    if (data.containsKey('error_detalle')) {
      context.handle(
        _errorDetalleMeta,
        errorDetalle.isAcceptableOrUnknown(
          data['error_detalle']!,
          _errorDetalleMeta,
        ),
      );
    }
    if (data.containsKey('transaccion_id')) {
      context.handle(
        _transaccionIdMeta,
        transaccionId.isAcceptableOrUnknown(
          data['transaccion_id']!,
          _transaccionIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('procesada_at')) {
      context.handle(
        _procesadaAtMeta,
        procesadaAt.isAcceptableOrUnknown(
          data['procesada_at']!,
          _procesadaAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CapturaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CapturaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      canal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canal'],
      )!,
      origen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origen'],
      )!,
      messageIdExterno: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id_externo'],
      ),
      textoCrudo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}texto_crudo'],
      ),
      adjuntoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adjunto_path'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      propuestaJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}propuesta_json'],
      ),
      errorDetalle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_detalle'],
      ),
      transaccionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaccion_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      procesadaAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}procesada_at'],
      ),
    );
  }

  @override
  $CapturaEntranteTable createAlias(String alias) {
    return $CapturaEntranteTable(attachedDatabase, alias);
  }
}

class CapturaRow extends DataClass implements Insertable<CapturaRow> {
  final int id;
  final String canal;
  final String origen;
  final String? messageIdExterno;
  final String? textoCrudo;
  final String? adjuntoPath;
  final String estado;
  final String? propuestaJson;
  final String? errorDetalle;
  final int? transaccionId;
  final int createdAt;
  final int? procesadaAt;
  const CapturaRow({
    required this.id,
    required this.canal,
    required this.origen,
    this.messageIdExterno,
    this.textoCrudo,
    this.adjuntoPath,
    required this.estado,
    this.propuestaJson,
    this.errorDetalle,
    this.transaccionId,
    required this.createdAt,
    this.procesadaAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['canal'] = Variable<String>(canal);
    map['origen'] = Variable<String>(origen);
    if (!nullToAbsent || messageIdExterno != null) {
      map['message_id_externo'] = Variable<String>(messageIdExterno);
    }
    if (!nullToAbsent || textoCrudo != null) {
      map['texto_crudo'] = Variable<String>(textoCrudo);
    }
    if (!nullToAbsent || adjuntoPath != null) {
      map['adjunto_path'] = Variable<String>(adjuntoPath);
    }
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || propuestaJson != null) {
      map['propuesta_json'] = Variable<String>(propuestaJson);
    }
    if (!nullToAbsent || errorDetalle != null) {
      map['error_detalle'] = Variable<String>(errorDetalle);
    }
    if (!nullToAbsent || transaccionId != null) {
      map['transaccion_id'] = Variable<int>(transaccionId);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || procesadaAt != null) {
      map['procesada_at'] = Variable<int>(procesadaAt);
    }
    return map;
  }

  CapturaEntranteCompanion toCompanion(bool nullToAbsent) {
    return CapturaEntranteCompanion(
      id: Value(id),
      canal: Value(canal),
      origen: Value(origen),
      messageIdExterno: messageIdExterno == null && nullToAbsent
          ? const Value.absent()
          : Value(messageIdExterno),
      textoCrudo: textoCrudo == null && nullToAbsent
          ? const Value.absent()
          : Value(textoCrudo),
      adjuntoPath: adjuntoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(adjuntoPath),
      estado: Value(estado),
      propuestaJson: propuestaJson == null && nullToAbsent
          ? const Value.absent()
          : Value(propuestaJson),
      errorDetalle: errorDetalle == null && nullToAbsent
          ? const Value.absent()
          : Value(errorDetalle),
      transaccionId: transaccionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transaccionId),
      createdAt: Value(createdAt),
      procesadaAt: procesadaAt == null && nullToAbsent
          ? const Value.absent()
          : Value(procesadaAt),
    );
  }

  factory CapturaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CapturaRow(
      id: serializer.fromJson<int>(json['id']),
      canal: serializer.fromJson<String>(json['canal']),
      origen: serializer.fromJson<String>(json['origen']),
      messageIdExterno: serializer.fromJson<String?>(json['messageIdExterno']),
      textoCrudo: serializer.fromJson<String?>(json['textoCrudo']),
      adjuntoPath: serializer.fromJson<String?>(json['adjuntoPath']),
      estado: serializer.fromJson<String>(json['estado']),
      propuestaJson: serializer.fromJson<String?>(json['propuestaJson']),
      errorDetalle: serializer.fromJson<String?>(json['errorDetalle']),
      transaccionId: serializer.fromJson<int?>(json['transaccionId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      procesadaAt: serializer.fromJson<int?>(json['procesadaAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'canal': serializer.toJson<String>(canal),
      'origen': serializer.toJson<String>(origen),
      'messageIdExterno': serializer.toJson<String?>(messageIdExterno),
      'textoCrudo': serializer.toJson<String?>(textoCrudo),
      'adjuntoPath': serializer.toJson<String?>(adjuntoPath),
      'estado': serializer.toJson<String>(estado),
      'propuestaJson': serializer.toJson<String?>(propuestaJson),
      'errorDetalle': serializer.toJson<String?>(errorDetalle),
      'transaccionId': serializer.toJson<int?>(transaccionId),
      'createdAt': serializer.toJson<int>(createdAt),
      'procesadaAt': serializer.toJson<int?>(procesadaAt),
    };
  }

  CapturaRow copyWith({
    int? id,
    String? canal,
    String? origen,
    Value<String?> messageIdExterno = const Value.absent(),
    Value<String?> textoCrudo = const Value.absent(),
    Value<String?> adjuntoPath = const Value.absent(),
    String? estado,
    Value<String?> propuestaJson = const Value.absent(),
    Value<String?> errorDetalle = const Value.absent(),
    Value<int?> transaccionId = const Value.absent(),
    int? createdAt,
    Value<int?> procesadaAt = const Value.absent(),
  }) => CapturaRow(
    id: id ?? this.id,
    canal: canal ?? this.canal,
    origen: origen ?? this.origen,
    messageIdExterno: messageIdExterno.present
        ? messageIdExterno.value
        : this.messageIdExterno,
    textoCrudo: textoCrudo.present ? textoCrudo.value : this.textoCrudo,
    adjuntoPath: adjuntoPath.present ? adjuntoPath.value : this.adjuntoPath,
    estado: estado ?? this.estado,
    propuestaJson: propuestaJson.present
        ? propuestaJson.value
        : this.propuestaJson,
    errorDetalle: errorDetalle.present ? errorDetalle.value : this.errorDetalle,
    transaccionId: transaccionId.present
        ? transaccionId.value
        : this.transaccionId,
    createdAt: createdAt ?? this.createdAt,
    procesadaAt: procesadaAt.present ? procesadaAt.value : this.procesadaAt,
  );
  CapturaRow copyWithCompanion(CapturaEntranteCompanion data) {
    return CapturaRow(
      id: data.id.present ? data.id.value : this.id,
      canal: data.canal.present ? data.canal.value : this.canal,
      origen: data.origen.present ? data.origen.value : this.origen,
      messageIdExterno: data.messageIdExterno.present
          ? data.messageIdExterno.value
          : this.messageIdExterno,
      textoCrudo: data.textoCrudo.present
          ? data.textoCrudo.value
          : this.textoCrudo,
      adjuntoPath: data.adjuntoPath.present
          ? data.adjuntoPath.value
          : this.adjuntoPath,
      estado: data.estado.present ? data.estado.value : this.estado,
      propuestaJson: data.propuestaJson.present
          ? data.propuestaJson.value
          : this.propuestaJson,
      errorDetalle: data.errorDetalle.present
          ? data.errorDetalle.value
          : this.errorDetalle,
      transaccionId: data.transaccionId.present
          ? data.transaccionId.value
          : this.transaccionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      procesadaAt: data.procesadaAt.present
          ? data.procesadaAt.value
          : this.procesadaAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CapturaRow(')
          ..write('id: $id, ')
          ..write('canal: $canal, ')
          ..write('origen: $origen, ')
          ..write('messageIdExterno: $messageIdExterno, ')
          ..write('textoCrudo: $textoCrudo, ')
          ..write('adjuntoPath: $adjuntoPath, ')
          ..write('estado: $estado, ')
          ..write('propuestaJson: $propuestaJson, ')
          ..write('errorDetalle: $errorDetalle, ')
          ..write('transaccionId: $transaccionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('procesadaAt: $procesadaAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    canal,
    origen,
    messageIdExterno,
    textoCrudo,
    adjuntoPath,
    estado,
    propuestaJson,
    errorDetalle,
    transaccionId,
    createdAt,
    procesadaAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CapturaRow &&
          other.id == this.id &&
          other.canal == this.canal &&
          other.origen == this.origen &&
          other.messageIdExterno == this.messageIdExterno &&
          other.textoCrudo == this.textoCrudo &&
          other.adjuntoPath == this.adjuntoPath &&
          other.estado == this.estado &&
          other.propuestaJson == this.propuestaJson &&
          other.errorDetalle == this.errorDetalle &&
          other.transaccionId == this.transaccionId &&
          other.createdAt == this.createdAt &&
          other.procesadaAt == this.procesadaAt);
}

class CapturaEntranteCompanion extends UpdateCompanion<CapturaRow> {
  final Value<int> id;
  final Value<String> canal;
  final Value<String> origen;
  final Value<String?> messageIdExterno;
  final Value<String?> textoCrudo;
  final Value<String?> adjuntoPath;
  final Value<String> estado;
  final Value<String?> propuestaJson;
  final Value<String?> errorDetalle;
  final Value<int?> transaccionId;
  final Value<int> createdAt;
  final Value<int?> procesadaAt;
  const CapturaEntranteCompanion({
    this.id = const Value.absent(),
    this.canal = const Value.absent(),
    this.origen = const Value.absent(),
    this.messageIdExterno = const Value.absent(),
    this.textoCrudo = const Value.absent(),
    this.adjuntoPath = const Value.absent(),
    this.estado = const Value.absent(),
    this.propuestaJson = const Value.absent(),
    this.errorDetalle = const Value.absent(),
    this.transaccionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.procesadaAt = const Value.absent(),
  });
  CapturaEntranteCompanion.insert({
    this.id = const Value.absent(),
    required String canal,
    required String origen,
    this.messageIdExterno = const Value.absent(),
    this.textoCrudo = const Value.absent(),
    this.adjuntoPath = const Value.absent(),
    this.estado = const Value.absent(),
    this.propuestaJson = const Value.absent(),
    this.errorDetalle = const Value.absent(),
    this.transaccionId = const Value.absent(),
    required int createdAt,
    this.procesadaAt = const Value.absent(),
  }) : canal = Value(canal),
       origen = Value(origen),
       createdAt = Value(createdAt);
  static Insertable<CapturaRow> custom({
    Expression<int>? id,
    Expression<String>? canal,
    Expression<String>? origen,
    Expression<String>? messageIdExterno,
    Expression<String>? textoCrudo,
    Expression<String>? adjuntoPath,
    Expression<String>? estado,
    Expression<String>? propuestaJson,
    Expression<String>? errorDetalle,
    Expression<int>? transaccionId,
    Expression<int>? createdAt,
    Expression<int>? procesadaAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (canal != null) 'canal': canal,
      if (origen != null) 'origen': origen,
      if (messageIdExterno != null) 'message_id_externo': messageIdExterno,
      if (textoCrudo != null) 'texto_crudo': textoCrudo,
      if (adjuntoPath != null) 'adjunto_path': adjuntoPath,
      if (estado != null) 'estado': estado,
      if (propuestaJson != null) 'propuesta_json': propuestaJson,
      if (errorDetalle != null) 'error_detalle': errorDetalle,
      if (transaccionId != null) 'transaccion_id': transaccionId,
      if (createdAt != null) 'created_at': createdAt,
      if (procesadaAt != null) 'procesada_at': procesadaAt,
    });
  }

  CapturaEntranteCompanion copyWith({
    Value<int>? id,
    Value<String>? canal,
    Value<String>? origen,
    Value<String?>? messageIdExterno,
    Value<String?>? textoCrudo,
    Value<String?>? adjuntoPath,
    Value<String>? estado,
    Value<String?>? propuestaJson,
    Value<String?>? errorDetalle,
    Value<int?>? transaccionId,
    Value<int>? createdAt,
    Value<int?>? procesadaAt,
  }) {
    return CapturaEntranteCompanion(
      id: id ?? this.id,
      canal: canal ?? this.canal,
      origen: origen ?? this.origen,
      messageIdExterno: messageIdExterno ?? this.messageIdExterno,
      textoCrudo: textoCrudo ?? this.textoCrudo,
      adjuntoPath: adjuntoPath ?? this.adjuntoPath,
      estado: estado ?? this.estado,
      propuestaJson: propuestaJson ?? this.propuestaJson,
      errorDetalle: errorDetalle ?? this.errorDetalle,
      transaccionId: transaccionId ?? this.transaccionId,
      createdAt: createdAt ?? this.createdAt,
      procesadaAt: procesadaAt ?? this.procesadaAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (canal.present) {
      map['canal'] = Variable<String>(canal.value);
    }
    if (origen.present) {
      map['origen'] = Variable<String>(origen.value);
    }
    if (messageIdExterno.present) {
      map['message_id_externo'] = Variable<String>(messageIdExterno.value);
    }
    if (textoCrudo.present) {
      map['texto_crudo'] = Variable<String>(textoCrudo.value);
    }
    if (adjuntoPath.present) {
      map['adjunto_path'] = Variable<String>(adjuntoPath.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (propuestaJson.present) {
      map['propuesta_json'] = Variable<String>(propuestaJson.value);
    }
    if (errorDetalle.present) {
      map['error_detalle'] = Variable<String>(errorDetalle.value);
    }
    if (transaccionId.present) {
      map['transaccion_id'] = Variable<int>(transaccionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (procesadaAt.present) {
      map['procesada_at'] = Variable<int>(procesadaAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CapturaEntranteCompanion(')
          ..write('id: $id, ')
          ..write('canal: $canal, ')
          ..write('origen: $origen, ')
          ..write('messageIdExterno: $messageIdExterno, ')
          ..write('textoCrudo: $textoCrudo, ')
          ..write('adjuntoPath: $adjuntoPath, ')
          ..write('estado: $estado, ')
          ..write('propuestaJson: $propuestaJson, ')
          ..write('errorDetalle: $errorDetalle, ')
          ..write('transaccionId: $transaccionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('procesadaAt: $procesadaAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CuentasTable cuentas = $CuentasTable(this);
  late final $CategoriasTable categorias = $CategoriasTable(this);
  late final $SubcategoriasTable subcategorias = $SubcategoriasTable(this);
  late final $EtiquetasTable etiquetas = $EtiquetasTable(this);
  late final $RecibosTable recibos = $RecibosTable(this);
  late final $TransaccionesTable transacciones = $TransaccionesTable(this);
  late final $TransaccionEtiquetasTable transaccionEtiquetas =
      $TransaccionEtiquetasTable(this);
  late final $TasasCambioTable tasasCambio = $TasasCambioTable(this);
  late final $ConfiguracionTable configuracion = $ConfiguracionTable(this);
  late final $CapturaEntranteTable capturaEntrante = $CapturaEntranteTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cuentas,
    categorias,
    subcategorias,
    etiquetas,
    recibos,
    transacciones,
    transaccionEtiquetas,
    tasasCambio,
    configuracion,
    capturaEntrante,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'transacciones',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transaccion_etiquetas', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'etiquetas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transaccion_etiquetas', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CuentasTableCreateCompanionBuilder = CuentasCompanion Function({
  Value<int> id,
  required String nombre,
  required String tipo,
  Value<int> saldoInicialCentavos,
  Value<String> moneda,
  Value<bool> activa,
  Value<String?> nota,
  required int creadoEn,
  required int actualizadoEn,
  Value<int?> eliminadoEn,
});
typedef $$CuentasTableUpdateCompanionBuilder = CuentasCompanion Function({
  Value<int> id,
  Value<String> nombre,
  Value<String> tipo,
  Value<int> saldoInicialCentavos,
  Value<String> moneda,
  Value<bool> activa,
  Value<String?> nota,
  Value<int> creadoEn,
  Value<int> actualizadoEn,
  Value<int?> eliminadoEn,
});

class $$CuentasTableFilterComposer
    extends Composer<_$AppDatabase, $CuentasTable> {
  $$CuentasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get saldoInicialCentavos => $composableBuilder(
    column: $table.saldoInicialCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moneda => $composableBuilder(
    column: $table.moneda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activa => $composableBuilder(
    column: $table.activa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CuentasTableOrderingComposer
    extends Composer<_$AppDatabase, $CuentasTable> {
  $$CuentasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get saldoInicialCentavos => $composableBuilder(
    column: $table.saldoInicialCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moneda => $composableBuilder(
    column: $table.moneda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activa => $composableBuilder(
    column: $table.activa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CuentasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CuentasTable> {
  $$CuentasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get saldoInicialCentavos => $composableBuilder(
    column: $table.saldoInicialCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get moneda =>
      $composableBuilder(column: $table.moneda, builder: (column) => column);

  GeneratedColumn<bool> get activa =>
      $composableBuilder(column: $table.activa, builder: (column) => column);

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);

  GeneratedColumn<int> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => column,
  );
}

class $$CuentasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CuentasTable,
          CuentaRow,
          $$CuentasTableFilterComposer,
          $$CuentasTableOrderingComposer,
          $$CuentasTableAnnotationComposer,
          $$CuentasTableCreateCompanionBuilder,
          $$CuentasTableUpdateCompanionBuilder,
          (CuentaRow, BaseReferences<_$AppDatabase, $CuentasTable, CuentaRow>),
          CuentaRow,
          PrefetchHooks Function()
        > {
  $$CuentasTableTableManager(_$AppDatabase db, $CuentasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CuentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CuentasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CuentasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<int> saldoInicialCentavos = const Value.absent(),
                Value<String> moneda = const Value.absent(),
                Value<bool> activa = const Value.absent(),
                Value<String?> nota = const Value.absent(),
                Value<int> creadoEn = const Value.absent(),
                Value<int> actualizadoEn = const Value.absent(),
                Value<int?> eliminadoEn = const Value.absent(),
              }) => CuentasCompanion(
                id: id,
                nombre: nombre,
                tipo: tipo,
                saldoInicialCentavos: saldoInicialCentavos,
                moneda: moneda,
                activa: activa,
                nota: nota,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                required String tipo,
                Value<int> saldoInicialCentavos = const Value.absent(),
                Value<String> moneda = const Value.absent(),
                Value<bool> activa = const Value.absent(),
                Value<String?> nota = const Value.absent(),
                required int creadoEn,
                required int actualizadoEn,
                Value<int?> eliminadoEn = const Value.absent(),
              }) => CuentasCompanion.insert(
                id: id,
                nombre: nombre,
                tipo: tipo,
                saldoInicialCentavos: saldoInicialCentavos,
                moneda: moneda,
                activa: activa,
                nota: nota,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CuentasTable, CuentaRow>(table),
                  BaseReferences<_$AppDatabase, $CuentasTable, CuentaRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CuentasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CuentasTable,
      CuentaRow,
      $$CuentasTableFilterComposer,
      $$CuentasTableOrderingComposer,
      $$CuentasTableAnnotationComposer,
      $$CuentasTableCreateCompanionBuilder,
      $$CuentasTableUpdateCompanionBuilder,
      (CuentaRow, BaseReferences<_$AppDatabase, $CuentasTable, CuentaRow>),
      CuentaRow,
      PrefetchHooks Function()
    >;
typedef $$CategoriasTableCreateCompanionBuilder = CategoriasCompanion Function({
  Value<int> id,
  required String nombre,
  required String naturaleza,
  Value<String?> icono,
  Value<String?> color,
  Value<bool> predefinida,
  Value<int> orden,
  Value<bool> archivada,
  required int creadoEn,
  required int actualizadoEn,
  Value<int?> eliminadoEn,
});
typedef $$CategoriasTableUpdateCompanionBuilder = CategoriasCompanion Function({
  Value<int> id,
  Value<String> nombre,
  Value<String> naturaleza,
  Value<String?> icono,
  Value<String?> color,
  Value<bool> predefinida,
  Value<int> orden,
  Value<bool> archivada,
  Value<int> creadoEn,
  Value<int> actualizadoEn,
  Value<int?> eliminadoEn,
});

final class $$CategoriasTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriasTable, CategoriaRow> {
  $$CategoriasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubcategoriasTable, List<SubcategoriaRow>>
  _subcategoriasRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.subcategorias,
    aliasName: 'categorias__id__subcategorias__categoria_id',
  );

  $$SubcategoriasTableProcessedTableManager get subcategoriasRefs {
    final manager = $$SubcategoriasTableTableManager(
      $_db,
      $_db.subcategorias,
    ).filter((f) => f.categoriaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_subcategoriasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransaccionesTable, List<TransaccionRow>>
  _transaccionesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transacciones,
    aliasName: 'categorias__id__transacciones__categoria_id',
  );

  $$TransaccionesTableProcessedTableManager get transaccionesRefs {
    final manager = $$TransaccionesTableTableManager(
      $_db,
      $_db.transacciones,
    ).filter((f) => f.categoriaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transaccionesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriasTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naturaleza => $composableBuilder(
    column: $table.naturaleza,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icono => $composableBuilder(
    column: $table.icono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get predefinida => $composableBuilder(
    column: $table.predefinida,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archivada => $composableBuilder(
    column: $table.archivada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> subcategoriasRefs(
    Expression<bool> Function($$SubcategoriasTableFilterComposer f) f,
  ) {
    final $$SubcategoriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subcategorias,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubcategoriasTableFilterComposer(
            $db: $db,
            $table: $db.subcategorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transaccionesRefs(
    Expression<bool> Function($$TransaccionesTableFilterComposer f) f,
  ) {
    final $$TransaccionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableFilterComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriasTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naturaleza => $composableBuilder(
    column: $table.naturaleza,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icono => $composableBuilder(
    column: $table.icono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get predefinida => $composableBuilder(
    column: $table.predefinida,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archivada => $composableBuilder(
    column: $table.archivada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get naturaleza => $composableBuilder(
    column: $table.naturaleza,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icono =>
      $composableBuilder(column: $table.icono, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get predefinida => $composableBuilder(
    column: $table.predefinida,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<bool> get archivada =>
      $composableBuilder(column: $table.archivada, builder: (column) => column);

  GeneratedColumn<int> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => column,
  );

  Expression<T> subcategoriasRefs<T extends Object>(
    Expression<T> Function($$SubcategoriasTableAnnotationComposer a) f,
  ) {
    final $$SubcategoriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subcategorias,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubcategoriasTableAnnotationComposer(
            $db: $db,
            $table: $db.subcategorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transaccionesRefs<T extends Object>(
    Expression<T> Function($$TransaccionesTableAnnotationComposer a) f,
  ) {
    final $$TransaccionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableAnnotationComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriasTable,
          CategoriaRow,
          $$CategoriasTableFilterComposer,
          $$CategoriasTableOrderingComposer,
          $$CategoriasTableAnnotationComposer,
          $$CategoriasTableCreateCompanionBuilder,
          $$CategoriasTableUpdateCompanionBuilder,
          (CategoriaRow, $$CategoriasTableReferences),
          CategoriaRow,
          PrefetchHooks Function({
            bool subcategoriasRefs,
            bool transaccionesRefs,
          })
        > {
  $$CategoriasTableTableManager(_$AppDatabase db, $CategoriasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> naturaleza = const Value.absent(),
                Value<String?> icono = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> predefinida = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<bool> archivada = const Value.absent(),
                Value<int> creadoEn = const Value.absent(),
                Value<int> actualizadoEn = const Value.absent(),
                Value<int?> eliminadoEn = const Value.absent(),
              }) => CategoriasCompanion(
                id: id,
                nombre: nombre,
                naturaleza: naturaleza,
                icono: icono,
                color: color,
                predefinida: predefinida,
                orden: orden,
                archivada: archivada,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                required String naturaleza,
                Value<String?> icono = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> predefinida = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<bool> archivada = const Value.absent(),
                required int creadoEn,
                required int actualizadoEn,
                Value<int?> eliminadoEn = const Value.absent(),
              }) => CategoriasCompanion.insert(
                id: id,
                nombre: nombre,
                naturaleza: naturaleza,
                icono: icono,
                color: color,
                predefinida: predefinida,
                orden: orden,
                archivada: archivada,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriasTable, CategoriaRow>(table),
                  $$CategoriasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({subcategoriasRefs = false, transaccionesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (subcategoriasRefs) db.subcategorias,
                    if (transaccionesRefs) db.transacciones,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (subcategoriasRefs)
                        await $_getPrefetchedDataByColumns<
                          CategoriaRow,
                          $CategoriasTable,
                          SubcategoriaRow,
                          $SubcategoriasTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriasTableReferences
                              ._subcategoriasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriasTableReferences(
                                db,
                                table,
                                p0,
                              ).subcategoriasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'categoria_id',
                          typedResults: items,
                        ),
                      if (transaccionesRefs)
                        await $_getPrefetchedDataByColumns<
                          CategoriaRow,
                          $CategoriasTable,
                          TransaccionRow,
                          $TransaccionesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriasTableReferences
                              ._transaccionesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriasTableReferences(
                                db,
                                table,
                                p0,
                              ).transaccionesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'categoria_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriasTable,
      CategoriaRow,
      $$CategoriasTableFilterComposer,
      $$CategoriasTableOrderingComposer,
      $$CategoriasTableAnnotationComposer,
      $$CategoriasTableCreateCompanionBuilder,
      $$CategoriasTableUpdateCompanionBuilder,
      (CategoriaRow, $$CategoriasTableReferences),
      CategoriaRow,
      PrefetchHooks Function({bool subcategoriasRefs, bool transaccionesRefs})
    >;
typedef $$SubcategoriasTableCreateCompanionBuilder =
    SubcategoriasCompanion Function({
      Value<int> id,
      required int categoriaId,
      required String nombre,
      Value<bool> predefinida,
      Value<bool> archivada,
      required int creadoEn,
      required int actualizadoEn,
      Value<int?> eliminadoEn,
    });
typedef $$SubcategoriasTableUpdateCompanionBuilder =
    SubcategoriasCompanion Function({
      Value<int> id,
      Value<int> categoriaId,
      Value<String> nombre,
      Value<bool> predefinida,
      Value<bool> archivada,
      Value<int> creadoEn,
      Value<int> actualizadoEn,
      Value<int?> eliminadoEn,
    });

final class $$SubcategoriasTableReferences
    extends
        BaseReferences<_$AppDatabase, $SubcategoriasTable, SubcategoriaRow> {
  $$SubcategoriasTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriasTable _categoriaIdTable(_$AppDatabase db) =>
      db.categorias.createAlias('subcategorias__categoria_id__categorias__id');

  $$CategoriasTableProcessedTableManager get categoriaId {
    final $_column = $_itemColumn<int>('categoria_id')!;

    final manager = $$CategoriasTableTableManager(
      $_db,
      $_db.categorias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoriaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransaccionesTable, List<TransaccionRow>>
  _transaccionesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transacciones,
    aliasName: 'subcategorias__id__transacciones__subcategoria_id',
  );

  $$TransaccionesTableProcessedTableManager get transaccionesRefs {
    final manager = $$TransaccionesTableTableManager(
      $_db,
      $_db.transacciones,
    ).filter((f) => f.subcategoriaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transaccionesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubcategoriasTableFilterComposer
    extends Composer<_$AppDatabase, $SubcategoriasTable> {
  $$SubcategoriasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get predefinida => $composableBuilder(
    column: $table.predefinida,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archivada => $composableBuilder(
    column: $table.archivada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriasTableFilterComposer get categoriaId {
    final $$CategoriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableFilterComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transaccionesRefs(
    Expression<bool> Function($$TransaccionesTableFilterComposer f) f,
  ) {
    final $$TransaccionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.subcategoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableFilterComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubcategoriasTableOrderingComposer
    extends Composer<_$AppDatabase, $SubcategoriasTable> {
  $$SubcategoriasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get predefinida => $composableBuilder(
    column: $table.predefinida,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archivada => $composableBuilder(
    column: $table.archivada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriasTableOrderingComposer get categoriaId {
    final $$CategoriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableOrderingComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubcategoriasTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubcategoriasTable> {
  $$SubcategoriasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<bool> get predefinida => $composableBuilder(
    column: $table.predefinida,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archivada =>
      $composableBuilder(column: $table.archivada, builder: (column) => column);

  GeneratedColumn<int> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => column,
  );

  $$CategoriasTableAnnotationComposer get categoriaId {
    final $$CategoriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableAnnotationComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transaccionesRefs<T extends Object>(
    Expression<T> Function($$TransaccionesTableAnnotationComposer a) f,
  ) {
    final $$TransaccionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.subcategoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableAnnotationComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubcategoriasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubcategoriasTable,
          SubcategoriaRow,
          $$SubcategoriasTableFilterComposer,
          $$SubcategoriasTableOrderingComposer,
          $$SubcategoriasTableAnnotationComposer,
          $$SubcategoriasTableCreateCompanionBuilder,
          $$SubcategoriasTableUpdateCompanionBuilder,
          (SubcategoriaRow, $$SubcategoriasTableReferences),
          SubcategoriaRow,
          PrefetchHooks Function({bool categoriaId, bool transaccionesRefs})
        > {
  $$SubcategoriasTableTableManager(_$AppDatabase db, $SubcategoriasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubcategoriasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubcategoriasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubcategoriasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> categoriaId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<bool> predefinida = const Value.absent(),
                Value<bool> archivada = const Value.absent(),
                Value<int> creadoEn = const Value.absent(),
                Value<int> actualizadoEn = const Value.absent(),
                Value<int?> eliminadoEn = const Value.absent(),
              }) => SubcategoriasCompanion(
                id: id,
                categoriaId: categoriaId,
                nombre: nombre,
                predefinida: predefinida,
                archivada: archivada,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int categoriaId,
                required String nombre,
                Value<bool> predefinida = const Value.absent(),
                Value<bool> archivada = const Value.absent(),
                required int creadoEn,
                required int actualizadoEn,
                Value<int?> eliminadoEn = const Value.absent(),
              }) => SubcategoriasCompanion.insert(
                id: id,
                categoriaId: categoriaId,
                nombre: nombre,
                predefinida: predefinida,
                archivada: archivada,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SubcategoriasTable, SubcategoriaRow>(table),
                  $$SubcategoriasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({categoriaId = false, transaccionesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transaccionesRefs) db.transacciones,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoriaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoriaId,
                            referencedTable: $$SubcategoriasTableReferences
                                ._categoriaIdTable(db),
                            referencedColumn: $$SubcategoriasTableReferences
                                ._categoriaIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transaccionesRefs)
                        await $_getPrefetchedDataByColumns<
                          SubcategoriaRow,
                          $SubcategoriasTable,
                          TransaccionRow,
                          $TransaccionesTable
                        >(
                          currentTable: table,
                          referencedTable: $$SubcategoriasTableReferences
                              ._transaccionesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubcategoriasTableReferences(
                                db,
                                table,
                                p0,
                              ).transaccionesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'subcategoria_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SubcategoriasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubcategoriasTable,
      SubcategoriaRow,
      $$SubcategoriasTableFilterComposer,
      $$SubcategoriasTableOrderingComposer,
      $$SubcategoriasTableAnnotationComposer,
      $$SubcategoriasTableCreateCompanionBuilder,
      $$SubcategoriasTableUpdateCompanionBuilder,
      (SubcategoriaRow, $$SubcategoriasTableReferences),
      SubcategoriaRow,
      PrefetchHooks Function({bool categoriaId, bool transaccionesRefs})
    >;
typedef $$EtiquetasTableCreateCompanionBuilder = EtiquetasCompanion Function({
  Value<int> id,
  required String nombre,
  Value<String?> color,
  required int creadoEn,
  required int actualizadoEn,
  Value<int?> eliminadoEn,
});
typedef $$EtiquetasTableUpdateCompanionBuilder = EtiquetasCompanion Function({
  Value<int> id,
  Value<String> nombre,
  Value<String?> color,
  Value<int> creadoEn,
  Value<int> actualizadoEn,
  Value<int?> eliminadoEn,
});

final class $$EtiquetasTableReferences
    extends BaseReferences<_$AppDatabase, $EtiquetasTable, EtiquetaRow> {
  $$EtiquetasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $TransaccionEtiquetasTable,
    List<TransaccionEtiquetaRow>
  >
  _transaccionEtiquetasRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transaccionEtiquetas,
        aliasName: 'etiquetas__id__transaccion_etiquetas__etiqueta_id',
      );

  $$TransaccionEtiquetasTableProcessedTableManager
  get transaccionEtiquetasRefs {
    final manager = $$TransaccionEtiquetasTableTableManager(
      $_db,
      $_db.transaccionEtiquetas,
    ).filter((f) => f.etiquetaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transaccionEtiquetasRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EtiquetasTableFilterComposer
    extends Composer<_$AppDatabase, $EtiquetasTable> {
  $$EtiquetasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transaccionEtiquetasRefs(
    Expression<bool> Function($$TransaccionEtiquetasTableFilterComposer f) f,
  ) {
    final $$TransaccionEtiquetasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transaccionEtiquetas,
      getReferencedColumn: (t) => t.etiquetaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionEtiquetasTableFilterComposer(
            $db: $db,
            $table: $db.transaccionEtiquetas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EtiquetasTableOrderingComposer
    extends Composer<_$AppDatabase, $EtiquetasTable> {
  $$EtiquetasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EtiquetasTableAnnotationComposer
    extends Composer<_$AppDatabase, $EtiquetasTable> {
  $$EtiquetasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => column,
  );

  Expression<T> transaccionEtiquetasRefs<T extends Object>(
    Expression<T> Function($$TransaccionEtiquetasTableAnnotationComposer a) f,
  ) {
    final $$TransaccionEtiquetasTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transaccionEtiquetas,
          getReferencedColumn: (t) => t.etiquetaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransaccionEtiquetasTableAnnotationComposer(
                $db: $db,
                $table: $db.transaccionEtiquetas,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$EtiquetasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EtiquetasTable,
          EtiquetaRow,
          $$EtiquetasTableFilterComposer,
          $$EtiquetasTableOrderingComposer,
          $$EtiquetasTableAnnotationComposer,
          $$EtiquetasTableCreateCompanionBuilder,
          $$EtiquetasTableUpdateCompanionBuilder,
          (EtiquetaRow, $$EtiquetasTableReferences),
          EtiquetaRow,
          PrefetchHooks Function({bool transaccionEtiquetasRefs})
        > {
  $$EtiquetasTableTableManager(_$AppDatabase db, $EtiquetasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EtiquetasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EtiquetasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EtiquetasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> creadoEn = const Value.absent(),
                Value<int> actualizadoEn = const Value.absent(),
                Value<int?> eliminadoEn = const Value.absent(),
              }) => EtiquetasCompanion(
                id: id,
                nombre: nombre,
                color: color,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                Value<String?> color = const Value.absent(),
                required int creadoEn,
                required int actualizadoEn,
                Value<int?> eliminadoEn = const Value.absent(),
              }) => EtiquetasCompanion.insert(
                id: id,
                nombre: nombre,
                color: color,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EtiquetasTable, EtiquetaRow>(table),
                  $$EtiquetasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transaccionEtiquetasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transaccionEtiquetasRefs) db.transaccionEtiquetas,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transaccionEtiquetasRefs)
                    await $_getPrefetchedDataByColumns<
                      EtiquetaRow,
                      $EtiquetasTable,
                      TransaccionEtiquetaRow,
                      $TransaccionEtiquetasTable
                    >(
                      currentTable: table,
                      referencedTable: $$EtiquetasTableReferences
                          ._transaccionEtiquetasRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$EtiquetasTableReferences(
                            db,
                            table,
                            p0,
                          ).transaccionEtiquetasRefs,
                      currentColumn: 'id',
                      referencedColumn: 'etiqueta_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EtiquetasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EtiquetasTable,
      EtiquetaRow,
      $$EtiquetasTableFilterComposer,
      $$EtiquetasTableOrderingComposer,
      $$EtiquetasTableAnnotationComposer,
      $$EtiquetasTableCreateCompanionBuilder,
      $$EtiquetasTableUpdateCompanionBuilder,
      (EtiquetaRow, $$EtiquetasTableReferences),
      EtiquetaRow,
      PrefetchHooks Function({bool transaccionEtiquetasRefs})
    >;
typedef $$RecibosTableCreateCompanionBuilder = RecibosCompanion Function({
  Value<int> id,
  required String archivoPath,
  required String archivoHash,
  required String mime,
  Value<String?> ocrTexto,
  Value<String?> ocrJson,
  required String estado,
  Value<int?> transaccionId,
  required int creadoEn,
  Value<int?> procesadoEn,
});
typedef $$RecibosTableUpdateCompanionBuilder = RecibosCompanion Function({
  Value<int> id,
  Value<String> archivoPath,
  Value<String> archivoHash,
  Value<String> mime,
  Value<String?> ocrTexto,
  Value<String?> ocrJson,
  Value<String> estado,
  Value<int?> transaccionId,
  Value<int> creadoEn,
  Value<int?> procesadoEn,
});

final class $$RecibosTableReferences
    extends BaseReferences<_$AppDatabase, $RecibosTable, ReciboRow> {
  $$RecibosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TransaccionesTable _transaccionIdTable(_$AppDatabase db) => db
      .transacciones
      .createAlias('recibos__transaccion_id__transacciones__id');

  $$TransaccionesTableProcessedTableManager? get transaccionId {
    final $_column = $_itemColumn<int>('transaccion_id');
    if ($_column == null) return null;
    final manager = $$TransaccionesTableTableManager(
      $_db,
      $_db.transacciones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transaccionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransaccionesTable, List<TransaccionRow>>
  _transaccionesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transacciones,
    aliasName: 'recibos__id__transacciones__recibo_id',
  );

  $$TransaccionesTableProcessedTableManager get transaccionesRefs {
    final manager = $$TransaccionesTableTableManager(
      $_db,
      $_db.transacciones,
    ).filter((f) => f.reciboId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transaccionesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecibosTableFilterComposer
    extends Composer<_$AppDatabase, $RecibosTable> {
  $$RecibosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archivoPath => $composableBuilder(
    column: $table.archivoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archivoHash => $composableBuilder(
    column: $table.archivoHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrTexto => $composableBuilder(
    column: $table.ocrTexto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrJson => $composableBuilder(
    column: $table.ocrJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get procesadoEn => $composableBuilder(
    column: $table.procesadoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$TransaccionesTableFilterComposer get transaccionId {
    final $$TransaccionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaccionId,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableFilterComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transaccionesRefs(
    Expression<bool> Function($$TransaccionesTableFilterComposer f) f,
  ) {
    final $$TransaccionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.reciboId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableFilterComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecibosTableOrderingComposer
    extends Composer<_$AppDatabase, $RecibosTable> {
  $$RecibosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archivoPath => $composableBuilder(
    column: $table.archivoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archivoHash => $composableBuilder(
    column: $table.archivoHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrTexto => $composableBuilder(
    column: $table.ocrTexto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrJson => $composableBuilder(
    column: $table.ocrJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get procesadoEn => $composableBuilder(
    column: $table.procesadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransaccionesTableOrderingComposer get transaccionId {
    final $$TransaccionesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaccionId,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableOrderingComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecibosTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecibosTable> {
  $$RecibosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get archivoPath => $composableBuilder(
    column: $table.archivoPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get archivoHash => $composableBuilder(
    column: $table.archivoHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<String> get ocrTexto =>
      $composableBuilder(column: $table.ocrTexto, builder: (column) => column);

  GeneratedColumn<String> get ocrJson =>
      $composableBuilder(column: $table.ocrJson, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<int> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<int> get procesadoEn => $composableBuilder(
    column: $table.procesadoEn,
    builder: (column) => column,
  );

  $$TransaccionesTableAnnotationComposer get transaccionId {
    final $$TransaccionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaccionId,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableAnnotationComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transaccionesRefs<T extends Object>(
    Expression<T> Function($$TransaccionesTableAnnotationComposer a) f,
  ) {
    final $$TransaccionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.reciboId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableAnnotationComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecibosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecibosTable,
          ReciboRow,
          $$RecibosTableFilterComposer,
          $$RecibosTableOrderingComposer,
          $$RecibosTableAnnotationComposer,
          $$RecibosTableCreateCompanionBuilder,
          $$RecibosTableUpdateCompanionBuilder,
          (ReciboRow, $$RecibosTableReferences),
          ReciboRow,
          PrefetchHooks Function({bool transaccionId, bool transaccionesRefs})
        > {
  $$RecibosTableTableManager(_$AppDatabase db, $RecibosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecibosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecibosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecibosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> archivoPath = const Value.absent(),
                Value<String> archivoHash = const Value.absent(),
                Value<String> mime = const Value.absent(),
                Value<String?> ocrTexto = const Value.absent(),
                Value<String?> ocrJson = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<int?> transaccionId = const Value.absent(),
                Value<int> creadoEn = const Value.absent(),
                Value<int?> procesadoEn = const Value.absent(),
              }) => RecibosCompanion(
                id: id,
                archivoPath: archivoPath,
                archivoHash: archivoHash,
                mime: mime,
                ocrTexto: ocrTexto,
                ocrJson: ocrJson,
                estado: estado,
                transaccionId: transaccionId,
                creadoEn: creadoEn,
                procesadoEn: procesadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String archivoPath,
                required String archivoHash,
                required String mime,
                Value<String?> ocrTexto = const Value.absent(),
                Value<String?> ocrJson = const Value.absent(),
                required String estado,
                Value<int?> transaccionId = const Value.absent(),
                required int creadoEn,
                Value<int?> procesadoEn = const Value.absent(),
              }) => RecibosCompanion.insert(
                id: id,
                archivoPath: archivoPath,
                archivoHash: archivoHash,
                mime: mime,
                ocrTexto: ocrTexto,
                ocrJson: ocrJson,
                estado: estado,
                transaccionId: transaccionId,
                creadoEn: creadoEn,
                procesadoEn: procesadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecibosTable, ReciboRow>(table),
                  $$RecibosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({transaccionId = false, transaccionesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transaccionesRefs) db.transacciones,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (transaccionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.transaccionId,
                            referencedTable: $$RecibosTableReferences
                                ._transaccionIdTable(db),
                            referencedColumn: $$RecibosTableReferences
                                ._transaccionIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transaccionesRefs)
                        await $_getPrefetchedDataByColumns<
                          ReciboRow,
                          $RecibosTable,
                          TransaccionRow,
                          $TransaccionesTable
                        >(
                          currentTable: table,
                          referencedTable: $$RecibosTableReferences
                              ._transaccionesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecibosTableReferences(
                                db,
                                table,
                                p0,
                              ).transaccionesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'recibo_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RecibosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecibosTable,
      ReciboRow,
      $$RecibosTableFilterComposer,
      $$RecibosTableOrderingComposer,
      $$RecibosTableAnnotationComposer,
      $$RecibosTableCreateCompanionBuilder,
      $$RecibosTableUpdateCompanionBuilder,
      (ReciboRow, $$RecibosTableReferences),
      ReciboRow,
      PrefetchHooks Function({bool transaccionId, bool transaccionesRefs})
    >;
typedef $$TransaccionesTableCreateCompanionBuilder =
    TransaccionesCompanion Function({
      Value<int> id,
      required String tipo,
      required int montoCentavos,
      required String moneda,
      required int cuentaId,
      Value<int?> cuentaDestinoId,
      Value<int?> montoDestinoCentavos,
      Value<String?> monedaDestino,
      Value<int?> categoriaId,
      Value<int?> subcategoriaId,
      required String fecha,
      required int fechaHora,
      Value<String?> nota,
      Value<int?> reciboId,
      Value<double?> tasaCambio,
      Value<String> estado,
      Value<String> origen,
      required int creadoEn,
      required int actualizadoEn,
      Value<int?> eliminadoEn,
    });
typedef $$TransaccionesTableUpdateCompanionBuilder =
    TransaccionesCompanion Function({
      Value<int> id,
      Value<String> tipo,
      Value<int> montoCentavos,
      Value<String> moneda,
      Value<int> cuentaId,
      Value<int?> cuentaDestinoId,
      Value<int?> montoDestinoCentavos,
      Value<String?> monedaDestino,
      Value<int?> categoriaId,
      Value<int?> subcategoriaId,
      Value<String> fecha,
      Value<int> fechaHora,
      Value<String?> nota,
      Value<int?> reciboId,
      Value<double?> tasaCambio,
      Value<String> estado,
      Value<String> origen,
      Value<int> creadoEn,
      Value<int> actualizadoEn,
      Value<int?> eliminadoEn,
    });

final class $$TransaccionesTableReferences
    extends BaseReferences<_$AppDatabase, $TransaccionesTable, TransaccionRow> {
  $$TransaccionesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CuentasTable _cuentaIdTable(_$AppDatabase db) =>
      db.cuentas.createAlias('transacciones__cuenta_id__cuentas__id');

  $$CuentasTableProcessedTableManager get cuentaId {
    final $_column = $_itemColumn<int>('cuenta_id')!;

    final manager = $$CuentasTableTableManager(
      $_db,
      $_db.cuentas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cuentaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CuentasTable _cuentaDestinoIdTable(_$AppDatabase db) =>
      db.cuentas.createAlias('transacciones__cuenta_destino_id__cuentas__id');

  $$CuentasTableProcessedTableManager? get cuentaDestinoId {
    final $_column = $_itemColumn<int>('cuenta_destino_id');
    if ($_column == null) return null;
    final manager = $$CuentasTableTableManager(
      $_db,
      $_db.cuentas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cuentaDestinoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriasTable _categoriaIdTable(_$AppDatabase db) =>
      db.categorias.createAlias('transacciones__categoria_id__categorias__id');

  $$CategoriasTableProcessedTableManager? get categoriaId {
    final $_column = $_itemColumn<int>('categoria_id');
    if ($_column == null) return null;
    final manager = $$CategoriasTableTableManager(
      $_db,
      $_db.categorias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoriaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SubcategoriasTable _subcategoriaIdTable(_$AppDatabase db) => db
      .subcategorias
      .createAlias('transacciones__subcategoria_id__subcategorias__id');

  $$SubcategoriasTableProcessedTableManager? get subcategoriaId {
    final $_column = $_itemColumn<int>('subcategoria_id');
    if ($_column == null) return null;
    final manager = $$SubcategoriasTableTableManager(
      $_db,
      $_db.subcategorias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subcategoriaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RecibosTable _reciboIdTable(_$AppDatabase db) =>
      db.recibos.createAlias('transacciones__recibo_id__recibos__id');

  $$RecibosTableProcessedTableManager? get reciboId {
    final $_column = $_itemColumn<int>('recibo_id');
    if ($_column == null) return null;
    final manager = $$RecibosTableTableManager(
      $_db,
      $_db.recibos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reciboIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RecibosTable, List<ReciboRow>> _recibosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.recibos,
    aliasName: 'transacciones__id__recibos__transaccion_id',
  );

  $$RecibosTableProcessedTableManager get recibosRefs {
    final manager = $$RecibosTableTableManager(
      $_db,
      $_db.recibos,
    ).filter((f) => f.transaccionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_recibosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TransaccionEtiquetasTable,
    List<TransaccionEtiquetaRow>
  >
  _transaccionEtiquetasRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transaccionEtiquetas,
        aliasName: 'transacciones__id__transaccion_etiquetas__transaccion_id',
      );

  $$TransaccionEtiquetasTableProcessedTableManager
  get transaccionEtiquetasRefs {
    final manager = $$TransaccionEtiquetasTableTableManager(
      $_db,
      $_db.transaccionEtiquetas,
    ).filter((f) => f.transaccionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transaccionEtiquetasRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CapturaEntranteTable, List<CapturaRow>>
  _capturaEntranteRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.capturaEntrante,
    aliasName: 'transacciones__id__captura_entrante__transaccion_id',
  );

  $$CapturaEntranteTableProcessedTableManager get capturaEntranteRefs {
    final manager = $$CapturaEntranteTableTableManager(
      $_db,
      $_db.capturaEntrante,
    ).filter((f) => f.transaccionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _capturaEntranteRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransaccionesTableFilterComposer
    extends Composer<_$AppDatabase, $TransaccionesTable> {
  $$TransaccionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get montoCentavos => $composableBuilder(
    column: $table.montoCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moneda => $composableBuilder(
    column: $table.moneda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get montoDestinoCentavos => $composableBuilder(
    column: $table.montoDestinoCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monedaDestino => $composableBuilder(
    column: $table.monedaDestino,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaHora => $composableBuilder(
    column: $table.fechaHora,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tasaCambio => $composableBuilder(
    column: $table.tasaCambio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$CuentasTableFilterComposer get cuentaId {
    final $$CuentasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuentaId,
      referencedTable: $db.cuentas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuentasTableFilterComposer(
            $db: $db,
            $table: $db.cuentas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CuentasTableFilterComposer get cuentaDestinoId {
    final $$CuentasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuentaDestinoId,
      referencedTable: $db.cuentas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuentasTableFilterComposer(
            $db: $db,
            $table: $db.cuentas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriasTableFilterComposer get categoriaId {
    final $$CategoriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableFilterComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubcategoriasTableFilterComposer get subcategoriaId {
    final $$SubcategoriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoriaId,
      referencedTable: $db.subcategorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubcategoriasTableFilterComposer(
            $db: $db,
            $table: $db.subcategorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecibosTableFilterComposer get reciboId {
    final $$RecibosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reciboId,
      referencedTable: $db.recibos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecibosTableFilterComposer(
            $db: $db,
            $table: $db.recibos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> recibosRefs(
    Expression<bool> Function($$RecibosTableFilterComposer f) f,
  ) {
    final $$RecibosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recibos,
      getReferencedColumn: (t) => t.transaccionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecibosTableFilterComposer(
            $db: $db,
            $table: $db.recibos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transaccionEtiquetasRefs(
    Expression<bool> Function($$TransaccionEtiquetasTableFilterComposer f) f,
  ) {
    final $$TransaccionEtiquetasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transaccionEtiquetas,
      getReferencedColumn: (t) => t.transaccionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionEtiquetasTableFilterComposer(
            $db: $db,
            $table: $db.transaccionEtiquetas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> capturaEntranteRefs(
    Expression<bool> Function($$CapturaEntranteTableFilterComposer f) f,
  ) {
    final $$CapturaEntranteTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.capturaEntrante,
      getReferencedColumn: (t) => t.transaccionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapturaEntranteTableFilterComposer(
            $db: $db,
            $table: $db.capturaEntrante,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransaccionesTableOrderingComposer
    extends Composer<_$AppDatabase, $TransaccionesTable> {
  $$TransaccionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get montoCentavos => $composableBuilder(
    column: $table.montoCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moneda => $composableBuilder(
    column: $table.moneda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get montoDestinoCentavos => $composableBuilder(
    column: $table.montoDestinoCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monedaDestino => $composableBuilder(
    column: $table.monedaDestino,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaHora => $composableBuilder(
    column: $table.fechaHora,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tasaCambio => $composableBuilder(
    column: $table.tasaCambio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$CuentasTableOrderingComposer get cuentaId {
    final $$CuentasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuentaId,
      referencedTable: $db.cuentas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuentasTableOrderingComposer(
            $db: $db,
            $table: $db.cuentas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CuentasTableOrderingComposer get cuentaDestinoId {
    final $$CuentasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuentaDestinoId,
      referencedTable: $db.cuentas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuentasTableOrderingComposer(
            $db: $db,
            $table: $db.cuentas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriasTableOrderingComposer get categoriaId {
    final $$CategoriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableOrderingComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubcategoriasTableOrderingComposer get subcategoriaId {
    final $$SubcategoriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoriaId,
      referencedTable: $db.subcategorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubcategoriasTableOrderingComposer(
            $db: $db,
            $table: $db.subcategorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecibosTableOrderingComposer get reciboId {
    final $$RecibosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reciboId,
      referencedTable: $db.recibos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecibosTableOrderingComposer(
            $db: $db,
            $table: $db.recibos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransaccionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransaccionesTable> {
  $$TransaccionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get montoCentavos => $composableBuilder(
    column: $table.montoCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get moneda =>
      $composableBuilder(column: $table.moneda, builder: (column) => column);

  GeneratedColumn<int> get montoDestinoCentavos => $composableBuilder(
    column: $table.montoDestinoCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get monedaDestino => $composableBuilder(
    column: $table.monedaDestino,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<int> get fechaHora =>
      $composableBuilder(column: $table.fechaHora, builder: (column) => column);

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);

  GeneratedColumn<double> get tasaCambio => $composableBuilder(
    column: $table.tasaCambio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get origen =>
      $composableBuilder(column: $table.origen, builder: (column) => column);

  GeneratedColumn<int> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => column,
  );

  $$CuentasTableAnnotationComposer get cuentaId {
    final $$CuentasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuentaId,
      referencedTable: $db.cuentas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuentasTableAnnotationComposer(
            $db: $db,
            $table: $db.cuentas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CuentasTableAnnotationComposer get cuentaDestinoId {
    final $$CuentasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cuentaDestinoId,
      referencedTable: $db.cuentas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuentasTableAnnotationComposer(
            $db: $db,
            $table: $db.cuentas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriasTableAnnotationComposer get categoriaId {
    final $$CategoriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableAnnotationComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubcategoriasTableAnnotationComposer get subcategoriaId {
    final $$SubcategoriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoriaId,
      referencedTable: $db.subcategorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubcategoriasTableAnnotationComposer(
            $db: $db,
            $table: $db.subcategorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecibosTableAnnotationComposer get reciboId {
    final $$RecibosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reciboId,
      referencedTable: $db.recibos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecibosTableAnnotationComposer(
            $db: $db,
            $table: $db.recibos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> recibosRefs<T extends Object>(
    Expression<T> Function($$RecibosTableAnnotationComposer a) f,
  ) {
    final $$RecibosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recibos,
      getReferencedColumn: (t) => t.transaccionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecibosTableAnnotationComposer(
            $db: $db,
            $table: $db.recibos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transaccionEtiquetasRefs<T extends Object>(
    Expression<T> Function($$TransaccionEtiquetasTableAnnotationComposer a) f,
  ) {
    final $$TransaccionEtiquetasTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transaccionEtiquetas,
          getReferencedColumn: (t) => t.transaccionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransaccionEtiquetasTableAnnotationComposer(
                $db: $db,
                $table: $db.transaccionEtiquetas,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> capturaEntranteRefs<T extends Object>(
    Expression<T> Function($$CapturaEntranteTableAnnotationComposer a) f,
  ) {
    final $$CapturaEntranteTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.capturaEntrante,
      getReferencedColumn: (t) => t.transaccionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapturaEntranteTableAnnotationComposer(
            $db: $db,
            $table: $db.capturaEntrante,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransaccionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransaccionesTable,
          TransaccionRow,
          $$TransaccionesTableFilterComposer,
          $$TransaccionesTableOrderingComposer,
          $$TransaccionesTableAnnotationComposer,
          $$TransaccionesTableCreateCompanionBuilder,
          $$TransaccionesTableUpdateCompanionBuilder,
          (TransaccionRow, $$TransaccionesTableReferences),
          TransaccionRow,
          PrefetchHooks Function({
            bool cuentaId,
            bool cuentaDestinoId,
            bool categoriaId,
            bool subcategoriaId,
            bool reciboId,
            bool recibosRefs,
            bool transaccionEtiquetasRefs,
            bool capturaEntranteRefs,
          })
        > {
  $$TransaccionesTableTableManager(_$AppDatabase db, $TransaccionesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransaccionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransaccionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransaccionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<int> montoCentavos = const Value.absent(),
                Value<String> moneda = const Value.absent(),
                Value<int> cuentaId = const Value.absent(),
                Value<int?> cuentaDestinoId = const Value.absent(),
                Value<int?> montoDestinoCentavos = const Value.absent(),
                Value<String?> monedaDestino = const Value.absent(),
                Value<int?> categoriaId = const Value.absent(),
                Value<int?> subcategoriaId = const Value.absent(),
                Value<String> fecha = const Value.absent(),
                Value<int> fechaHora = const Value.absent(),
                Value<String?> nota = const Value.absent(),
                Value<int?> reciboId = const Value.absent(),
                Value<double?> tasaCambio = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String> origen = const Value.absent(),
                Value<int> creadoEn = const Value.absent(),
                Value<int> actualizadoEn = const Value.absent(),
                Value<int?> eliminadoEn = const Value.absent(),
              }) => TransaccionesCompanion(
                id: id,
                tipo: tipo,
                montoCentavos: montoCentavos,
                moneda: moneda,
                cuentaId: cuentaId,
                cuentaDestinoId: cuentaDestinoId,
                montoDestinoCentavos: montoDestinoCentavos,
                monedaDestino: monedaDestino,
                categoriaId: categoriaId,
                subcategoriaId: subcategoriaId,
                fecha: fecha,
                fechaHora: fechaHora,
                nota: nota,
                reciboId: reciboId,
                tasaCambio: tasaCambio,
                estado: estado,
                origen: origen,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tipo,
                required int montoCentavos,
                required String moneda,
                required int cuentaId,
                Value<int?> cuentaDestinoId = const Value.absent(),
                Value<int?> montoDestinoCentavos = const Value.absent(),
                Value<String?> monedaDestino = const Value.absent(),
                Value<int?> categoriaId = const Value.absent(),
                Value<int?> subcategoriaId = const Value.absent(),
                required String fecha,
                required int fechaHora,
                Value<String?> nota = const Value.absent(),
                Value<int?> reciboId = const Value.absent(),
                Value<double?> tasaCambio = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String> origen = const Value.absent(),
                required int creadoEn,
                required int actualizadoEn,
                Value<int?> eliminadoEn = const Value.absent(),
              }) => TransaccionesCompanion.insert(
                id: id,
                tipo: tipo,
                montoCentavos: montoCentavos,
                moneda: moneda,
                cuentaId: cuentaId,
                cuentaDestinoId: cuentaDestinoId,
                montoDestinoCentavos: montoDestinoCentavos,
                monedaDestino: monedaDestino,
                categoriaId: categoriaId,
                subcategoriaId: subcategoriaId,
                fecha: fecha,
                fechaHora: fechaHora,
                nota: nota,
                reciboId: reciboId,
                tasaCambio: tasaCambio,
                estado: estado,
                origen: origen,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransaccionesTable, TransaccionRow>(table),
                  $$TransaccionesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                cuentaId = false,
                cuentaDestinoId = false,
                categoriaId = false,
                subcategoriaId = false,
                reciboId = false,
                recibosRefs = false,
                transaccionEtiquetasRefs = false,
                capturaEntranteRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recibosRefs) db.recibos,
                    if (transaccionEtiquetasRefs) db.transaccionEtiquetas,
                    if (capturaEntranteRefs) db.capturaEntrante,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (cuentaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.cuentaId,
                            referencedTable: $$TransaccionesTableReferences
                                ._cuentaIdTable(db),
                            referencedColumn: $$TransaccionesTableReferences
                                ._cuentaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (cuentaDestinoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.cuentaDestinoId,
                            referencedTable: $$TransaccionesTableReferences
                                ._cuentaDestinoIdTable(db),
                            referencedColumn: $$TransaccionesTableReferences
                                ._cuentaDestinoIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (categoriaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoriaId,
                            referencedTable: $$TransaccionesTableReferences
                                ._categoriaIdTable(db),
                            referencedColumn: $$TransaccionesTableReferences
                                ._categoriaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (subcategoriaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.subcategoriaId,
                            referencedTable: $$TransaccionesTableReferences
                                ._subcategoriaIdTable(db),
                            referencedColumn: $$TransaccionesTableReferences
                                ._subcategoriaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (reciboId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.reciboId,
                            referencedTable: $$TransaccionesTableReferences
                                ._reciboIdTable(db),
                            referencedColumn: $$TransaccionesTableReferences
                                ._reciboIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recibosRefs)
                        await $_getPrefetchedDataByColumns<
                          TransaccionRow,
                          $TransaccionesTable,
                          ReciboRow,
                          $RecibosTable
                        >(
                          currentTable: table,
                          referencedTable: $$TransaccionesTableReferences
                              ._recibosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransaccionesTableReferences(
                                db,
                                table,
                                p0,
                              ).recibosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'transaccion_id',
                          typedResults: items,
                        ),
                      if (transaccionEtiquetasRefs)
                        await $_getPrefetchedDataByColumns<
                          TransaccionRow,
                          $TransaccionesTable,
                          TransaccionEtiquetaRow,
                          $TransaccionEtiquetasTable
                        >(
                          currentTable: table,
                          referencedTable: $$TransaccionesTableReferences
                              ._transaccionEtiquetasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransaccionesTableReferences(
                                db,
                                table,
                                p0,
                              ).transaccionEtiquetasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'transaccion_id',
                          typedResults: items,
                        ),
                      if (capturaEntranteRefs)
                        await $_getPrefetchedDataByColumns<
                          TransaccionRow,
                          $TransaccionesTable,
                          CapturaRow,
                          $CapturaEntranteTable
                        >(
                          currentTable: table,
                          referencedTable: $$TransaccionesTableReferences
                              ._capturaEntranteRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransaccionesTableReferences(
                                db,
                                table,
                                p0,
                              ).capturaEntranteRefs,
                          currentColumn: 'id',
                          referencedColumn: 'transaccion_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TransaccionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransaccionesTable,
      TransaccionRow,
      $$TransaccionesTableFilterComposer,
      $$TransaccionesTableOrderingComposer,
      $$TransaccionesTableAnnotationComposer,
      $$TransaccionesTableCreateCompanionBuilder,
      $$TransaccionesTableUpdateCompanionBuilder,
      (TransaccionRow, $$TransaccionesTableReferences),
      TransaccionRow,
      PrefetchHooks Function({
        bool cuentaId,
        bool cuentaDestinoId,
        bool categoriaId,
        bool subcategoriaId,
        bool reciboId,
        bool recibosRefs,
        bool transaccionEtiquetasRefs,
        bool capturaEntranteRefs,
      })
    >;
typedef $$TransaccionEtiquetasTableCreateCompanionBuilder =
    TransaccionEtiquetasCompanion Function({
      required int transaccionId,
      required int etiquetaId,
      Value<int> rowid,
    });
typedef $$TransaccionEtiquetasTableUpdateCompanionBuilder =
    TransaccionEtiquetasCompanion Function({
      Value<int> transaccionId,
      Value<int> etiquetaId,
      Value<int> rowid,
    });

final class $$TransaccionEtiquetasTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransaccionEtiquetasTable,
          TransaccionEtiquetaRow
        > {
  $$TransaccionEtiquetasTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransaccionesTable _transaccionIdTable(_$AppDatabase db) => db
      .transacciones
      .createAlias('transaccion_etiquetas__transaccion_id__transacciones__id');

  $$TransaccionesTableProcessedTableManager get transaccionId {
    final $_column = $_itemColumn<int>('transaccion_id')!;

    final manager = $$TransaccionesTableTableManager(
      $_db,
      $_db.transacciones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transaccionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EtiquetasTable _etiquetaIdTable(_$AppDatabase db) => db.etiquetas
      .createAlias('transaccion_etiquetas__etiqueta_id__etiquetas__id');

  $$EtiquetasTableProcessedTableManager get etiquetaId {
    final $_column = $_itemColumn<int>('etiqueta_id')!;

    final manager = $$EtiquetasTableTableManager(
      $_db,
      $_db.etiquetas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_etiquetaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransaccionEtiquetasTableFilterComposer
    extends Composer<_$AppDatabase, $TransaccionEtiquetasTable> {
  $$TransaccionEtiquetasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TransaccionesTableFilterComposer get transaccionId {
    final $$TransaccionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaccionId,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableFilterComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EtiquetasTableFilterComposer get etiquetaId {
    final $$EtiquetasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.etiquetaId,
      referencedTable: $db.etiquetas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EtiquetasTableFilterComposer(
            $db: $db,
            $table: $db.etiquetas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransaccionEtiquetasTableOrderingComposer
    extends Composer<_$AppDatabase, $TransaccionEtiquetasTable> {
  $$TransaccionEtiquetasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TransaccionesTableOrderingComposer get transaccionId {
    final $$TransaccionesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaccionId,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableOrderingComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EtiquetasTableOrderingComposer get etiquetaId {
    final $$EtiquetasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.etiquetaId,
      referencedTable: $db.etiquetas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EtiquetasTableOrderingComposer(
            $db: $db,
            $table: $db.etiquetas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransaccionEtiquetasTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransaccionEtiquetasTable> {
  $$TransaccionEtiquetasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TransaccionesTableAnnotationComposer get transaccionId {
    final $$TransaccionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaccionId,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableAnnotationComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EtiquetasTableAnnotationComposer get etiquetaId {
    final $$EtiquetasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.etiquetaId,
      referencedTable: $db.etiquetas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EtiquetasTableAnnotationComposer(
            $db: $db,
            $table: $db.etiquetas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransaccionEtiquetasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransaccionEtiquetasTable,
          TransaccionEtiquetaRow,
          $$TransaccionEtiquetasTableFilterComposer,
          $$TransaccionEtiquetasTableOrderingComposer,
          $$TransaccionEtiquetasTableAnnotationComposer,
          $$TransaccionEtiquetasTableCreateCompanionBuilder,
          $$TransaccionEtiquetasTableUpdateCompanionBuilder,
          (TransaccionEtiquetaRow, $$TransaccionEtiquetasTableReferences),
          TransaccionEtiquetaRow,
          PrefetchHooks Function({bool transaccionId, bool etiquetaId})
        > {
  $$TransaccionEtiquetasTableTableManager(
    _$AppDatabase db,
    $TransaccionEtiquetasTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransaccionEtiquetasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransaccionEtiquetasTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TransaccionEtiquetasTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> transaccionId = const Value.absent(),
                Value<int> etiquetaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransaccionEtiquetasCompanion(
                transaccionId: transaccionId,
                etiquetaId: etiquetaId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int transaccionId,
                required int etiquetaId,
                Value<int> rowid = const Value.absent(),
              }) => TransaccionEtiquetasCompanion.insert(
                transaccionId: transaccionId,
                etiquetaId: etiquetaId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $TransaccionEtiquetasTable,
                    TransaccionEtiquetaRow
                  >(table),
                  $$TransaccionEtiquetasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transaccionId = false, etiquetaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (transaccionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.transaccionId,
                        referencedTable: $$TransaccionEtiquetasTableReferences
                            ._transaccionIdTable(db),
                        referencedColumn: $$TransaccionEtiquetasTableReferences
                            ._transaccionIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (etiquetaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.etiquetaId,
                        referencedTable: $$TransaccionEtiquetasTableReferences
                            ._etiquetaIdTable(db),
                        referencedColumn: $$TransaccionEtiquetasTableReferences
                            ._etiquetaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransaccionEtiquetasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransaccionEtiquetasTable,
      TransaccionEtiquetaRow,
      $$TransaccionEtiquetasTableFilterComposer,
      $$TransaccionEtiquetasTableOrderingComposer,
      $$TransaccionEtiquetasTableAnnotationComposer,
      $$TransaccionEtiquetasTableCreateCompanionBuilder,
      $$TransaccionEtiquetasTableUpdateCompanionBuilder,
      (TransaccionEtiquetaRow, $$TransaccionEtiquetasTableReferences),
      TransaccionEtiquetaRow,
      PrefetchHooks Function({bool transaccionId, bool etiquetaId})
    >;
typedef $$TasasCambioTableCreateCompanionBuilder =
    TasasCambioCompanion Function({
      Value<int> id,
      required String monedaOrigen,
      required String monedaDestino,
      required double valor,
      required String fecha,
      required String fuente,
      required int creadoEn,
    });
typedef $$TasasCambioTableUpdateCompanionBuilder =
    TasasCambioCompanion Function({
      Value<int> id,
      Value<String> monedaOrigen,
      Value<String> monedaDestino,
      Value<double> valor,
      Value<String> fecha,
      Value<String> fuente,
      Value<int> creadoEn,
    });

class $$TasasCambioTableFilterComposer
    extends Composer<_$AppDatabase, $TasasCambioTable> {
  $$TasasCambioTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monedaOrigen => $composableBuilder(
    column: $table.monedaOrigen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monedaDestino => $composableBuilder(
    column: $table.monedaDestino,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fuente => $composableBuilder(
    column: $table.fuente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasasCambioTableOrderingComposer
    extends Composer<_$AppDatabase, $TasasCambioTable> {
  $$TasasCambioTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monedaOrigen => $composableBuilder(
    column: $table.monedaOrigen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monedaDestino => $composableBuilder(
    column: $table.monedaDestino,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuente => $composableBuilder(
    column: $table.fuente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasasCambioTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasasCambioTable> {
  $$TasasCambioTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get monedaOrigen => $composableBuilder(
    column: $table.monedaOrigen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get monedaDestino => $composableBuilder(
    column: $table.monedaDestino,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get fuente =>
      $composableBuilder(column: $table.fuente, builder: (column) => column);

  GeneratedColumn<int> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);
}

class $$TasasCambioTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasasCambioTable,
          TasaCambioRow,
          $$TasasCambioTableFilterComposer,
          $$TasasCambioTableOrderingComposer,
          $$TasasCambioTableAnnotationComposer,
          $$TasasCambioTableCreateCompanionBuilder,
          $$TasasCambioTableUpdateCompanionBuilder,
          (
            TasaCambioRow,
            BaseReferences<_$AppDatabase, $TasasCambioTable, TasaCambioRow>,
          ),
          TasaCambioRow,
          PrefetchHooks Function()
        > {
  $$TasasCambioTableTableManager(_$AppDatabase db, $TasasCambioTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasasCambioTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasasCambioTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasasCambioTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> monedaOrigen = const Value.absent(),
                Value<String> monedaDestino = const Value.absent(),
                Value<double> valor = const Value.absent(),
                Value<String> fecha = const Value.absent(),
                Value<String> fuente = const Value.absent(),
                Value<int> creadoEn = const Value.absent(),
              }) => TasasCambioCompanion(
                id: id,
                monedaOrigen: monedaOrigen,
                monedaDestino: monedaDestino,
                valor: valor,
                fecha: fecha,
                fuente: fuente,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String monedaOrigen,
                required String monedaDestino,
                required double valor,
                required String fecha,
                required String fuente,
                required int creadoEn,
              }) => TasasCambioCompanion.insert(
                id: id,
                monedaOrigen: monedaOrigen,
                monedaDestino: monedaDestino,
                valor: valor,
                fecha: fecha,
                fuente: fuente,
                creadoEn: creadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasasCambioTable, TasaCambioRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TasasCambioTable,
                    TasaCambioRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasasCambioTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasasCambioTable,
      TasaCambioRow,
      $$TasasCambioTableFilterComposer,
      $$TasasCambioTableOrderingComposer,
      $$TasasCambioTableAnnotationComposer,
      $$TasasCambioTableCreateCompanionBuilder,
      $$TasasCambioTableUpdateCompanionBuilder,
      (
        TasaCambioRow,
        BaseReferences<_$AppDatabase, $TasasCambioTable, TasaCambioRow>,
      ),
      TasaCambioRow,
      PrefetchHooks Function()
    >;
typedef $$ConfiguracionTableCreateCompanionBuilder =
    ConfiguracionCompanion Function({
      required String clave,
      required String valor,
      required int actualizadoEn,
      Value<int> rowid,
    });
typedef $$ConfiguracionTableUpdateCompanionBuilder =
    ConfiguracionCompanion Function({
      Value<String> clave,
      Value<String> valor,
      Value<int> actualizadoEn,
      Value<int> rowid,
    });

class $$ConfiguracionTableFilterComposer
    extends Composer<_$AppDatabase, $ConfiguracionTable> {
  $$ConfiguracionTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConfiguracionTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfiguracionTable> {
  $$ConfiguracionTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConfiguracionTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfiguracionTable> {
  $$ConfiguracionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clave =>
      $composableBuilder(column: $table.clave, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );
}

class $$ConfiguracionTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfiguracionTable,
          ConfiguracionRow,
          $$ConfiguracionTableFilterComposer,
          $$ConfiguracionTableOrderingComposer,
          $$ConfiguracionTableAnnotationComposer,
          $$ConfiguracionTableCreateCompanionBuilder,
          $$ConfiguracionTableUpdateCompanionBuilder,
          (
            ConfiguracionRow,
            BaseReferences<
              _$AppDatabase,
              $ConfiguracionTable,
              ConfiguracionRow
            >,
          ),
          ConfiguracionRow,
          PrefetchHooks Function()
        > {
  $$ConfiguracionTableTableManager(_$AppDatabase db, $ConfiguracionTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfiguracionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfiguracionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfiguracionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clave = const Value.absent(),
                Value<String> valor = const Value.absent(),
                Value<int> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfiguracionCompanion(
                clave: clave,
                valor: valor,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clave,
                required String valor,
                required int actualizadoEn,
                Value<int> rowid = const Value.absent(),
              }) => ConfiguracionCompanion.insert(
                clave: clave,
                valor: valor,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConfiguracionTable, ConfiguracionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ConfiguracionTable,
                    ConfiguracionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConfiguracionTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfiguracionTable,
      ConfiguracionRow,
      $$ConfiguracionTableFilterComposer,
      $$ConfiguracionTableOrderingComposer,
      $$ConfiguracionTableAnnotationComposer,
      $$ConfiguracionTableCreateCompanionBuilder,
      $$ConfiguracionTableUpdateCompanionBuilder,
      (
        ConfiguracionRow,
        BaseReferences<_$AppDatabase, $ConfiguracionTable, ConfiguracionRow>,
      ),
      ConfiguracionRow,
      PrefetchHooks Function()
    >;
typedef $$CapturaEntranteTableCreateCompanionBuilder =
    CapturaEntranteCompanion Function({
      Value<int> id,
      required String canal,
      required String origen,
      Value<String?> messageIdExterno,
      Value<String?> textoCrudo,
      Value<String?> adjuntoPath,
      Value<String> estado,
      Value<String?> propuestaJson,
      Value<String?> errorDetalle,
      Value<int?> transaccionId,
      required int createdAt,
      Value<int?> procesadaAt,
    });
typedef $$CapturaEntranteTableUpdateCompanionBuilder =
    CapturaEntranteCompanion Function({
      Value<int> id,
      Value<String> canal,
      Value<String> origen,
      Value<String?> messageIdExterno,
      Value<String?> textoCrudo,
      Value<String?> adjuntoPath,
      Value<String> estado,
      Value<String?> propuestaJson,
      Value<String?> errorDetalle,
      Value<int?> transaccionId,
      Value<int> createdAt,
      Value<int?> procesadaAt,
    });

final class $$CapturaEntranteTableReferences
    extends BaseReferences<_$AppDatabase, $CapturaEntranteTable, CapturaRow> {
  $$CapturaEntranteTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransaccionesTable _transaccionIdTable(_$AppDatabase db) => db
      .transacciones
      .createAlias('captura_entrante__transaccion_id__transacciones__id');

  $$TransaccionesTableProcessedTableManager? get transaccionId {
    final $_column = $_itemColumn<int>('transaccion_id');
    if ($_column == null) return null;
    final manager = $$TransaccionesTableTableManager(
      $_db,
      $_db.transacciones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transaccionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CapturaEntranteTableFilterComposer
    extends Composer<_$AppDatabase, $CapturaEntranteTable> {
  $$CapturaEntranteTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canal => $composableBuilder(
    column: $table.canal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageIdExterno => $composableBuilder(
    column: $table.messageIdExterno,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textoCrudo => $composableBuilder(
    column: $table.textoCrudo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adjuntoPath => $composableBuilder(
    column: $table.adjuntoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get propuestaJson => $composableBuilder(
    column: $table.propuestaJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorDetalle => $composableBuilder(
    column: $table.errorDetalle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get procesadaAt => $composableBuilder(
    column: $table.procesadaAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TransaccionesTableFilterComposer get transaccionId {
    final $$TransaccionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaccionId,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableFilterComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CapturaEntranteTableOrderingComposer
    extends Composer<_$AppDatabase, $CapturaEntranteTable> {
  $$CapturaEntranteTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canal => $composableBuilder(
    column: $table.canal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageIdExterno => $composableBuilder(
    column: $table.messageIdExterno,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textoCrudo => $composableBuilder(
    column: $table.textoCrudo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adjuntoPath => $composableBuilder(
    column: $table.adjuntoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get propuestaJson => $composableBuilder(
    column: $table.propuestaJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorDetalle => $composableBuilder(
    column: $table.errorDetalle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get procesadaAt => $composableBuilder(
    column: $table.procesadaAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransaccionesTableOrderingComposer get transaccionId {
    final $$TransaccionesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaccionId,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableOrderingComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CapturaEntranteTableAnnotationComposer
    extends Composer<_$AppDatabase, $CapturaEntranteTable> {
  $$CapturaEntranteTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get canal =>
      $composableBuilder(column: $table.canal, builder: (column) => column);

  GeneratedColumn<String> get origen =>
      $composableBuilder(column: $table.origen, builder: (column) => column);

  GeneratedColumn<String> get messageIdExterno => $composableBuilder(
    column: $table.messageIdExterno,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textoCrudo => $composableBuilder(
    column: $table.textoCrudo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get adjuntoPath => $composableBuilder(
    column: $table.adjuntoPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get propuestaJson => $composableBuilder(
    column: $table.propuestaJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorDetalle => $composableBuilder(
    column: $table.errorDetalle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get procesadaAt => $composableBuilder(
    column: $table.procesadaAt,
    builder: (column) => column,
  );

  $$TransaccionesTableAnnotationComposer get transaccionId {
    final $$TransaccionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaccionId,
      referencedTable: $db.transacciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaccionesTableAnnotationComposer(
            $db: $db,
            $table: $db.transacciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CapturaEntranteTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CapturaEntranteTable,
          CapturaRow,
          $$CapturaEntranteTableFilterComposer,
          $$CapturaEntranteTableOrderingComposer,
          $$CapturaEntranteTableAnnotationComposer,
          $$CapturaEntranteTableCreateCompanionBuilder,
          $$CapturaEntranteTableUpdateCompanionBuilder,
          (CapturaRow, $$CapturaEntranteTableReferences),
          CapturaRow,
          PrefetchHooks Function({bool transaccionId})
        > {
  $$CapturaEntranteTableTableManager(
    _$AppDatabase db,
    $CapturaEntranteTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CapturaEntranteTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CapturaEntranteTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CapturaEntranteTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> canal = const Value.absent(),
                Value<String> origen = const Value.absent(),
                Value<String?> messageIdExterno = const Value.absent(),
                Value<String?> textoCrudo = const Value.absent(),
                Value<String?> adjuntoPath = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String?> propuestaJson = const Value.absent(),
                Value<String?> errorDetalle = const Value.absent(),
                Value<int?> transaccionId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> procesadaAt = const Value.absent(),
              }) => CapturaEntranteCompanion(
                id: id,
                canal: canal,
                origen: origen,
                messageIdExterno: messageIdExterno,
                textoCrudo: textoCrudo,
                adjuntoPath: adjuntoPath,
                estado: estado,
                propuestaJson: propuestaJson,
                errorDetalle: errorDetalle,
                transaccionId: transaccionId,
                createdAt: createdAt,
                procesadaAt: procesadaAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String canal,
                required String origen,
                Value<String?> messageIdExterno = const Value.absent(),
                Value<String?> textoCrudo = const Value.absent(),
                Value<String?> adjuntoPath = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String?> propuestaJson = const Value.absent(),
                Value<String?> errorDetalle = const Value.absent(),
                Value<int?> transaccionId = const Value.absent(),
                required int createdAt,
                Value<int?> procesadaAt = const Value.absent(),
              }) => CapturaEntranteCompanion.insert(
                id: id,
                canal: canal,
                origen: origen,
                messageIdExterno: messageIdExterno,
                textoCrudo: textoCrudo,
                adjuntoPath: adjuntoPath,
                estado: estado,
                propuestaJson: propuestaJson,
                errorDetalle: errorDetalle,
                transaccionId: transaccionId,
                createdAt: createdAt,
                procesadaAt: procesadaAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CapturaEntranteTable, CapturaRow>(table),
                  $$CapturaEntranteTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transaccionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (transaccionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.transaccionId,
                        referencedTable: $$CapturaEntranteTableReferences
                            ._transaccionIdTable(db),
                        referencedColumn: $$CapturaEntranteTableReferences
                            ._transaccionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CapturaEntranteTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CapturaEntranteTable,
      CapturaRow,
      $$CapturaEntranteTableFilterComposer,
      $$CapturaEntranteTableOrderingComposer,
      $$CapturaEntranteTableAnnotationComposer,
      $$CapturaEntranteTableCreateCompanionBuilder,
      $$CapturaEntranteTableUpdateCompanionBuilder,
      (CapturaRow, $$CapturaEntranteTableReferences),
      CapturaRow,
      PrefetchHooks Function({bool transaccionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CuentasTableTableManager get cuentas =>
      $$CuentasTableTableManager(_db, _db.cuentas);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db, _db.categorias);
  $$SubcategoriasTableTableManager get subcategorias =>
      $$SubcategoriasTableTableManager(_db, _db.subcategorias);
  $$EtiquetasTableTableManager get etiquetas =>
      $$EtiquetasTableTableManager(_db, _db.etiquetas);
  $$RecibosTableTableManager get recibos =>
      $$RecibosTableTableManager(_db, _db.recibos);
  $$TransaccionesTableTableManager get transacciones =>
      $$TransaccionesTableTableManager(_db, _db.transacciones);
  $$TransaccionEtiquetasTableTableManager get transaccionEtiquetas =>
      $$TransaccionEtiquetasTableTableManager(_db, _db.transaccionEtiquetas);
  $$TasasCambioTableTableManager get tasasCambio =>
      $$TasasCambioTableTableManager(_db, _db.tasasCambio);
  $$ConfiguracionTableTableManager get configuracion =>
      $$ConfiguracionTableTableManager(_db, _db.configuracion);
  $$CapturaEntranteTableTableManager get capturaEntrante =>
      $$CapturaEntranteTableTableManager(_db, _db.capturaEntrante);
}
