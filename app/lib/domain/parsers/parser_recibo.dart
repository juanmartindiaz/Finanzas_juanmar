import '../../domain/entities/categoria.dart';
import '../../domain/entities/captura.dart';
import '../../domain/entities/transaccion.dart';

/// Resultado de interpretar el texto de un recibo.
class PropuestaRecibo {
  const PropuestaRecibo({
    this.montoCentavos,
    this.comercio,
    required this.fecha,
    this.categoriaId,
    this.categoriaNombre,
    required this.confianza,
    required this.faltantes,
    required this.textoReconocido,
  });

  final int? montoCentavos;
  final String? comercio;
  final String fecha;
  final int? categoriaId;
  final String? categoriaNombre;
  final ConfianzaPropuesta confianza;
  final List<String> faltantes;
  final String textoReconocido;

  String get resumen {
    final String monto = montoCentavos == null
        ? 'Recibo'
        : '\$ ${_formatear(montoCentavos!)}';
    return comercio == null ? monto : '$comercio · $monto';
  }
}

/// Interpreta el texto plano de un recibo. No depende de Android ni de ML Kit.
PropuestaRecibo parsearRecibo(
  String texto, {
  required DateTime fechaRecepcion,
  required List<Categoria> categorias,
}) {
  final List<String> lineas = texto
      .split('\n')
      .map((String linea) => linea.trim())
      .where((String linea) => linea.isNotEmpty)
      .toList();
  final List<String> faltantes = <String>[];

  final String? comercio = _detectarComercio(lineas);
  if (comercio == null) {
    faltantes.add('comercio');
  }

  final _MontoDetectado? monto = _detectarMonto(lineas);
  if (monto == null) {
    faltantes.add('monto');
  }

  final String fecha = _detectarFecha(lineas) ?? _fechaIso(fechaRecepcion);

  _CategoriaDetectada? categoria = _detectarCategoria(
    texto: texto,
    comercio: comercio,
    categorias: categorias,
  );
  if (categoria == null) {
    faltantes.add('categoría');
    categoria = _buscarOtros(categorias);
  }

  final ConfianzaPropuesta confianza;
  if (monto != null && monto.deLineaTotal) {
    confianza = ConfianzaPropuesta.alta;
  } else if (monto != null) {
    confianza = ConfianzaPropuesta.media;
  } else {
    confianza = ConfianzaPropuesta.baja;
  }

  return PropuestaRecibo(
    montoCentavos: monto?.centavos,
    comercio: comercio,
    fecha: fecha,
    categoriaId: categoria?.id,
    categoriaNombre: categoria?.nombre,
    confianza: confianza,
    faltantes: faltantes,
    textoReconocido: texto,
  );
}

class _MontoDetectado {
  const _MontoDetectado({required this.centavos, required this.deLineaTotal});
  final int centavos;
  final bool deLineaTotal;
}

class _CategoriaDetectada {
  const _CategoriaDetectada({required this.id, required this.nombre});
  final int id;
  final String nombre;
}

_MontoDetectado? _detectarMonto(List<String> lineas) {
  int? mejorCentavos;
  int mejorPuntaje = -1;
  bool deTotal = false;

  for (int i = 0; i < lineas.length; i++) {
    final String linea = lineas[i];
    final String normal = _normalizar(linea);
    if (_pareceFechaOTelefono(normal)) {
      continue;
    }
    final bool esTotal = normal.contains('total');
    final bool esValor = normal.contains('valor') || normal.contains('importe');
    if (!esTotal && !esValor && normal.contains('propina')) {
      continue;
    }
    for (final int centavos in _numerosDeLinea(linea)) {
      if (_esAnio(centavos)) {
        continue;
      }
      final int puntaje = (esTotal ? 200 : esValor ? 100 : 10) + i;
      if (puntaje > mejorPuntaje) {
        mejorPuntaje = puntaje;
        mejorCentavos = centavos;
        deTotal = esTotal;
      }
    }
  }

  // Si no hubo línea con "total"/"valor", se toma el número más grande
  // (excluyendo fechas y teléfonos).
  if (mejorCentavos == null) {
    for (final String linea in lineas) {
      final String normal = _normalizar(linea);
      if (_pareceFechaOTelefono(normal)) continue;
      for (final int centavos in _numerosDeLinea(linea)) {
        if (_esAnio(centavos)) continue;
        if (mejorCentavos == null || centavos > mejorCentavos) {
          mejorCentavos = centavos;
        }
      }
    }
  }

  if (mejorCentavos == null || mejorCentavos <= 0) {
    return null;
  }
  return _MontoDetectado(centavos: mejorCentavos, deLineaTotal: deTotal);
}

List<int> _numerosDeLinea(String linea) {
  final List<int> resultado = <int>[];
  final Iterable<RegExpMatch> coincidencias =
      RegExp(r'\d[\d.,]*').allMatches(linea);
  for (final RegExpMatch coincidencia in coincidencias) {
    final String crudo = coincidencia.group(0)!.replaceAll(RegExp(r'[.,]$'), '');
    final int? centavos = _aCentavos(crudo);
    if (centavos != null) {
      resultado.add(centavos);
    }
  }
  return resultado;
}

int? _aCentavos(String crudo) {
  if (crudo.isEmpty) return null;
  final int ultimoPunto = crudo.lastIndexOf('.');
  final int ultimaComa = crudo.lastIndexOf(',');
  final int ultimo = ultimoPunto > ultimaComa ? ultimoPunto : ultimaComa;
  double numero;
  if (ultimo >= 0) {
    final int decimales = crudo.length - ultimo - 1;
    if (decimales == 2) {
      final String entero = crudo.substring(0, ultimo).replaceAll(RegExp(r'[.,]'), '');
      final String frac = crudo.substring(ultimo + 1);
      numero = double.tryParse('$entero.$frac') ?? 0;
    } else {
      numero = double.tryParse(crudo.replaceAll(RegExp(r'[.,]'), '')) ?? 0;
    }
  } else {
    numero = double.tryParse(crudo) ?? 0;
  }
  if (numero <= 0) return null;
  return (numero * 100).round();
}

bool _esAnio(int centavos) {
  final double valor = centavos / 100;
  return valor >= 1900 && valor <= 2100 && valor == valor.roundToDouble();
}

bool _pareceFechaOTelefono(String linea) {
  if (RegExp(r'\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b').hasMatch(linea)) {
    return true;
  }
  if (RegExp(r'\b(fecha|hora|tel|telefono|nit|cc|cajero|recibo)\b').hasMatch(linea)) {
    return true;
  }
  final List<int> numeros = _numerosDeLinea(linea);
  if (numeros.length == 1) {
    final double valor = numeros.first / 100;
    if (valor >= 10000000) {
      return true; // número tipo teléfono (10+ dígitos)
    }
  }
  return false;
}

String? _detectarComercio(List<String> lineas) {
  for (final String linea in lineas.take(4)) {
    final String normal = _normalizar(linea);
    if (normal.contains('nit') ||
        normal.contains('factura') ||
        normal.contains('recibo') ||
        normal.contains('fecha') ||
        normal.contains('cajero') ||
        normal.contains('telefono') ||
        normal.contains('cliente')) {
      continue;
    }
    final int letras =
        linea.replaceAll(RegExp(r'[^A-Za-zÁÉÍÓÚáéíóúÑñ]'), '').length;
    if (letras >= 3) {
      return linea
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll(RegExp(r'^[^A-Za-zÁÉÍÓÚáéíóúÑñ]+'), '')
          .trim();
    }
  }
  return null;
}

String? _detectarFecha(List<String> lineas) {
  for (final String linea in lineas) {
    final RegExpMatch? ymd =
        RegExp(r'\b(\d{4})-(\d{2})-(\d{2})\b').firstMatch(linea);
    if (ymd != null) {
      return '${ymd.group(1)}-${ymd.group(2)}-${ymd.group(3)}';
    }
    final RegExpMatch? dmy =
        RegExp(r'\b(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})\b').firstMatch(linea);
    if (dmy != null) {
      final int dia = int.parse(dmy.group(1)!);
      final int mes = int.parse(dmy.group(2)!);
      int anio = int.parse(dmy.group(3)!);
      if (anio < 100) anio += 2000;
      if (mes >= 1 && mes <= 12 && dia >= 1 && dia <= 31) {
        return '${anio.toString().padLeft(4, '0')}-'
            '${mes.toString().padLeft(2, '0')}-'
            '${dia.toString().padLeft(2, '0')}';
      }
    }
  }
  return null;
}

_CategoriaDetectada? _detectarCategoria({
  required String texto,
  required String? comercio,
  required List<Categoria> categorias,
}) {
  final String normal = _normalizar('$texto ${comercio ?? ''}');
  const Map<String, List<String>> palabras = <String, List<String>>{
    'alimentacion': <String>[
      'supermercado',
      'exito',
      'carulla',
      'd1',
      'ara',
      'jumbo',
      'olimpica',
      'mercado',
      'panaderia',
      'restaurante',
      'cafe',
    ],
    'transporte': <String>['uber', 'taxi', 'didi', 'gasolina', 'estacion', 'peaje', 'parqueadero'],
    'salud': <String>['farmacia', 'drogueria', 'clinica', 'hospital', 'medico'],
    'hogar': <String>['ferreteria', 'homecenter', 'muebles', 'aseo'],
    'entretenimiento': <String>['cine', 'teatro', 'concierto', 'juego'],
  };
  for (final Categoria categoria in categorias) {
    if (categoria.archivada) continue;
    final String nombre = _normalizar(categoria.nombre);
    final List<String>? claves = palabras[nombre];
    if (claves != null && claves.any(normal.contains)) {
      return _CategoriaDetectada(id: categoria.id, nombre: categoria.nombre);
    }
    if (nombre.length >= 4 && normal.contains(nombre)) {
      return _CategoriaDetectada(id: categoria.id, nombre: categoria.nombre);
    }
  }
  return null;
}

_CategoriaDetectada? _buscarOtros(List<Categoria> categorias) {
  for (final Categoria categoria in categorias) {
    if (!categoria.archivada &&
        categoria.naturaleza == NaturalezaCategoria.gasto &&
        _normalizar(categoria.nombre) == 'otros') {
      return _CategoriaDetectada(id: categoria.id, nombre: categoria.nombre);
    }
  }
  return null;
}

String _fechaIso(DateTime fecha) =>
    '${fecha.year.toString().padLeft(4, '0')}-'
    '${fecha.month.toString().padLeft(2, '0')}-'
    '${fecha.day.toString().padLeft(2, '0')}';

String _normalizar(String texto) => texto
    .toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll('ñ', 'n');

String _formatear(int centavos) {
  final String entero = (centavos ~/ 100).toString();
  final String conPuntos = entero.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (Match m) => '${m.group(1)}.',
  );
  final int resto = centavos % 100;
  return resto == 0 ? conPuntos : '$conPuntos,${resto.toString().padLeft(2, '0')}';
}

/// Lo usa el servidor para mapear a `PropuestaCaptura`.
extension PropuestaReciboCaptura on PropuestaRecibo {
  PropuestaCaptura aPropuestaCaptura({required String moneda}) {
    return PropuestaCaptura(
      tipo: TipoTransaccion.gasto,
      montoCentavos: montoCentavos,
      moneda: moneda,
      categoriaId: categoriaId,
      categoriaNombre: categoriaNombre,
      confianza: confianza,
      faltantes: faltantes,
      resumen: resumen,
    );
  }
}
