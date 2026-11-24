import { spawn } from 'node:child_process';

/** Activa termux-wake-lock si está disponible; si no, no hace nada. */
export function activarWakeLock(logger) {
  try {
    const proceso = spawn('termux-wake-lock', [], { stdio: 'ignore' });
    proceso.on('error', () => {
      logger?.debug?.('termux-wake-lock no disponible (normal fuera de Termux)');
    });
    proceso.on('exit', (codigo) => {
      if (codigo === 0) {
        logger?.info?.('termux-wake-lock activado.', 'termux');
      }
    });
  } catch {
    // Fuera de Termux no existe; se ignora.
  }
}
