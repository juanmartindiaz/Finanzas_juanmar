#!/usr/bin/env node
'use strict';

/**
 * Bot Gestor Finanzas — esqueleto de la Fase 0.
 *
 * En esta fase el bot NO se conecta a WhatsApp ni instala Baileys: solo
 * confirma que el esqueleto del proyecto Node existe y arranca.
 *
 * En la Fase 2 este archivo hará:
 *   1. Conectarse a WhatsApp con Baileys usando un número secundario (Termux).
 *   2. Recibir mensajes de texto, audio y foto del número autorizado.
 *   3. Reenviarlos a la app por HTTP local: POST http://127.0.0.1:8787/api/v1/inbox
 *   4. Consultar los mensajes salientes de la app: GET http://127.0.0.1:8787/api/v1/outbox
 *   5. Enviarlos por WhatsApp y confirmarlos con POST .../outbox/{id}/ack
 *
 * El contrato completo está en ../docs/API_CONTRACT.md.
 */

const MENSAJE = 'Bot Gestor Finanzas — pendiente Fase 2';

console.log(MENSAJE);

module.exports = { MENSAJE };
