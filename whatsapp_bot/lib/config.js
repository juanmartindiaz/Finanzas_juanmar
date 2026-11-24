import fs from 'node:fs';
import path from 'node:path';

const POR_DEFECTO = {
  numero_autorizado: null,
  lid_autorizado: null,
  token: '',
  puerto_app: 8787,
};

export function cargarConfig(ruta) {
  if (!fs.existsSync(ruta)) {
    return { ...POR_DEFECTO };
  }
  try {
    const crudo = JSON.parse(fs.readFileSync(ruta, 'utf8'));
    return {
      numero_autorizado: crudo.numero_autorizado ?? null,
      lid_autorizado: crudo.lid_autorizado ?? null,
      token: String(crudo.token ?? ''),
      puerto_app: Number(crudo.puerto_app) || POR_DEFECTO.puerto_app,
    };
  } catch (error) {
    throw new Error(`config.json inválido: ${error.message}`);
  }
}

export function guardarConfig(ruta, config) {
  fs.mkdirSync(path.dirname(ruta), { recursive: true });
  fs.writeFileSync(
    ruta,
    JSON.stringify(
      {
        numero_autorizado: config.numero_autorizado ?? null,
        lid_autorizado: config.lid_autorizado ?? null,
        token: config.token ?? '',
        puerto_app: config.puerto_app ?? POR_DEFECTO.puerto_app,
      },
      null,
      2,
    ),
  );
}

/** Pregunta interactiva en la primera ejecución (solo TTY). */
export async function preguntarNumeroSiFalta({ ruta, config, logger }) {
  if (config.numero_autorizado) return config;
  if (!process.stdin.isTTY) return config;
  const { createInterface } = await import('node:readline/promises');
  const rl = createInterface({ input: process.stdin, output: process.stdout });
  try {
    const respuesta = await rl.question(
      'Ingresa tu número autorizado (solo dígitos, ej. 573001234567): ',
    );
    const limpio = String(respuesta).replace(/\D/g, '');
    if (limpio.length >= 8) {
      config.numero_autorizado = limpio;
      guardarConfig(ruta, config);
      logger.info(`Número autorizado guardado: ${limpio}`, 'config');
    } else {
      logger.warn('Número inválido; edita config.json a mano.', 'config');
    }
  } finally {
    rl.close();
  }
  return config;
}
