import qrcode from 'qrcode-terminal';

import { debeReintentar, siguienteEspera } from './reconexion.js';

const MIME_EXTENSION = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
  'audio/ogg': 'ogg',
  'audio/opus': 'opus',
  'audio/mpeg': 'mp3',
  'audio/mp4': 'm4a',
  'audio/amr': 'amr',
};

/**
 * Transporte real de WhatsApp con Baileys.
 *
 * `baileys` se importa **dinámicamente** al iniciar, para que los tests del bot
 * (transporte falso) no necesiten cargar la librería ni una sesión real.
 */
export class TransporteBaileys {
  constructor({ authDir, logger, alPedirQr } = {}) {
    this.authDir = authDir;
    this.logger = logger;
    this.alPedirQr = alPedirQr;
    this.sock = null;
    this.intento = 0;
    this.temporizador = null;
    this.cerrado = false;
    this.onMensaje = null;
    this.onConexion = null;
    this.baileys = null;
  }

  async iniciar({ onMensaje, onConexion }) {
    this.onMensaje = onMensaje;
    this.onConexion = onConexion;
    await this.#conectar();
  }

  async #conectar() {
    const baileys = await import('baileys');
    this.baileys = baileys;
    const makeWASocket = baileys.default ?? baileys.makeWASocket;
    const { useMultiFileAuthState, DisconnectReason, fetchLatestBaileysVersion } =
      baileys;

    const { state, saveCreds } = await useMultiFileAuthState(this.authDir);
    const versionInfo = await fetchLatestBaileysVersion().catch(() => null);

    const sock = makeWASocket({
      auth: state,
      ...(versionInfo?.version ? { version: versionInfo.version } : {}),
      printQRInTerminal: false,
      browser: ['Gestor Finanzas', 'Chrome', '1.0'],
    });
    this.sock = sock;

    sock.ev.on('creds.update', saveCreds);
    sock.ev.on('connection.update', (actualizacion) => {
      const { connection, qr, lastDisconnect } = actualizacion;
      if (qr) {
        this.logger.info(
          'Escanea este QR con el número SECUNDARIO de WhatsApp:',
          'wa',
        );
        qrcode.generate(qr, { small: true });
        this.alPedirQr?.(qr);
        this.onConexion?.('qr');
      }
      if (connection === 'open') {
        this.intento = 0;
        this.logger.info('Conectado a WhatsApp.', 'wa');
        this.onConexion?.('abierta');
      }
      if (connection === 'close') {
        const codigo = lastDisconnect?.error?.output?.statusCode;
        const cerradoPorUsuario =
          codigo === DisconnectReason?.loggedOut || codigo === 401;
        if (cerradoPorUsuario) {
          this.logger.error(
            'La sesión de WhatsApp se cerró. Borra auth/ y vuelve a iniciar ' +
              'para escanear un QR nuevo.',
            'wa',
          );
          this.onConexion?.('logout');
          return;
        }
        if (this.cerrado) return;
        this.intento += 1;
        const espera = siguienteEspera(this.intento);
        this.logger.warn(
          `Desconectado (código ${codigo ?? 'desconocido'}). Reintento ` +
            `${this.intento} en ${espera} ms.`,
          'wa',
        );
        if (!debeReintentar('red')) return;
        this.temporizador = setTimeout(() => {
          void this.#conectar().catch((error) =>
            this.logger.error(`Reconexión fallida: ${error.message}`, 'wa'),
          );
        }, espera);
        this.onConexion?.('cerrada', codigo);
      }
    });

    sock.ev.on('messages.upsert', (evento) => {
      if (evento?.type !== 'notify') return;
      for (const mensaje of evento.messages ?? []) {
        const normalizado = this.#normalizar(mensaje);
        if (!normalizado) continue;
        Promise.resolve(this.onMensaje?.(normalizado)).catch((error) =>
          this.logger.error(`Error procesando mensaje: ${error.message}`, 'wa'),
        );
      }
    });
  }

  #normalizar(mensaje) {
    const key = mensaje?.key;
    if (!key?.remoteJid || key.fromMe) return null;
    const jid = key.remoteJid;
    const contenido = mensaje.message ?? {};
    let tipo = 'otro';
    let texto = null;

    if (typeof contenido.conversation === 'string') {
      tipo = 'texto';
      texto = contenido.conversation;
    } else if (contenido.extendedTextMessage?.text) {
      tipo = 'texto';
      texto = contenido.extendedTextMessage.text;
    } else if (contenido.imageMessage) {
      tipo = 'foto';
      texto = contenido.imageMessage.caption ?? null;
    } else if (contenido.audioMessage) {
      tipo = 'audio';
    }

    return {
      id: key.id,
      remitente: jid,
      tipo,
      texto,
      timestamp: Number(mensaje.messageTimestamp) * 1000 || Date.now(),
      esGrupo: jid.endsWith('@g.us'),
      esEstado: jid === 'status@broadcast' || jid.endsWith('@broadcast'),
      crudo: mensaje,
    };
  }

  async enviarTexto(jid, texto) {
    if (!this.sock) throw new Error('WhatsApp no está conectado.');
    await this.sock.sendMessage(jid, { text: texto });
  }

  async descargarMedia(evento) {
    if (!this.sock || !this.baileys) {
      throw new Error('WhatsApp no está conectado.');
    }
    const contenido = evento.crudo?.message ?? {};
    const bytes = await this.baileys.downloadMediaMessage(
      evento.crudo,
      'buffer',
      {},
      { logger: this.#loggerBaileys() },
    );
    const mime =
      contenido.imageMessage?.mimetype ??
      contenido.audioMessage?.mimetype ??
      'application/octet-stream';
    const extension = MIME_EXTENSION[mime] ?? 'bin';
    return {
      bytes,
      mime,
      nombre: `${evento.id}.${extension}`,
    };
  }

  #loggerBaileys() {
    const silencioso = {
      trace() {},
      debug() {},
      info() {},
      warn() {},
      error() {},
      fatal() {},
      child() {
        return silencioso;
      },
    };
    return silencioso;
  }

  async cerrar() {
    this.cerrado = true;
    if (this.temporizador) {
      clearTimeout(this.temporizador);
      this.temporizador = null;
    }
    try {
      this.sock?.end?.();
    } catch {
      // Ignorado al cerrar.
    }
    this.sock = null;
  }
}
