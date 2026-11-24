/**
 * Cliente HTTP del bot hacia el servidor local de la app.
 * No lanza por errores de red: devuelve { status: 0, ok:false, error }.
 */
export function crearAppClient({
  baseUrl,
  token,
  fetchImpl = globalThis.fetch,
  timeoutMs = 15000,
} = {}) {
  const base = baseUrl.replace(/\/+$/, '');

  async function pedir(ruta, opciones) {
    try {
      const respuesta = await fetchImpl(`${base}${ruta}`, {
        ...opciones,
        signal: AbortSignal.timeout(timeoutMs),
      });
      const texto = await respuesta.text();
      let cuerpo = {};
      try {
        cuerpo = texto ? JSON.parse(texto) : {};
      } catch {
        cuerpo = {};
      }
      return { status: respuesta.status, ok: respuesta.ok, body: cuerpo };
    } catch (error) {
      return { status: 0, ok: false, error: error?.message ?? 'Error de red' };
    }
  }

  async function enviarTexto({ messageId, texto, canal = 'texto', timestamp }) {
    return pedir('/api/capturas/texto', {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-bot-token': token,
      },
      body: JSON.stringify({
        message_id: messageId,
        texto,
        canal,
        timestamp,
      }),
    });
  }

  async function enviarArchivo({
    messageId,
    timestamp,
    tipo,
    bytes,
    mime = 'application/octet-stream',
    nombre = 'archivo.bin',
  }) {
    const formulario = new FormData();
    formulario.append('message_id', messageId);
    formulario.append('timestamp', String(timestamp));
    formulario.append(
      'archivo',
      new Blob([Buffer.from(bytes)], { type: mime }),
      nombre,
    );
    return pedir(tipo === 'audio' ? '/api/audio' : '/api/capturas/foto', {
      method: 'POST',
      headers: { 'x-bot-token': token },
      body: formulario,
    });
  }

  return { enviarTexto, enviarArchivo };
}
