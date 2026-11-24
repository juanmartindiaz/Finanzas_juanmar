import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { crearAppClient } from './lib/app-client.js';
import { crearBot } from './lib/bot.js';
import { crearCola } from './lib/cola.js';
import { crearConversacion } from './lib/conversacion.js';
import { cargarConfig, preguntarNumeroSiFalta } from './lib/config.js';
import { crearLogger } from './lib/logger.js';
import { activarWakeLock } from './lib/termux.js';
import { TransporteBaileys } from './lib/wa.js';

const baseDir = path.dirname(fileURLToPath(import.meta.url));
const rutaConfig = process.env.CONFIG_PATH ?? path.join(baseDir, 'config.json');

const logger = crearLogger({
  dir: path.join(baseDir, 'logs'),
  debug: process.env.DEBUG === '1',
});

logger.info('Iniciando bot Gestor Finanzas…', 'bot');

let config;
try {
  config = cargarConfig(rutaConfig);
} catch (error) {
  logger.error(`No se pudo leer config.json: ${error.message}`, 'config');
  process.exit(1);
}

config = await preguntarNumeroSiFalta({ ruta: rutaConfig, config, logger });

if (!config.numero_autorizado) {
  logger.warn(
    '⚠️ Falta configurar numero_autorizado en config.json. Edita ese archivo ' +
      'con tu número (ej: 573001234567) y reinicia. No se procesará ningún ' +
      'mensaje hasta entonces.',
    'config',
  );
}
if (!config.token || config.token.startsWith('COPIA_AQUI')) {
  logger.error(
    '⚠️ Falta el token de la app en config.json. Cópialo desde Ajustes → ' +
      'Canal bot y pega el valor de "token".',
    'config',
  );
  process.exit(1);
}

activarWakeLock(logger);

const cola = crearCola({ dir: baseDir });
const conversacion = crearConversacion({ dir: baseDir });
const appClient = crearAppClient({
  baseUrl: `http://127.0.0.1:${config.puerto_app}`,
  token: config.token,
});
const transporte = new TransporteBaileys({
  authDir: path.join(baseDir, 'auth'),
  logger,
});
const bot = crearBot({ config, transporte, appClient, cola, conversacion, logger });

let cerrando = false;
async function salir(senal) {
  if (cerrando) return;
  cerrando = true;
  logger.info(`Recibida señal ${senal}; cerrando el bot…`, 'bot');
  try {
    await bot.detener();
  } finally {
    process.exit(0);
  }
}
process.on('SIGINT', () => void salir('SIGINT'));
process.on('SIGTERM', () => void salir('SIGTERM'));

try {
  await bot.iniciar();
} catch (error) {
  logger.error(`No se pudo iniciar el bot: ${error.stack ?? error.message}`, 'bot');
  process.exit(1);
}
