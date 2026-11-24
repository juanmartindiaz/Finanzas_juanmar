import fs from 'node:fs';
import path from 'node:path';

const RETENCION_DIAS = 7;

/**
 * Logger simple: stdout + archivo diario `logs/bot-YYYY-MM-DD.log`.
 * No registra el contenido de los mensajes salvo nivel DEBUG.
 */
export function crearLogger({ dir, debug = false, ahora = () => new Date() } = {}) {
  const carpeta = dir ?? path.join(process.cwd(), 'logs');
  fs.mkdirSync(carpeta, { recursive: true });

  function rutaArchivo(fecha) {
    const dia = fecha.toISOString().slice(0, 10);
    return path.join(carpeta, `bot-${dia}.log`);
  }

  function limpiarAntiguos(fecha) {
    try {
      const limite = fecha.getTime() - RETENCION_DIAS * 24 * 60 * 60 * 1000;
      for (const nombre of fs.readdirSync(carpeta)) {
        const coincidencia = /^bot-(\d{4}-\d{2}-\d{2})\.log$/.exec(nombre);
        if (!coincidencia) continue;
        const fechaArchivo = Date.parse(`${coincidencia[1]}T00:00:00Z`);
        if (Number.isFinite(fechaArchivo) && fechaArchivo < limite) {
          fs.rmSync(path.join(carpeta, nombre), { force: true });
        }
      }
    } catch {
      // La limpieza no debe romper el bot.
    }
  }

  function escribir(nivel, modulo, mensaje) {
    const fecha = ahora();
    const linea = `[${fecha.toISOString()}] [${nivel}] [${modulo}] ${mensaje}`;
    console.log(linea);
    try {
      limpiarAntiguos(fecha);
      fs.appendFileSync(rutaArchivo(fecha), `${linea}\n`);
    } catch {
      // Si no se puede escribir el archivo, stdout ya tiene la línea.
    }
  }

  return {
    info: (mensaje, modulo = 'bot') => escribir('INFO', modulo, mensaje),
    warn: (mensaje, modulo = 'bot') => escribir('WARN', modulo, mensaje),
    error: (mensaje, modulo = 'bot') => escribir('ERROR', modulo, mensaje),
    debug: (mensaje, modulo = 'bot') => {
      if (debug) escribir('DEBUG', modulo, mensaje);
    },
  };
}
