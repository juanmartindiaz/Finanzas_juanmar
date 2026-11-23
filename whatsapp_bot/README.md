# whatsapp_bot — Bot de WhatsApp (Node.js)

Componente **separado** de la app Flutter. En la versión final correrá en el mismo
teléfono Android, dentro de **Termux**, con un **número secundario** de WhatsApp.

## Estado actual: Fase 0 (esqueleto)

Este esqueleto **no** se conecta a WhatsApp, **no** instala Baileys y **no** habla
todavía con la app. Solo imprime un mensaje y sale.

```bash
cd whatsapp_bot
node index.js
```

Salida esperada:

```
Bot Gestor Finanzas — pendiente Fase 2
```

## Requisitos

- **Node.js 20 o superior** (en Windows ya está instalado Node 24; en Termux se
  instala en la Fase 5 con `pkg install nodejs`).
- No hay dependencias que instalar en esta fase (el `package.json` todavía no
  declara `baileys`).

## Qué hará a partir de la Fase 2

1. Conectarse a WhatsApp con **Baileys** usando el número secundario (sesión
   guardada en el teléfono, sin API oficial de Meta).
2. Recibir mensajes del número autorizado: **texto**, **audio** y **foto**.
3. Reenviarlos a la app por HTTP local (`POST /api/v1/inbox`, puerto 8787).
4. Consultar la bandeja de salida de la app (`GET /api/v1/outbox`) para enviar
   los reportes diarios (3 veces al día) y las confirmaciones.
5. Confirmar cada envío (`POST /api/v1/outbox/{id}/ack`).

El contrato completo, con ejemplos de request/response, está en
[`../docs/API_CONTRACT.md`](../docs/API_CONTRACT.md).

## Instalación en Termux (Fase 5, pendiente)

Se completará en la Fase 5:

```bash
pkg update && pkg upgrade
pkg install nodejs git
git clone <repositorio> gestor_finanzas
cd gestor_finanzas/whatsapp_bot
npm install
node index.js
```

> Pendiente: guía detallada con número secundario, arranque automático
> (`termux-services` o `boot`), batería y permisos de Termux.
