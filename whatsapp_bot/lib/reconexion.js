/** Backoff de reconexión y decisión ante logout. */

export const ESPERAS_RECONEXION_MS = [1000, 2000, 5000, 10000, 30000, 60000];

/** Espera para el intento n (1-based), con tope de 60 s. */
export function siguienteEspera(intento) {
  const indice = Math.max(1, Math.floor(intento)) - 1;
  return ESPERAS_RECONEXION_MS[Math.min(indice, ESPERAS_RECONEXION_MS.length - 1)];
}

/**
 * Solo reintenta si la sesión sigue siendo válida. Si el usuario cerró sesión
 * desde el teléfono, hay que pedir un QR nuevo (borrando auth/).
 */
export function debeReintentar(motivoDesconexion) {
  return motivoDesconexion !== 'logout';
}
