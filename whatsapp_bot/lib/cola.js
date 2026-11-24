import fs from 'node:fs';
import path from 'node:path';

/**
 * Cola de entrada persistente: cada mensaje se guarda antes de intentar la
 * entrega a la app. Sobrevive reinicios del bot.
 */
export function crearCola({ dir } = {}) {
  const raiz = dir ?? process.cwd();
  const pendientes = path.join(raiz, 'cola', 'pendientes');
  const entregados = path.join(raiz, 'cola', 'entregados');
  fs.mkdirSync(pendientes, { recursive: true });
  fs.mkdirSync(entregados, { recursive: true });

  const nombreSeguro = (id) => String(id).replace(/[^A-Za-z0-9_.-]/g, '_');
  const rutaJson = (id, carpeta = pendientes) =>
    path.join(carpeta, `${nombreSeguro(id)}.json`);

  function guardarPendiente(mensaje) {
    const destino = rutaJson(mensaje.message_id);
    const temporal = `${destino}.tmp`;
    fs.writeFileSync(temporal, JSON.stringify(mensaje), 'utf8');
    fs.renameSync(temporal, destino);
    return destino;
  }

  /** Guarda los bytes de un adjunto junto al JSON y devuelve el nombre. */
  function guardarMedia(id, bytes, extension = 'bin') {
    const nombre = `${nombreSeguro(id)}.${extension}`;
    fs.writeFileSync(path.join(pendientes, nombre), Buffer.from(bytes));
    return nombre;
  }

  function listarPendientes() {
    return fs
      .readdirSync(pendientes)
      .filter((nombre) => nombre.endsWith('.json'))
      .map((nombre) => {
        try {
          return JSON.parse(fs.readFileSync(path.join(pendientes, nombre), 'utf8'));
        } catch {
          return null;
        }
      })
      .filter(Boolean);
  }

  function leerMedia(mensaje) {
    if (!mensaje.mediaArchivo) return null;
    const ruta = path.join(pendientes, mensaje.mediaArchivo);
    return fs.existsSync(ruta) ? fs.readFileSync(ruta) : null;
  }

  function moverArchivo(origen, destino) {
    if (!fs.existsSync(origen)) return;
    try {
      fs.renameSync(origen, destino);
    } catch {
      fs.copyFileSync(origen, destino);
      fs.rmSync(origen, { force: true });
    }
  }

  function marcarEntregado(mensaje) {
    const id = mensaje.message_id;
    moverArchivo(rutaJson(id), rutaJson(id, entregados));
    if (mensaje.mediaArchivo) {
      moverArchivo(
        path.join(pendientes, mensaje.mediaArchivo),
        path.join(entregados, mensaje.mediaArchivo),
      );
    }
  }

  function eliminarPendiente(mensaje) {
    fs.rmSync(rutaJson(mensaje.message_id), { force: true });
    if (mensaje.mediaArchivo) {
      fs.rmSync(path.join(pendientes, mensaje.mediaArchivo), { force: true });
    }
  }

  function contarPendientes() {
    return fs.readdirSync(pendientes).filter((n) => n.endsWith('.json')).length;
  }

  function contarEntregados() {
    return fs.readdirSync(entregados).filter((n) => n.endsWith('.json')).length;
  }

  return {
    guardarPendiente,
    guardarMedia,
    listarPendientes,
    leerMedia,
    marcarEntregado,
    eliminarPendiente,
    contarPendientes,
    contarEntregados,
  };
}
