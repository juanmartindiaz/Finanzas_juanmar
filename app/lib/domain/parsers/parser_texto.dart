/// Parser de texto en español para capturas.
///
/// Dart puro: no usa Flutter ni la base de datos. Recibe el catálogo actual
/// (categorías, subcategorías, etiquetas, cuentas) y devuelve una propuesta con
/// confianza y campos faltantes (ADR-034). Nunca guarda nada.
library;

import '../../core/utils/dinero.dart';
import '../entities/captura.dart';
import '../entities/categoria.dart';
import '../entities/cuenta.dart';
import '../entities/etiqueta.dart';
import '../entities/subcategoria.dart';
import '../entities/transaccion.dart';

/// Datos del usuario que el parser necesita para proponer.
class ContextoParser {
  const ContextoParser({
    required this.categorias,
    required this.subcategorias,
    required this.etiquetas,
    required this.cuentas,
    required this.monedaBase,
    this.cuentaPorDefectoId,
  });

  final List<Categoria> categorias;
  final List<Subcategoria> subcategorias;
  final List<Etiqueta> etiquetas;
  final List<Cuenta> cuentas;
  final String monedaBase;
  final int? cuentaPorDefectoId;
}

/// Convierte el texto en una propuesta. Nunca lanza: si no entiende algo, lo
/// deja en `faltantes` y baja la confianza.
PropuestaCaptura parsearTexto(String texto, ContextoParser contexto) {
  final String normalizado = normalizarTexto(texto);
  final List<String> faltantes = <String>[];

  final TipoTransaccion? tipo = _detectarTipo(normalizado);
  if (tipo == null) {
    faltantes.add('tipo');
  }

  final int? monto = _detectarMonto(normalizado);
  if (monto == null) {
    faltantes.add('monto');
  }

  final List<int> etiquetaIds = <int>[];
  final List<String> etiquetaNombres = <String>[];
  for (final String etiqueta in _detectarEtiquetas(normalizado)) {
    final Etiqueta? encontrada = _buscarEtiqueta(etiqueta, contexto.etiquetas);
    if (encontrada == null) {
      faltantes.add('etiqueta #$etiqueta');
    } else {
      etiquetaIds.add(encontrada.id);
      etiquetaNombres.add(encontrada.nombre);
    }
  }

  final _CoincidenciaCategoria? coincidencia =
      _detectarCategoria(normalizado, tipo, contexto);
  int? categoriaId = coincidencia?.categoriaId;
  String? categoriaNombre = coincidencia?.categoriaNombre;
  int? subcategoriaId = coincidencia?.subcategoriaId;
  String? subcategoriaNombre = coincidencia?.subcategoriaNombre;
  bool categoriaExplicita = coincidencia != null;

  if (categoriaId == null) {
    faltantes.add('categoría');
    final Categoria? otros = _buscarOtros(tipo, contexto.categorias);
    if (otros != null) {
      categoriaId = otros.id;
      categoriaNombre = otros.nombre;
      categoriaExplicita = false;
    }
  }

  final Cuenta? cuenta = _buscarCuenta(contexto);
  if (cuenta == null) {
    faltantes.add('cuenta');
  }

  final int explicitos = <bool>[
    tipo != null,
    monto != null,
    categoriaExplicita,
    cuenta != null,
  ].where((bool valor) => valor).length;

  final ConfianzaPropuesta confianza;
  if (explicitos >= 4 && faltantes.isEmpty) {
    confianza = ConfianzaPropuesta.alta;
  } else if (monto != null && tipo != null) {
    confianza = ConfianzaPropuesta.media;
  } else {
    confianza = ConfianzaPropuesta.baja;
  }

  final String moneda = cuenta?.moneda ?? contexto.monedaBase;
  return PropuestaCaptura(
    tipo: tipo,
    montoCentavos: monto,
    moneda: moneda,
    cuentaId: cuenta?.id,
    cuentaNombre: cuenta?.nombre,
    categoriaId: categoriaId,
    categoriaNombre: categoriaNombre,
    subcategoriaId: subcategoriaId,
    subcategoriaNombre: subcategoriaNombre,
    etiquetaIds: etiquetaIds,
    etiquetaNombres: etiquetaNombres,
    confianza: confianza,
    faltantes: faltantes,
    resumen: _resumen(
      tipo: tipo,
      monto: monto,
      moneda: moneda,
      categoriaNombre: categoriaNombre,
      textoOriginal: texto,
    ),
  );
}

/// Minúsculas, sin tildes, espacios simples.
String normalizarTexto(String texto) {
  final String minusculas = texto.toLowerCase();
  const String conTilde = 'áéíóúüñàèìòùâêîôûäëïöç';
  const String sinTilde = 'aeiouunaeiouaeiouaeioc';
  final StringBuffer buffer = StringBuffer();
  for (final int rune in minusculas.runes) {
    final String caracter = String.fromCharCode(rune);
    final int indice = conTilde.indexOf(caracter);
    buffer.write(indice >= 0 ? sinTilde[indice] : caracter);
  }
  return buffer
      .toString()
      .replaceAll(RegExp(r'[^a-z0-9$#.,\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

TipoTransaccion? _detectarTipo(String normalizado) {
  final bool gasto = _contienePalabra(normalizado, <String>[
    'gaste',
    'pague',
    'compre',
    'compra',
  ]);
  final bool ingreso = _contienePalabra(normalizado, <String>[
    'recibi',
    'cobre',
    'ingreso',
    'me pagaron',
  ]);
  if (gasto && !ingreso) {
    return TipoTransaccion.gasto;
  }
  if (ingreso && !gasto) {
    return TipoTransaccion.ingreso;
  }
  return null;
}

bool _contienePalabra(String texto, List<String> palabras) {
  for (final String palabra in palabras) {
    if (RegExp('(^|\\s)${RegExp.escape(palabra)}(\\s|\$)').hasMatch(texto)) {
      return true;
    }
  }
  return false;
}

int? _detectarMonto(String normalizado) {
  // 1) Símbolo de pesos: "$ 18.500"
  final Match? conSimbolo =
      RegExp(r'\$\s*([0-9][0-9.,]*)').firstMatch(normalizado);
  if (conSimbolo != null) {
    final int? centavos = parsearMonto(conSimbolo.group(1)!);
    if (centavos != null && centavos > 0) {
      return centavos;
    }
  }

  // 2) Sufijos: "20 mil", "20k", "1.5 millones"
  final Match? conSufijo = RegExp(
    r'([0-9][0-9.,]*)\s*(millones|millon|mil|k)\b',
  ).firstMatch(normalizado);
  if (conSufijo != null) {
    final double? numero = _aDouble(conSufijo.group(1)!);
    final String sufijo = conSufijo.group(2)!;
    final int multiplicador = switch (sufijo) {
      'millones' || 'millon' => 1000000,
      'mil' => 1000,
      _ => 1000,
    };
    if (numero != null && numero > 0) {
      return (numero * multiplicador * 100).round();
    }
  }

  // 3) Número suelto con al menos 3 caracteres: "18.500", "18500"
  final Match? suelto = RegExp(
    r'(^|\s)([0-9][0-9.,]{2,})(\s|$)',
  ).firstMatch(normalizado);
  if (suelto != null) {
    final int? centavos = parsearMonto(suelto.group(2)!);
    if (centavos != null && centavos > 0) {
      return centavos;
    }
  }
  return null;
}

double? _aDouble(String numero) {
  String limpio = numero.trim();
  final int ultimaComa = limpio.lastIndexOf(',');
  final int ultimoPunto = limpio.lastIndexOf('.');
  int? posicionDecimal;
  if (ultimaComa >= 0 && ultimoPunto >= 0) {
    posicionDecimal = ultimaComa > ultimoPunto ? ultimaComa : ultimoPunto;
  } else if (ultimaComa >= 0) {
    posicionDecimal = ultimaComa;
  } else if (ultimoPunto >= 0 &&
      limpio.length - ultimoPunto - 1 <= 2) {
    posicionDecimal = ultimoPunto;
  }
  if (posicionDecimal != null) {
    final String enteros = limpio
        .substring(0, posicionDecimal)
        .replaceAll(RegExp(r'[.,]'), '');
    final String decimales = limpio
        .substring(posicionDecimal + 1)
        .replaceAll(RegExp(r'[.,]'), '');
    limpio = '$enteros.$decimales';
  } else {
    limpio = limpio.replaceAll(RegExp(r'[.,]'), '');
  }
  return double.tryParse(limpio);
}

List<String> _detectarEtiquetas(String normalizado) {
  return RegExp(r'#([a-z0-9_]+)')
      .allMatches(normalizado)
      .map((Match match) => match.group(1)!)
      .toList();
}

Etiqueta? _buscarEtiqueta(String nombre, List<Etiqueta> etiquetas) {
  final String buscado = normalizarTexto(nombre);
  for (final Etiqueta etiqueta in etiquetas) {
    if (normalizarTexto(etiqueta.nombre) == buscado) {
      return etiqueta;
    }
  }
  return null;
}

_CoincidenciaCategoria? _detectarCategoria(
  String normalizado,
  TipoTransaccion? tipo,
  ContextoParser contexto,
) {
  _CoincidenciaCategoria? mejor;
  int mejorPuntaje = 0;

  for (final Subcategoria subcategoria in contexto.subcategorias) {
    if (subcategoria.archivada) {
      continue;
    }
    Categoria? padre;
    for (final Categoria categoria in contexto.categorias) {
      if (categoria.id == subcategoria.categoriaId) {
        padre = categoria;
        break;
      }
    }
    if (padre == null || padre.archivada || !_naturalezaCompatible(padre, tipo)) {
      continue;
    }
    final int puntaje = _puntajeCoincidencia(normalizado, subcategoria.nombre);
    if (puntaje > mejorPuntaje) {
      mejorPuntaje = puntaje;
      mejor = _CoincidenciaCategoria(
        categoriaId: padre.id,
        categoriaNombre: padre.nombre,
        subcategoriaId: subcategoria.id,
        subcategoriaNombre: subcategoria.nombre,
      );
    }
  }

  for (final Categoria categoria in contexto.categorias) {
    if (categoria.archivada || !_naturalezaCompatible(categoria, tipo)) {
      continue;
    }
    final int puntaje = _puntajeCoincidencia(normalizado, categoria.nombre);
    if (puntaje > mejorPuntaje) {
      mejorPuntaje = puntaje;
      mejor = _CoincidenciaCategoria(
        categoriaId: categoria.id,
        categoriaNombre: categoria.nombre,
      );
    }
  }

  return mejor;
}

bool _naturalezaCompatible(Categoria categoria, TipoTransaccion? tipo) {
  if (tipo == null) {
    return true;
  }
  if (tipo == TipoTransaccion.gasto) {
    return categoria.naturaleza == NaturalezaCategoria.gasto ||
        categoria.naturaleza == NaturalezaCategoria.ambos;
  }
  return categoria.naturaleza == NaturalezaCategoria.ingreso ||
      categoria.naturaleza == NaturalezaCategoria.ambos;
}

/// Puntaje 0 = no aparece; mayor = coincidencia más específica.
int _puntajeCoincidencia(String texto, String nombre) {
  final String buscado = normalizarTexto(nombre);
  if (buscado.length < 4) {
    return 0;
  }
  if (texto.contains(buscado)) {
    return buscado.length + 10;
  }
  // Coincidencia parcial: alguna palabra del texto (>= 4 letras) está dentro
  // del nombre ("mercado" dentro de "supermercado").
  for (final String palabra in texto.split(' ')) {
    if (palabra.length >= 4 && buscado.contains(palabra)) {
      return palabra.length;
    }
  }
  return 0;
}

Categoria? _buscarOtros(TipoTransaccion? tipo, List<Categoria> categorias) {
  if (tipo == null) {
    return null;
  }
  final NaturalezaCategoria buscada = tipo == TipoTransaccion.gasto
      ? NaturalezaCategoria.gasto
      : NaturalezaCategoria.ingreso;
  for (final Categoria categoria in categorias) {
    if (!categoria.archivada &&
        normalizarTexto(categoria.nombre) == 'otros' &&
        (categoria.naturaleza == buscada ||
            categoria.naturaleza == NaturalezaCategoria.ambos)) {
      return categoria;
    }
  }
  return null;
}

Cuenta? _buscarCuenta(ContextoParser contexto) {
  if (contexto.cuentaPorDefectoId == null) {
    return null;
  }
  for (final Cuenta cuenta in contexto.cuentas) {
    if (cuenta.id == contexto.cuentaPorDefectoId && cuenta.activa) {
      return cuenta;
    }
  }
  return null;
}

String _resumen({
  required TipoTransaccion? tipo,
  required int? monto,
  required String moneda,
  required String? categoriaNombre,
  required String textoOriginal,
}) {
  if (tipo == null && monto == null && categoriaNombre == null) {
    return textoOriginal.trim();
  }
  final List<String> partes = <String>[];
  if (tipo != null) {
    partes.add(tipo.etiqueta);
  }
  if (monto != null) {
    partes.add(formatearMonto(monto, moneda));
  }
  if (categoriaNombre != null) {
    partes.add(categoriaNombre);
  }
  return partes.join(' · ');
}

class _CoincidenciaCategoria {
  const _CoincidenciaCategoria({
    required this.categoriaId,
    required this.categoriaNombre,
    this.subcategoriaId,
    this.subcategoriaNombre,
  });

  final int categoriaId;
  final String categoriaNombre;
  final int? subcategoriaId;
  final String? subcategoriaNombre;
}
