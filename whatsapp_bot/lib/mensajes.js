/** Respuestas automáticas al usuario y heurísticas de clasificación. */

export const RESPUESTAS = {
  noEsTransaccion:
    "No identifiqué un monto ni categoría. Escribe por ejemplo: 'gasté 20.000 en mercado'.",
  formatoNoSoportado:
    '⚠️ Formato no soportado. Envía texto, audio o foto.',
  tokenInvalido:
    '⚠️ Error de autenticación. Revisa el token en Ajustes → Canal bot de la app.',
  duplicado: 'Ya había procesado este mensaje.',
  archivoGrande: 'Archivo demasiado grande (máx 8 MB).',
  esperandoApp: '⏳ Guardado, esperando app',
  errorDescarga:
    '⚠️ No pude descargar el archivo. Intenta enviarlo de nuevo.',
};

/** Solo dígitos, para comparar números de WhatsApp. */
export function normalizarNumero(jid) {
  return String(jid ?? '').split('@')[0].replace(/\D/g, '');
}

/**
 * WhatsApp puede entregar el mensaje con un LID (identidad interna) en
 * `remoteJid` y el número real en `remoteJidAlt`. Para autorizar y responder
 * siempre preferimos el JID con número (`@s.whatsapp.net`).
 */
export function elegirJidRemitente(key = {}) {
  const candidatos = [key.remoteJid, key.remoteJidAlt];
  for (const jid of candidatos) {
    if (typeof jid === 'string' && jid.endsWith('@s.whatsapp.net')) {
      return jid;
    }
  }
  return key.remoteJid ?? key.remoteJidAlt ?? null;
}

export function idCorto(capturaId) {
  const texto = String(capturaId ?? '');
  return texto.length <= 4 ? texto : texto.slice(-4);
}

export function respuestaExito(tipo, capturaId) {
  const id = idCorto(capturaId);
  if (tipo === 'foto') {
    return `📷 Foto guardada (#${id}). Revísala en la app.`;
  }
  if (tipo === 'audio') {
    return `🎤 Audio guardado (#${id}). La transcripción llegará en una próxima actualización; por ahora lo revisas en la app.`;
  }
  return `✅ Recibido (#${id}). Revísalo en la app.`;
}

export function respuestaProcesado(capturaId) {
  return `✅ Procesado (#${idCorto(capturaId)}). Ya puedes revisarlo en la app.`;
}

export function respuestaRegistrada(resumen, capturaId) {
  const detalle = String(resumen ?? '').trim() || 'Movimiento registrado';
  return `✅ Registrado: ${detalle} (#${idCorto(capturaId)}). Puedes editarlo en la bandeja.`;
}

/** Pregunta por el primer dato que falta. */
export function preguntaFaltante(faltante, cuentas = []) {
  if (faltante === 'cuenta') {
    const nombres = cuentas.map((cuenta) => cuenta.nombre);
    return nombres.length > 0
      ? `¿De qué cuenta? Responde con el nombre: ${nombres.join(', ')}.`
      : '¿De qué cuenta? (No pude leer las cuentas de la app.)';
  }
  if (faltante === 'monto') {
    return '¿Cuánto fue? Escríbelo por ejemplo así: 18.500';
  }
  if (faltante === 'tipo') {
    return '¿Fue un gasto o un ingreso?';
  }
  return '¿Me das el dato que falta?';
}

/** Busca una cuenta por nombre dentro de una respuesta corta. */
export function elegirCuenta(texto, cuentas = []) {
  const buscado = normalizarTextoBasico(texto);
  if (!buscado) return null;
  let mejor = null;
  let largo = 0;
  for (const cuenta of cuentas) {
    const nombre = normalizarTextoBasico(cuenta.nombre);
    if (!nombre) continue;
    if (buscado === nombre || buscado.includes(nombre) || nombre.includes(buscado)) {
      if (nombre.length > largo) {
        mejor = cuenta;
        largo = nombre.length;
      }
    }
  }
  return mejor;
}

export function parsearTipo(texto) {
  const t = normalizarTextoBasico(texto);
  if (/\b(ingres\w*|recib\w*|entr\w*|cobr\w*)\b/.test(t)) {
    return 'ingreso';
  }
  if (/\b(gast\w*|pagu\w*|compr\w*|egres\w*)\b/.test(t)) {
    return 'gasto';
  }
  return null;
}

/** Convierte "18.500", "18500", "18,5 mil" o "1.5 millones" a centavos. */
export function parsearMonto(texto) {
  const t = normalizarTextoBasico(texto);
  if (!t) return null;
  let multiplicador = 1;
  if (/\bmil\b/.test(t) || /\bk\b/.test(t)) multiplicador = 1000;
  if (/\bmillones?\b/.test(t) || /\bmillon\b/.test(t)) multiplicador = 1000000;

  const limpio = t.replace(/[^\d.,]/g, '');
  if (!limpio) return null;
  const ultimoPunto = limpio.lastIndexOf('.');
  const ultimaComa = limpio.lastIndexOf(',');
  const ultimoSeparador = Math.max(ultimoPunto, ultimaComa);
  let numero;
  if (
    ultimoSeparador >= 0 &&
    limpio.length - ultimoSeparador - 1 <= 2 &&
    limpio.slice(0, ultimoSeparador).replace(/[^\d]/g, '').length > 0
  ) {
    const entero = limpio.slice(0, ultimoSeparador).replace(/[.,]/g, '');
    const decimales = limpio.slice(ultimoSeparador + 1);
    numero = Number(`${entero}.${decimales}`);
  } else {
    numero = Number(limpio.replace(/[.,]/g, ''));
  }
  if (!Number.isFinite(numero) || numero <= 0) return null;
  return Math.round(numero * multiplicador * 100);
}

function normalizarTextoBasico(texto) {
  return String(texto ?? '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

/**
 * Heurística para no ensuciar la bandeja con mensajes de charla ("hola").
 * El bot solo reenvía textos con un monto; el parser de la app hace el resto
 * (si falta la categoría, la propone "Otros" y el usuario la completa).
 */
export function pareceTransaccion(texto) {
  const contenido = String(texto ?? '');
  const conMontos = [
    /\$\s*\d[\d.,]*/,
    /\b\d[\d.,]*\s*(mil|k|millones?|millón)\b/i,
    /\b\d[\d.,]{2,}\b/,
  ];
  if (conMontos.some((patron) => patron.test(contenido))) {
    return true;
  }
  // Aunque falte el monto, una palabra de transacción permite que el bot
  // pregunte ("gasté" → ¿cuánto fue?).
  return parsearTipo(contenido) !== null;
}

/** Tipo normalizado que entrega el transporte. */
export function tipoDeMensaje(evento) {
  if (!evento) return 'otro';
  if (evento.tipo === 'texto' || evento.tipo === 'foto' || evento.tipo === 'audio') {
    return evento.tipo;
  }
  return 'otro';
}

export function extensionDeMedia(media) {
  const nombre = media?.nombre ?? '';
  const punto = nombre.lastIndexOf('.');
  if (punto >= 0 && punto < nombre.length - 1) {
    return nombre.slice(punto + 1).toLowerCase();
  }
  const mime = media?.mime ?? '';
  const mapa = {
    'image/jpeg': 'jpg',
    'image/png': 'png',
    'image/webp': 'webp',
    'audio/ogg': 'ogg',
    'audio/opus': 'opus',
    'audio/mpeg': 'mp3',
    'audio/mp4': 'm4a',
    'audio/amr': 'amr',
  };
  return mapa[mime] ?? 'bin';
}
