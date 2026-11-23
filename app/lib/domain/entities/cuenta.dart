/// Tipos de cuenta y su agrupación para el dashboard.
library;

/// Grupo con el que se muestra una cuenta en el dashboard.
enum GrupoCuenta {
  efectivo('Efectivo'),
  bancos('Bancos'),
  tarjetas('Tarjetas'),
  ahorro('Ahorro'),
  inversion('Inversión');

  const GrupoCuenta(this.etiqueta);

  final String etiqueta;
}

/// Tipos de cuenta soportados (columna `tipo` de la tabla `cuenta`).
enum TipoCuenta {
  efectivo('efectivo', 'Efectivo', GrupoCuenta.efectivo),
  banco('banco', 'Banco', GrupoCuenta.bancos),
  nequi('nequi', 'Nequi', GrupoCuenta.bancos),
  daviplata('daviplata', 'Daviplata', GrupoCuenta.bancos),
  tarjetaCredito(
    'tarjeta_credito',
    'Tarjeta de crédito',
    GrupoCuenta.tarjetas,
  ),
  ahorro('ahorro', 'Ahorro', GrupoCuenta.ahorro),
  inversion('inversion', 'Inversión', GrupoCuenta.inversion);

  const TipoCuenta(this.valorDb, this.etiqueta, this.grupo);

  /// Valor tal como se guarda en SQLite.
  final String valorDb;

  /// Etiqueta visible en la interfaz.
  final String etiqueta;

  /// Grupo del dashboard.
  final GrupoCuenta grupo;

  static TipoCuenta desdeDb(String valor) => values.firstWhere(
    (TipoCuenta tipo) => tipo.valorDb == valor,
    orElse: () => TipoCuenta.efectivo,
  );
}

/// Cuenta financiera.
class Cuenta {
  const Cuenta({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.saldoInicialCentavos,
    required this.moneda,
    required this.activa,
    this.nota,
  });

  final int id;
  final String nombre;
  final TipoCuenta tipo;

  /// Saldo declarado al crear la cuenta (no es el saldo actual).
  final int saldoInicialCentavos;
  final String moneda;
  final bool activa;
  final String? nota;

  Cuenta copyWith({
    String? nombre,
    TipoCuenta? tipo,
    int? saldoInicialCentavos,
    String? moneda,
    bool? activa,
    String? nota,
  }) {
    return Cuenta(
      id: id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      saldoInicialCentavos:
          saldoInicialCentavos ?? this.saldoInicialCentavos,
      moneda: moneda ?? this.moneda,
      activa: activa ?? this.activa,
      nota: nota ?? this.nota,
    );
  }
}
