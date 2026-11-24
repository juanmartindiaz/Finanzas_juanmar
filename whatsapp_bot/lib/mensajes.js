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
  return conMontos.some((patron) => patron.test(contenido));
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
