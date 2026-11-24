/** Transporte falso: no conecta a WhatsApp; los tests emiten eventos. */
export class MockTransporte {
  constructor({ media } = {}) {
    this.enviados = [];
    this.media = media ?? {
      bytes: Buffer.from('FOTO_BYTES'),
      mime: 'image/jpeg',
      nombre: 'recibo.jpg',
    };
    this.errorDescarga = null;
    this.cerrado = false;
    this.onMensaje = null;
    this.onConexion = null;
  }

  async iniciar({ onMensaje, onConexion }) {
    this.onMensaje = onMensaje;
    this.onConexion = onConexion;
  }

  async enviarTexto(jid, texto) {
    this.enviados.push({ jid, texto });
  }

  async descargarMedia() {
    if (this.errorDescarga) throw new Error(this.errorDescarga);
    return this.media;
  }

  async cerrar() {
    this.cerrado = true;
  }

  async emitir(evento) {
    await this.onMensaje?.(evento);
  }

  conectar() {
    this.onConexion?.('abierta');
  }
}

export function loggerSilencioso() {
  return { info() {}, warn() {}, error() {}, debug() {} };
}
