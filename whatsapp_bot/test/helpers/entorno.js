import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

import { crearAppClient } from '../../lib/app-client.js';
import { crearBot } from '../../lib/bot.js';
import { crearCola } from '../../lib/cola.js';
import { crearLogger } from '../../lib/logger.js';
import { MockTransporte, loggerSilencioso } from './mock-transporte.js';
import { crearServidorMock } from './mock-server.js';

export const NUMERO = '573001234567';

export async function crearEntorno({
  respuesta = { status: 201, body: { captura_id: 1234, estado: 'listo' } },
  config = {},
  media,
  dirReutilizable,
  baseUrl,
  servidorExistente,
  logger = loggerSilencioso(),
} = {}) {
  const dir = dirReutilizable ?? fs.mkdtempSync(path.join(os.tmpdir(), 'bot-'));
  const servidor = servidorExistente ?? (await crearServidorMock());
  if (servidorExistente) {
    servidor.responder(respuesta);
  } else {
    servidor.responder(respuesta);
  }
  const cola = crearCola({ dir });
  const transporte = new MockTransporte({ media });
  const appClient = crearAppClient({
    baseUrl: baseUrl ?? servidor.url,
    token: 'token-prueba',
  });
  const configuracion = {
    numero_autorizado: NUMERO,
    token: 'token-prueba',
    puerto_app: servidor.puerto,
    ...config,
  };
  const bot = crearBot({
    config: configuracion,
    transporte,
    appClient,
    cola,
    logger,
  });
  await bot.iniciar();

  async function cerrar() {
    await bot.detener();
    if (!servidorExistente) {
      await servidor.cerrar();
    }
    if (!dirReutilizable) {
      fs.rmSync(dir, { recursive: true, force: true });
    }
  }

  return { dir, servidor, cola, transporte, bot, configuracion, cerrar };
}

export function eventoTexto(overrides = {}) {
  return {
    id: `m-${Math.random().toString(36).slice(2)}`,
    remitente: `${NUMERO}@s.whatsapp.net`,
    tipo: 'texto',
    texto: 'gasté 18.500 en mercado',
    timestamp: 1795500000000,
    esGrupo: false,
    esEstado: false,
    ...overrides,
  };
}

export { crearLogger };
