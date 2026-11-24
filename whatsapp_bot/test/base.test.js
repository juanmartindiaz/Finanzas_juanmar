import { describe, expect, test } from 'vitest';

import { debeReintentar, siguienteEspera } from '../lib/reconexion.js';
import { cargarConfig, guardarConfig } from '../lib/config.js';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

describe('reconexión', () => {
  test('backoff exponencial con tope de 60 s', () => {
    expect(siguienteEspera(1)).toBe(1000);
    expect(siguienteEspera(2)).toBe(2000);
    expect(siguienteEspera(3)).toBe(5000);
    expect(siguienteEspera(4)).toBe(10000);
    expect(siguienteEspera(5)).toBe(30000);
    expect(siguienteEspera(6)).toBe(60000);
    expect(siguienteEspera(20)).toBe(60000);
  });

  test('logout no reintenta; red sí', () => {
    expect(debeReintentar('logout')).toBe(false);
    expect(debeReintentar('red')).toBe(true);
  });
});

describe('configuración', () => {
  test('carga valores por defecto si no existe', () => {
    const config = cargarConfig(path.join(os.tmpdir(), 'no-existe-123.json'));
    expect(config.numero_autorizado).toBeNull();
    expect(config.puerto_app).toBe(8787);
  });

  test('guarda y relee el número autorizado', () => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'bot-config-'));
    const ruta = path.join(dir, 'config.json');
    guardarConfig(ruta, {
      numero_autorizado: '573001234567',
      token: 'abc',
      puerto_app: 8787,
    });
    const config = cargarConfig(ruta);
    expect(config.numero_autorizado).toBe('573001234567');
    expect(config.token).toBe('abc');
    fs.rmSync(dir, { recursive: true, force: true });
  });
});
