import {
  RESPUESTAS,
  extensionDeMedia,
  normalizarNumero,
  pareceTransaccion,
  respuestaExito,
  respuestaProcesado,
  tipoDeMensaje,
} from './mensajes.js';

/**
 * Orquestador del bot: filtra mensajes, encola antes de entregar y reintenta.
 * No conoce Baileys ni HTTP concretos: todo se inyecta (testeable).
 */
export function crearBot({
  config,
  transporte,
  appClient,
  cola,
  logger,
  reloj = {},
  intervaloReintentoMs = 30000,
}) {
  const ahora = reloj.ahora ?? (() => Date.now());
  const programarIntervalo = reloj.programarIntervalo ?? setInterval;
  const limpiarIntervalo = reloj.limpiarIntervalo ?? clearInterval;

  let activo = false;
  let temporizador = null;
  let avisoConfig = false;

  function numeroAutorizado() {
    return normalizarNumero(config.numero_autorizado) || null;
  }

  function lidAutorizado() {
    return normalizarNumero(config.lid_autorizado) || null;
  }

  function avisarConfigFaltante() {
    if (avisoConfig) return;
    avisoConfig = true;
    logger.warn(
      '⚠️ Falta configurar numero_autorizado en config.json. Edita ese archivo ' +
        'con tu número (ej: 573001234567) y reinicia. No se procesará ningún mensaje.',
      'config',
    );
  }

  async function iniciar() {
    if (!numeroAutorizado()) {
      avisarConfigFaltante();
    }
    activo = true;
    await transporte.iniciar({
      onMensaje: manejarMensaje,
      onConexion: manejarConexion,
    });
    temporizador = programarIntervalo(() => {
      void reintentarPendientes();
    }, intervaloReintentoMs);
    logger.info('Bot iniciado. Cola persistente activa.', 'bot');
  }

  async function detener() {
    activo = false;
    if (temporizador !== null) {
      limpiarIntervalo(temporizador);
      temporizador = null;
    }
    try {
      await transporte.cerrar();
    } catch (error) {
      logger.warn(`Error al cerrar el transporte: ${error?.message}`, 'wa');
    }
    logger.info('Bot detenido.', 'bot');
  }

  function manejarConexion(estado, detalle) {
    if (estado === 'logout') {
      logger.error(
        'WhatsApp cerró la sesión. Borra la carpeta auth/ y vuelve a iniciar ' +
          'para escanear un QR nuevo.',
        'wa',
      );
      return;
    }
    logger.info(
      `Conexión: ${estado}${detalle ? ` (${detalle})` : ''}`,
      'wa',
    );
  }

  async function manejarMensaje(evento) {
    if (!activo) return;
    if (!numeroAutorizado()) {
      avisarConfigFaltante();
      return;
    }
    if (evento.esGrupo || evento.esEstado) {
      logger.debug('Mensaje ignorado: grupo o estado.', 'filtro');
      return;
    }
    const numeroRemitente = normalizarNumero(evento.remitente);
    const numeroLid = normalizarNumero(evento.lid ?? '');
    const autorizadoPorNumero =
      numeroAutorizado() !== null && numeroRemitente === numeroAutorizado();
    const autorizadoPorLid =
      lidAutorizado() !== null && numeroLid === lidAutorizado();
    if (!autorizadoPorNumero && !autorizadoPorLid) {
      logger.info(
        `Mensaje ignorado de remitente no autorizado: ${numeroRemitente}` +
          (numeroLid ? ` (LID ${numeroLid})` : ''),
        'filtro',
      );
      return;
    }

    const tipo = tipoDeMensaje(evento);
    if (tipo === 'otro') {
      logger.info(`Formato no soportado de ${evento.id}`, 'mensajes');
      await responder(evento, RESPUESTAS.formatoNoSoportado);
      return;
    }

    if (tipo === 'texto') {
      const texto = String(evento.texto ?? '').trim();
      if (!texto) {
        await responder(evento, RESPUESTAS.formatoNoSoportado);
        return;
      }
      if (!pareceTransaccion(texto)) {
        logger.info(
          `Texto sin monto; no se envía a la app (${evento.id})`,
          'filtro',
        );
        await responder(evento, RESPUESTAS.noEsTransaccion);
        return;
      }
      const mensaje = {
        message_id: evento.id,
        tipo: 'texto',
        texto,
        timestamp: Number(evento.timestamp) || ahora(),
        remitente: evento.remitente,
      };
      await encolarYEntregar(evento, mensaje);
      return;
    }

    // Foto o audio: se descarga y se encola antes de intentar.
    let media;
    try {
      media = await transporte.descargarMedia(evento);
    } catch (error) {
      logger.error(
        `No se pudo descargar ${tipo} ${evento.id}: ${error?.message}`,
        'mensajes',
      );
      await responder(evento, RESPUESTAS.errorDescarga);
      return;
    }
    const mensaje = {
      message_id: evento.id,
      tipo,
      timestamp: Number(evento.timestamp) || ahora(),
      remitente: evento.remitente,
      mime: media.mime ?? 'application/octet-stream',
      nombre: media.nombre ?? `archivo.${extensionDeMedia(media)}`,
      mediaArchivo: null,
    };
    mensaje.mediaArchivo = cola.guardarMedia(
      evento.id,
      media.bytes,
      extensionDeMedia(media),
    );
    await encolarYEntregar(evento, mensaje);
  }

  async function encolarYEntregar(evento, mensaje, { reintento = false } = {}) {
    cola.guardarPendiente(mensaje);
    const resultado = await entregar(mensaje);

    if (resultado.ok) {
      cola.marcarEntregado(mensaje);
      logger.info(
        `Entregado ${mensaje.tipo} ${mensaje.message_id} → captura ${resultado.body?.captura_id}`,
        'entrega',
      );
      if (!reintento) {
        await responder(
          evento,
          respuestaExito(mensaje.tipo, resultado.body?.captura_id),
        );
      }
      return;
    }

    if (resultado.status === 409) {
      cola.marcarEntregado(mensaje);
      logger.info(`Duplicado ${mensaje.message_id}; se trata como entregado.`, 'entrega');
      await responder(evento, RESPUESTAS.duplicado);
      return;
    }

    if (resultado.status === 401) {
      cola.eliminarPendiente(mensaje);
      logger.error(
        '401 del servidor local: revisa el token en Ajustes → Canal bot.',
        'entrega',
      );
      await responder(evento, RESPUESTAS.tokenInvalido);
      return;
    }

    if (resultado.status === 413) {
      cola.eliminarPendiente(mensaje);
      logger.warn(`413 archivo demasiado grande: ${mensaje.message_id}`, 'entrega');
      await responder(evento, RESPUESTAS.archivoGrande);
      return;
    }

    logger.warn(
      `No se pudo entregar ${mensaje.message_id} (status ${resultado.status}); queda en cola.`,
      'entrega',
    );
    if (!reintento) {
      await responder(evento, RESPUESTAS.esperandoApp);
    }
  }

  async function entregar(mensaje) {
    if (mensaje.tipo === 'texto') {
      return appClient.enviarTexto({
        messageId: mensaje.message_id,
        texto: mensaje.texto,
        canal: 'texto',
        timestamp: mensaje.timestamp,
      });
    }
    const bytes = cola.leerMedia(mensaje);
    if (!bytes) {
      logger.error(`Adjunto perdido para ${mensaje.message_id}`, 'cola');
      return { status: 0, ok: false, error: 'adjunto perdido' };
    }
    return appClient.enviarArchivo({
      messageId: mensaje.message_id,
      timestamp: mensaje.timestamp,
      tipo: mensaje.tipo,
      bytes,
      mime: mensaje.mime,
      nombre: mensaje.nombre,
    });
  }

  /** Loop de reintento: recorre pendientes y los entrega si la app responde. */
  async function reintentarPendientes() {
    if (!numeroAutorizado()) return;
    const pendientes = cola.listarPendientes();
    for (const mensaje of pendientes) {
      const resultado = await entregar(mensaje);
      if (resultado.ok || resultado.status === 409) {
        cola.marcarEntregado(mensaje);
        logger.info(
          `Reintento entregado ${mensaje.message_id} → captura ${resultado.body?.captura_id}`,
          'reintentos',
        );
        if (resultado.ok) {
          await responder(
            { remitente: mensaje.remitente },
            respuestaProcesado(resultado.body?.captura_id),
          );
        }
        continue;
      }
      if (resultado.status === 401 || resultado.status === 413) {
        cola.eliminarPendiente(mensaje);
        logger.error(
          `Reintento descartado (${resultado.status}): ${mensaje.message_id}`,
          'reintentos',
        );
        continue;
      }
      logger.warn(
        `Sigue en cola ${mensaje.message_id} (status ${resultado.status}).`,
        'reintentos',
      );
    }
  }

  async function responder(evento, texto) {
    try {
      if (!evento?.remitente) return;
      await transporte.enviarTexto(evento.remitente, texto);
    } catch (error) {
      logger.warn(`No se pudo responder al usuario: ${error?.message}`, 'wa');
    }
  }

  return {
    iniciar,
    detener,
    manejarMensaje,
    reintentarPendientes,
    get activo() {
      return activo;
    },
  };
}
