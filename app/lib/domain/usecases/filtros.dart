/// Filtros del listado de transacciones (lógica pura y testeable).
library;

import '../../core/utils/fechas.dart';
import '../entities/transaccion.dart';

/// Criterios de búsqueda del listado.
class FiltroTransacciones {
  const FiltroTransacciones({
    this.texto,
    this.tipo,
    this.cuentaId,
    this.categoriaId,
    this.etiquetaId,
    this.desde,
    this.hasta,
  });

  final String? texto;
  final TipoTransaccion? tipo;
  final int? cuentaId;
  final int? categoriaId;
  final int? etiquetaId;
  final DateTime? desde;
  final DateTime? hasta;

  bool get vacio =>
      (texto == null || texto!.trim().isEmpty) &&
      tipo == null &&
      cuentaId == null &&
      categoriaId == null &&
      etiquetaId == null &&
      desde == null &&
      hasta == null;

  FiltroTransacciones copyWith({
    String? texto,
    TipoTransaccion? tipo,
    int? cuentaId,
    int? categoriaId,
    int? etiquetaId,
    DateTime? desde,
    DateTime? hasta,
    bool limpiarTipo = false,
    bool limpiarCuenta = false,
    bool limpiarCategoria = false,
    bool limpiarEtiqueta = false,
    bool limpiarDesde = false,
    bool limpiarHasta = false,
  }) {
    return FiltroTransacciones(
      texto: texto ?? this.texto,
      tipo: limpiarTipo ? null : (tipo ?? this.tipo),
      cuentaId: limpiarCuenta ? null : (cuentaId ?? this.cuentaId),
      categoriaId:
          limpiarCategoria ? null : (categoriaId ?? this.categoriaId),
      etiquetaId: limpiarEtiqueta ? null : (etiquetaId ?? this.etiquetaId),
      desde: limpiarDesde ? null : (desde ?? this.desde),
      hasta: limpiarHasta ? null : (hasta ?? this.hasta),
    );
  }
}

/// Aplica los filtros a una lista de transacciones.
List<Transaccion> aplicarFiltroTransacciones(
  List<Transaccion> transacciones,
  FiltroTransacciones filtro,
) {
  final String? texto = filtro.texto?.trim().toLowerCase();
  final String? desdeIso = filtro.desde == null ? null : fechaIso(filtro.desde!);
  final String? hastaIso = filtro.hasta == null ? null : fechaIso(filtro.hasta!);

  return transacciones.where((Transaccion transaccion) {
    if (filtro.tipo != null && transaccion.tipo != filtro.tipo) {
      return false;
    }
    if (filtro.cuentaId != null &&
        transaccion.cuentaId != filtro.cuentaId &&
        transaccion.cuentaDestinoId != filtro.cuentaId) {
      return false;
    }
    if (filtro.categoriaId != null &&
        transaccion.categoriaId != filtro.categoriaId) {
      return false;
    }
    if (filtro.etiquetaId != null &&
        !transaccion.etiquetas.any(
          (elemento) => elemento.id == filtro.etiquetaId,
        )) {
      return false;
    }
    if (desdeIso != null && transaccion.fecha.compareTo(desdeIso) < 0) {
      return false;
    }
    if (hastaIso != null && transaccion.fecha.compareTo(hastaIso) > 0) {
      return false;
    }
    if (texto != null && texto.isNotEmpty) {
      final String nota = (transaccion.nota ?? '').toLowerCase();
      if (!nota.contains(texto)) {
        return false;
      }
    }
    return true;
  }).toList();
}
