import { beforeEach, describe, expect, test } from 'vitest';

import { crearAppClient } from '../lib/app-client.js';
import { crearBot } from '../lib/bot.js';
import { crearCola } from '../lib/cola.js';
import { crearLogger } from '../lib/logger.js';
import { RESPUESTAS } from '../lib/mensajes.js';
import { crearServidorMock } from './helpers/mock-server.js';
import { MockTransporte, loggerSilencioso } from './helpers/mock-transporte.js';
import { NUMERO, crearEntorno, eventoTexto } from './helpers/entorno.js';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

function jsonDe(peticion) {
  return JSON.parse(peticion.cuerpo.toString('utf8'));
}

describe('bot: flujo feliz y filtros', () => {
  let entorno;
  beforeEach(async () => {
    entorno = await crearEntorno();
  });

  test('texto autorizado se entrega con el payload correcto y responde', async () => {
    const evento = eventoTexto({ texto: 'gasté 18.500 en mercado' });
    await entorno.transporte.emitir(evento);

    expect(entorno.servidor.peticiones).toHaveLength(1);
    const peticion = entorno.servidor.peticiones[0];
    expect(peticion.url).toBe('/api/capturas/texto');
    expect(peticion.headers['x-bot-token']).toBe('token-prueba');
    expect(jsonDe(peticion)).toEqual({
      message_id: evento.id,
      texto: 'gasté 18.500 en mercado',
      canal: 'texto',
      timestamp: evento.timestamp,
    });
    expect(entorno.transporte.enviados[0].texto).toContain('✅ Recibido (#1234)');
    expect(entorno.cola.contarPendientes()).toBe(0);
    expect(entorno.cola.contarEntregados()).toBe(1);
    await entorno.cerrar();
  });

  test('foto se entrega por multipart y responde 📷', async () => {
    const entornoFoto = await crearEntorno();
    await entornoFoto.transporte.emitir(
      eventoTexto({ tipo: 'foto', texto: null }),
    );
    const peticion = entornoFoto.servidor.peticiones[0];
    expect(peticion.url).toBe('/api/capturas/foto');
    expect(peticion.headers['content-type']).toContain('multipart/form-data');
    const cuerpo = peticion.cuerpo.toString('latin1');
    expect(cuerpo).toContain('name="message_id"');
    expect(cuerpo).toContain('name="archivo"');
    expect(cuerpo).toContain('recibo.jpg');
    expect(entornoFoto.transporte.enviados[0].texto).toContain('📷 Foto guardada');
    await entornoFoto.cerrar();
  });

  test('audio se entrega por /api/audio y responde 🎤', async () => {
    const entornoAudio = await crearEntorno();
    await entornoAudio.transporte.emitir(
      eventoTexto({ tipo: 'audio', texto: null }),
    );
    expect(entornoAudio.servidor.peticiones[0].url).toBe('/api/audio');
    expect(entornoAudio.transporte.enviados[0].texto).toContain('🎤 Audio guardado');
    await entornoAudio.cerrar();
  });

  test('formato no soportado responde y no crea captura', async () => {
    const entornoOtro = await crearEntorno();
    await entornoOtro.transporte.emitir(eventoTexto({ tipo: 'video' }));
    expect(entornoOtro.servidor.peticiones).toHaveLength(0);
    expect(entornoOtro.transporte.enviados[0].texto).toBe(
      RESPUESTAS.formatoNoSoportado,
    );
    await entornoOtro.cerrar();
  });

  test('texto de charla no crea captura y pide ejemplo', async () => {
    const entornoChat = await crearEntorno();
    await entornoChat.transporte.emitir(eventoTexto({ texto: 'hola, ¿cómo estás?' }));
    expect(entornoChat.servidor.peticiones).toHaveLength(0);
    expect(entornoChat.transporte.enviados[0].texto).toBe(
      RESPUESTAS.noEsTransaccion,
    );
    await entornoChat.cerrar();
  });

  test('texto con monto y sin categoría sí crea captura', async () => {
    const entornoMonto = await crearEntorno();
    await entornoMonto.transporte.emitir(eventoTexto({ texto: 'gasté 20.000' }));
    expect(entornoMonto.servidor.peticiones).toHaveLength(1);
    expect(entornoMonto.transporte.enviados[0].texto).toContain('✅ Recibido');
    await entornoMonto.cerrar();
  });

  test('mensaje de grupo se ignora', async () => {
    await entorno.transporte.emitir(eventoTexto({ esGrupo: true }));
    expect(entorno.servidor.peticiones).toHaveLength(0);
    expect(entorno.transporte.enviados).toHaveLength(0);
    await entorno.cerrar();
  });
});

describe('bot: autorización (sin TOFU)', () => {
  test('(A) sin numero_autorizado no procesa', async () => {
    const entorno = await crearEntorno({ config: { numero_autorizado: null } });
    await entorno.transporte.emitir(eventoTexto());
    expect(entorno.servidor.peticiones).toHaveLength(0);
    expect(entorno.transporte.enviados).toHaveLength(0);
    await entorno.cerrar();
  });

  test('(B) remitente distinto se ignora', async () => {
    const entorno = await crearEntorno();
    await entorno.transporte.emitir(
      eventoTexto({ remitente: '573009999999@s.whatsapp.net' }),
    );
    expect(entorno.servidor.peticiones).toHaveLength(0);
    expect(entorno.transporte.enviados).toHaveLength(0);
    await entorno.cerrar();
  });

  test('(C) remitente correcto procesa', async () => {
    const entorno = await crearEntorno();
    await entorno.transporte.emitir(eventoTexto());
    expect(entorno.servidor.peticiones).toHaveLength(1);
    await entorno.cerrar();
  });

  test('(D) LID autorizado en config permite procesar', async () => {
    const entorno = await crearEntorno({
      config: { lid_autorizado: '69072452640988' },
    });
    await entorno.transporte.emitir(
      eventoTexto({
        remitente: '69072452640988@lid',
        lid: '69072452640988@lid',
      }),
    );
    expect(entorno.servidor.peticiones).toHaveLength(1);
    await entorno.cerrar();
  });
});

describe('bot: errores del servidor', () => {
  test('401 responde token inválido y no deja cola', async () => {
    const entorno = await crearEntorno({ respuesta: { status: 401, body: {} } });
    await entorno.transporte.emitir(eventoTexto());
    expect(entorno.transporte.enviados[0].texto).toBe(RESPUESTAS.tokenInvalido);
    expect(entorno.cola.contarPendientes()).toBe(0);
    expect(entorno.cola.contarEntregados()).toBe(0);
    await entorno.cerrar();
  });

  test('409 directo responde duplicado y se trata como entregado', async () => {
    const entorno = await crearEntorno({
      respuesta: { status: 409, body: { captura_id: 55 } },
    });
    await entorno.transporte.emitir(eventoTexto());
    expect(entorno.transporte.enviados[0].texto).toBe(RESPUESTAS.duplicado);
    expect(entorno.cola.contarPendientes()).toBe(0);
    expect(entorno.cola.contarEntregados()).toBe(1);
    await entorno.cerrar();
  });

  test('413 responde archivo grande y no deja cola', async () => {
    const entorno = await crearEntorno({ respuesta: { status: 413, body: {} } });
    await entorno.transporte.emitir(eventoTexto({ tipo: 'foto' }));
    expect(entorno.transporte.enviados[0].texto).toBe(RESPUESTAS.archivoGrande);
    expect(entorno.cola.contarPendientes()).toBe(0);
    await entorno.cerrar();
  });

  test('5xx encola, avisa y reintenta hasta entregar', async () => {
    const entorno = await crearEntorno({ respuesta: { status: 503, body: {} } });
    await entorno.transporte.emitir(eventoTexto());
    expect(entorno.transporte.enviados.at(-1).texto).toBe(
      RESPUESTAS.esperandoApp,
    );
    expect(entorno.cola.contarPendientes()).toBe(1);

    entorno.servidor.responder({ status: 201, body: { captura_id: 77 } });
    await entorno.bot.reintentarPendientes();
    expect(entorno.cola.contarPendientes()).toBe(0);
    expect(entorno.cola.contarEntregados()).toBe(1);
    expect(entorno.transporte.enviados.at(-1).texto).toContain('✅ Procesado (#77)');
    await entorno.cerrar();
  });

  test('conexión rechazada encola y reintenta', async () => {
    const servidor = await crearServidorMock();
    const puerto = servidor.puerto;
    await servidor.cerrar();
    const entorno = await crearEntorno({
      baseUrl: `http://127.0.0.1:${puerto}`,
    });
    await entorno.transporte.emitir(eventoTexto());
    expect(entorno.cola.contarPendientes()).toBe(1);
    expect(entorno.transporte.enviados.at(-1).texto).toBe(
      RESPUESTAS.esperandoApp,
    );

    const servidorNuevo = await crearServidorMock({ puerto });
    servidorNuevo.responder({ status: 201, body: { captura_id: 88 } });
    entorno.servidor = servidorNuevo;
    await entorno.bot.reintentarPendientes();
    expect(entorno.cola.contarPendientes()).toBe(0);
    expect(entorno.transporte.enviados.at(-1).texto).toContain('✅ Procesado (#88)');
    await servidorNuevo.cerrar();
    await entorno.bot.detener();
    fs.rmSync(entorno.dir, { recursive: true, force: true });
  });
});

describe('bot: cola persistente', () => {
  test('los pendientes sobreviven un reinicio simulado', async () => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'bot-persist-'));
    const servidor = await crearServidorMock();
    servidor.responder({ status: 500, body: {} });
    const cola = crearCola({ dir });
    const transporte1 = new MockTransporte();
    const bot1 = crearBot({
      config: { numero_autorizado: NUMERO, token: 't' },
      transporte: transporte1,
      appClient: crearAppClient({ baseUrl: servidor.url, token: 't' }),
      cola,
      logger: loggerSilencioso(),
    });
    await bot1.iniciar();
    const evento = eventoTexto();
    await transporte1.emitir(evento);
    expect(cola.contarPendientes()).toBe(1);
    await bot1.detener();

    servidor.responder({ status: 201, body: { captura_id: 99 } });
    const transporte2 = new MockTransporte();
    const bot2 = crearBot({
      config: { numero_autorizado: NUMERO, token: 't' },
      transporte: transporte2,
      appClient: crearAppClient({ baseUrl: servidor.url, token: 't' }),
      cola: crearCola({ dir }),
      logger: loggerSilencioso(),
    });
    await bot2.iniciar();
    await bot2.reintentarPendientes();
    expect(cola.contarPendientes()).toBe(0);
    expect(cola.contarEntregados()).toBe(1);
    expect(transporte2.enviados.at(-1).texto).toContain('✅ Procesado');

    await bot2.detener();
    await servidor.cerrar();
    fs.rmSync(dir, { recursive: true, force: true });
  });

  test('409 en reintento se trata como entregado sin duplicar', async () => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'bot-dup-'));
    servidor: {
      const servidor = await crearServidorMock();
      servidor.responder({ status: 500, body: {} });
      const cola = crearCola({ dir });
      const transporte = new MockTransporte();
      const bot = crearBot({
        config: { numero_autorizado: NUMERO, token: 't' },
        transporte,
        appClient: crearAppClient({ baseUrl: servidor.url, token: 't' }),
        cola,
        logger: loggerSilencioso(),
      });
      await bot.iniciar();
      await transporte.emitir(eventoTexto());
      expect(cola.contarPendientes()).toBe(1);

      servidor.responder({ status: 409, body: { captura_id: 1 } });
      await bot.reintentarPendientes();
      expect(cola.contarPendientes()).toBe(0);
      expect(cola.contarEntregados()).toBe(1);
      await bot.detener();
      await servidor.cerrar();
    }
    fs.rmSync(dir, { recursive: true, force: true });
  });

  test('el adjunto de una foto pendiente sobrevive el reinicio', async () => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'bot-media-'));
    const servidor = await crearServidorMock();
    servidor.responder({ status: 500, body: {} });
    const cola = crearCola({ dir });
    const transporte = new MockTransporte({
      media: { bytes: Buffer.from('BYTES-FOTO'), mime: 'image/jpeg', nombre: 'f.jpg' },
    });
    const bot = crearBot({
      config: { numero_autorizado: NUMERO, token: 't' },
      transporte,
      appClient: crearAppClient({ baseUrl: servidor.url, token: 't' }),
      cola,
      logger: loggerSilencioso(),
    });
    await bot.iniciar();
    await transporte.emitir(eventoTexto({ tipo: 'foto', texto: null }));
    expect(cola.contarPendientes()).toBe(1);

    servidor.responder({ status: 201, body: { captura_id: 44 } });
    await bot.reintentarPendientes();
    const peticion = servidor.peticiones.at(-1);
    expect(peticion.cuerpo.toString('latin1')).toContain('BYTES-FOTO');
    expect(cola.contarEntregados()).toBe(1);

    await bot.detener();
    await servidor.cerrar();
    fs.rmSync(dir, { recursive: true, force: true });
  });
});

describe('logger', () => {
  test('escribe formato, archivo diario y limpia mayores a 7 días', () => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'bot-log-'));
    const ahora = new Date('2026-11-24T10:00:00Z');
    const logger = crearLogger({ dir, ahora: () => ahora });
    fs.writeFileSync(
      path.join(dir, 'bot-2026-11-10.log'),
      'viejo\n',
    );
    logger.info('hola', 'prueba');
    const archivo = path.join(dir, 'bot-2026-11-24.log');
    expect(fs.readFileSync(archivo, 'utf8')).toContain(
      '[2026-11-24T10:00:00.000Z] [INFO] [prueba] hola',
    );
    expect(fs.existsSync(path.join(dir, 'bot-2026-11-10.log'))).toBe(false);
    fs.rmSync(dir, { recursive: true, force: true });
  });
});
