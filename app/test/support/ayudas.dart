import 'package:gestor_finanzas/domain/entities/categoria.dart';
import 'package:gestor_finanzas/domain/entities/cuenta.dart';
import 'package:gestor_finanzas/domain/entities/subcategoria.dart';
import 'package:gestor_finanzas/domain/entities/tasa_cambio.dart';
import 'package:gestor_finanzas/domain/entities/transaccion.dart';

/// Constructores de datos para las pruebas.

Cuenta crearCuenta({
  int id = 1,
  String nombre = 'Efectivo',
  TipoCuenta tipo = TipoCuenta.efectivo,
  int saldoInicialCentavos = 0,
  String moneda = 'COP',
  bool activa = true,
}) {
  return Cuenta(
    id: id,
    nombre: nombre,
    tipo: tipo,
    saldoInicialCentavos: saldoInicialCentavos,
    moneda: moneda,
    activa: activa,
  );
}

Transaccion crearTransaccion({
  int id = 1,
  TipoTransaccion tipo = TipoTransaccion.gasto,
  int montoCentavos = 100000,
  String moneda = 'COP',
  int cuentaId = 1,
  int? cuentaDestinoId,
  int? montoDestinoCentavos,
  String? monedaDestino,
  int? categoriaId = 1,
  int? subcategoriaId,
  String fecha = '2026-11-23',
  int fechaHora = 1795451760000,
  String? nota,
  double? tasaCambio,
}) {
  return Transaccion(
    id: id,
    tipo: tipo,
    montoCentavos: montoCentavos,
    moneda: moneda,
    cuentaId: cuentaId,
    cuentaDestinoId: cuentaDestinoId,
    montoDestinoCentavos: montoDestinoCentavos,
    monedaDestino: monedaDestino,
    categoriaId: tipo == TipoTransaccion.transferencia ? null : categoriaId,
    subcategoriaId: subcategoriaId,
    fecha: fecha,
    fechaHora: fechaHora,
    nota: nota,
    tasaCambio: tasaCambio,
    estado: EstadoTransaccion.confirmada,
    origen: OrigenTransaccion.manual,
  );
}

Categoria crearCategoria({
  int id = 1,
  String nombre = 'Alimentación',
  NaturalezaCategoria naturaleza = NaturalezaCategoria.gasto,
  bool archivada = false,
}) {
  return Categoria(
    id: id,
    nombre: nombre,
    naturaleza: naturaleza,
    predefinida: false,
    orden: 0,
    archivada: archivada,
  );
}

Subcategoria crearSubcategoria({
  int id = 1,
  int categoriaId = 1,
  String nombre = 'Supermercado',
}) {
  return Subcategoria(
    id: id,
    categoriaId: categoriaId,
    nombre: nombre,
    predefinida: false,
    archivada: false,
  );
}

TasaCambio crearTasa({
  int id = 1,
  String origen = 'USD',
  String destino = 'COP',
  double valor = 4000,
  String fecha = '2026-11-23',
}) {
  return TasaCambio(
    id: id,
    monedaOrigen: origen,
    monedaDestino: destino,
    valor: valor,
    fecha: fecha,
    fuente: FuenteTasa.manual,
  );
}
