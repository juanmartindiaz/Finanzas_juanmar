import fs from 'node:fs';
import path from 'node:path';

/**
 * Estado de conversación por remitente (qué captura está esperando datos).
 * Se guarda en la cola para sobrevivir reinicios del bot.
 */
export function crearConversacion({ dir } = {}) {
  const carpeta = path.join(dir ?? process.cwd(), 'cola');
  fs.mkdirSync(carpeta, { recursive: true });
  const archivo = path.join(carpeta, 'conversacion.json');

  let datos = {};
  try {
    datos = JSON.parse(fs.readFileSync(archivo, 'utf8')) ?? {};
  } catch {
    datos = {};
  }

  function persistir() {
    const temporal = `${archivo}.tmp`;
    fs.writeFileSync(temporal, JSON.stringify(datos, null, 2));
    fs.renameSync(temporal, archivo);
  }

  return {
    obtener(remitente) {
      const clave = String(remitente ?? '').replace(/\D/g, '');
      return clave && datos[clave] ? datos[clave] : null;
    },
    guardar(remitente, estado) {
      const clave = String(remitente ?? '').replace(/\D/g, '');
      if (!clave) return;
      datos[clave] = estado;
      persistir();
    },
    limpiar(remitente) {
      const clave = String(remitente ?? '').replace(/\D/g, '');
      if (!clave) return;
      delete datos[clave];
      persistir();
    },
  };
}
