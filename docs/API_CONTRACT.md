# Contrato de API — App ↔ Bot (v1)

**Fase 0: nada de esto está implementado.** No hay servidores escuchando, ni rutas, ni token, ni modo mock. Este documento es el acuerdo que se implementará en la **Fase 2** (captura) y se ampliará en la **Fase 4** (reportes). Sirve para que las dos partes se construyan por separado sin sorpresas.

Los dos procesos corren en el mismo teléfono Android: la **app Flutter** y el **bot Node.js** de WhatsApp. Este contrato fija cómo se hablan.

---

## 1. Principios

| Principio | Regla |
|---|---|
| Solo loopback | Se escucha en `127.0.0.1`; jamás en `0.0.0.0` ni en una IP de la red |
| La app manda | El bot no decide montos ni categorías: entrega, avisa y espera |
| Todo autenticado | `X-Bot-Token` obligatorio en cada llamada, salvo `GET /health` en ambos lados (solo informa estado, no expone datos) |
| JSON siempre | Cuerpo y respuesta en JSON UTF-8, `Content-Type: application/json` |
| Errores uniformes | Un único formato de error, siempre con `codigo` y `mensaje` |
| Idempotente | Reenviar el mismo mensaje no duplica capturas |
| Versionado | Todas las rutas cuelgan de `/api/v1` |
| Sin estado compartido | El bot puede reiniciarse en cualquier momento sin perder datos de finanzas |

---

## 2. Direcciones y puertos

| Servidor | Escucha en | Quién le habla | Para qué |
|---|---|---|---|
| App Flutter | `http://127.0.0.1:8787` | El bot | Entregar mensajes, recoger la cola de salida |
| Bot Node.js | `http://127.0.0.1:8788` | La app | Saber estado de WhatsApp, enviar mensajes, configurar horarios |

Ambos puertos son **fijos** (no se negocian). Si un puerto está ocupado, el proceso que arranca segundo falla con un mensaje claro en lugar de cambiar de puerto en silencio: dos puertos fijos hacen que la depuración sea predecible.

---

## 3. Autenticación

Cada petición lleva:

```http
POST /api/v1/inbox HTTP/1.1
Host: 127.0.0.1:8787
Content-Type: application/json
X-Bot-Token: 7f3c9a1e5b2d48c6a0f1e9d7c3b5a8f2
```

| Aspecto | Definición |
|---|---|
| Cabecera | `X-Bot-Token` |
| Valor | Cadena aleatoria de al menos 32 caracteres |
| Comparación | **Tiempo constante** (no comparar con `==`; no salir antes al primer byte distinto) |
| Falta la cabecera | `401` `NO_AUTORIZADO` |
| Token incorrecto | `401` `NO_AUTORIZADO` (mismo mensaje que el caso anterior, a propósito) |
| Token vacío o muy corto | `401` `NO_AUTORIZADO` |
| Rotación | El usuario puede regenerar el token en Ajustes; la app y el bot se actualizan a la vez |

Respuesta de error de autenticación:

```json
{
  "error": {
    "codigo": "NO_AUTORIZADO",
    "mensaje": "Falta el token o no coincide."
  }
}
```

El token **no** viaja en la URL ni en el cuerpo, para que no quede en registros de texto.

**Única excepción:** `GET /health` en los dos servidores no exige token. Devuelve solo si el proceso está vivo y listo, sin nombres, montos ni configuración. Todo lo demás —incluido `GET /api/v1/config`— responde `401` sin token válido.

---

## 4. Formato de errores

Todo error usa exactamente esta forma:

```json
{
  "error": {
    "codigo": "PAYLOAD_INVALIDO",
    "mensaje": "El campo 'tipo' debe ser texto, audio o imagen.",
    "campo": "tipo"
  }
}
```

`campo` es opcional y solo aparece cuando el problema es un campo concreto.

| Código | HTTP | Cuándo | Qué debe hacer el cliente |
|---|---|---|---|
| `NO_AUTORIZADO` | 401 | Token ausente o incorrecto | Revisar configuración; no reintentar en bucle |
| `PAYLOAD_INVALIDO` | 400 | JSON mal formado o campo obligatorio ausente/tipo erróneo | Corregir la petición; reintentar no sirve |
| `DEMASIADO_GRANDE` | 413 | Cuerpo sobre el límite (§6) | Reducir imagen/audio o trocear |
| `NO_ENCONTRADO` | 404 | Ruta o `id` inexistente | Verificar la ruta y el id |
| `CONFLICTO` | 409 | Estado incompatible (p. ej. `ack` doble sobre un mensaje ya entregado) | Leer el mensaje y decidir |
| `NO_DISPONIBLE` | 503 | App cerrada, WhatsApp desconectado o base ocupada | Reintentar con espera creciente |
| `LIMITE_EXCEDIDO` | 429 | Demasiadas peticiones en poco tiempo | Esperar y reintentar |
| `ERROR_INTERNO` | 500 | Fallo inesperado | Reintentar una vez; si persiste, reportar |

Regla de reintentos (lado bot): esperar 2 s, 5 s, 15 s, 30 s, 60 s; nunca reintentar `400`, `401`, `404` ni `413`.

---

## 5. Convenciones de datos

| Dato | Formato | Ejemplo |
|---|---|---|
| Fechas de calendario | `"YYYY-MM-DD"` | `"2026-11-23"` |
| Instantes | entero, **epoch en milisegundos** | `1795451760000` |
| Dinero | entero, **centavos** (nunca decimal) | `1850000` = $18.500 COP |
| Moneda | ISO 4217, 3 letras mayúsculas | `"COP"`, `"USD"` |
| Booleanos | `true` / `false` | `true` |
| Ids | entero positivo | `41` |
| Texto libre | UTF-8, sin límite interno distinto al de §6 | `"Almuerzo 18.500"` |

Los nombres de campos van en español; los identificadores de código (clases, funciones, rutas internas) en inglés o neutro.

---

## 6. Límites

| Límite | Valor | Motivo |
|---|---|---|
| Tamaño máximo del cuerpo | 8 MB | Un audio o una foto de WhatsApp caben sin llenar la memoria del teléfono |
| Texto de mensaje | 4.000 caracteres | Más que eso no es un gasto ni un reporte |
| Imagen | hasta 4 MB tras decodificar base64; JPEG/PNG/WebP | Lo que manda WhatsApp |
| Audio | hasta 6 MB; OGG/Opus, M4A, MP3 | Notas de voz típicas |
| Tiempo de espera por petición | 15 s (app y bot) | Antes de eso se responde `NO_DISPONIBLE` |
| Consultas del bot a `/outbox` | cada 30 s (configurable) | Equilibrio entre rapidez y batería |
| Tamaño de `/outbox` | máximo 20 mensajes por respuesta | Evita respuestas gigantes |
| Reintentos automáticos | 5 con espera creciente | Suficiente para que el usuario no intervenga |

El límite de cuerpo se valida **antes** de decodificar base64; si el cliente envía 12 MB, se responde `413` sin intentar procesarlo.

---

## 7. Idempotencia

El bot identifica cada mensaje entrante con `id_mensaje` (el identificador de WhatsApp).

| Caso | Comportamiento |
|---|---|
| `id_mensaje` nunca visto | Se crea una captura nueva y se responde `202` con `estado: "pendiente_revision"` |
| `id_mensaje` repetido, misma captura | Se responde `200` con **el mismo** `id_captura` y el mismo `estado`; no se crea nada |
| `id_mensaje` repetido de un mensaje ignorado | Se responde `200` con el mismo `estado: "ignorado"` |
| `id_mensaje` repetido con contenido distinto | Se responde `409` `CONFLICTO` (el id ya está usado por otro contenido) |

Así el bot puede reintentar sin miedo cuando se corta la red local o la app está dormida. La app guarda el `id_mensaje` junto a la captura (ver [DATA_MODEL.md](DATA_MODEL.md)).

---

## 8. Endpoints que expone la APP (`127.0.0.1:8787`)

### 8.1 `GET /api/v1/health`

No requiere token, pero no revela nada sensible. Sirve para saber si vale la pena seguir.

**Respuesta 200:**

```json
{
  "estado": "ok",
  "listo": true,
  "version_app": "0.1.0",
  "api": "v1",
  "base_datos": "ok",
  "modo_mock": false,
  "hora_servidor": 1795451760000
}
```

| Campo | Tipo | Significado |
|---|---|---|
| `estado` | texto | `ok`, `iniciando` o `error` |
| `listo` | booleano | `true` solo si la base de datos abrió y la app está desbloqueada |
| `version_app` | texto | Versión del APK |
| `api` | texto | Siempre `"v1"` |
| `base_datos` | texto | `ok` o `error` |
| `modo_mock` | booleano | Si el bot simulado está activo |
| `hora_servidor` | entero | Epoch ms, para detectar relojes desfasados |

Si la app está bloqueada con PIN, `listo` es `false` y las demás rutas responden `503 NO_DISPONIBLE`.

### 8.2 `GET /api/v1/config`

Devuelve lo que el bot necesita saber. **No** devuelve el token (el bot ya lo tiene).

**Respuesta 200:**

```json
{
  "version": 3,
  "numero_autorizado": "573001234567",
  "destinatarios": ["573001234567"],
  "horarios_reporte": ["07:30", "13:00", "20:30"],
  "modo_mock": false,
  "zona_horaria": "America/Bogota",
  "moneda_base": "COP"
}
```

| Campo | Tipo | Significado |
|---|---|---|
| `version` | entero | Sube cada vez que cambia la configuración; el bot la compara |
| `numero_autorizado` | texto | Único número cuyos mensajes se aceptan |
| `destinatarios` | lista | A quién se envían reportes |
| `horarios_reporte` | lista | Horas locales `"HH:MM"` |
| `modo_mock` | booleano | Si la app simula el bot |
| `zona_horaria` | texto | Zona IANA del teléfono |
| `moneda_base` | texto | Siempre `COP` en esta versión |

### 8.3 `POST /api/v1/inbox`

El bot entrega un mensaje entrante. Es la ruta más importante del contrato.

**Petición (texto):**

```json
{
  "id_mensaje": "wamid.HBgMNTczMDAxMjM0NTY3FQIAEhgg",
  "remitente": "573001234567",
  "tipo": "texto",
  "timestamp": 1795451700000,
  "texto": "Almuerzo 18.500 efectivo",
  "archivo_base64": null,
  "mime": null
}
```

**Petición (audio):**

```json
{
  "id_mensaje": "wamid.HBgMNTczMDAxMjM0NTY3FQIAEhgh",
  "remitente": "573001234567",
  "tipo": "audio",
  "timestamp": 1795451720000,
  "texto": null,
  "archivo_base64": "T2dnUwACAAAAAAAAAAA...",
  "mime": "audio/ogg"
}
```

**Petición (imagen):**

```json
{
  "id_mensaje": "wamid.HBgMNTczMDAxMjM0NTY3FQIAEhgi",
  "remitente": "573001234567",
  "tipo": "imagen",
  "timestamp": 1795451740000,
  "texto": null,
  "archivo_base64": "/9j/4AAQSkZJRgABAQ...",
  "mime": "image/jpeg"
}
```

| Campo | Tipo | Obligatorio | Regla |
|---|---|---|---|
| `id_mensaje` | texto | Sí | Único; llave de idempotencia |
| `remitente` | texto | Sí | Solo dígitos; si no es `numero_autorizado` → `estado: "ignorado"` |
| `tipo` | texto | Sí | `texto`, `audio` o `imagen` |
| `timestamp` | entero | Sí | Epoch ms; no puede ser futuro por más de 5 minutos |
| `texto` | texto o null | Solo si `tipo: "texto"` | 1–4.000 caracteres |
| `archivo_base64` | texto o null | Solo si `tipo` es audio/imagen | Base64 sin prefijo `data:` |
| `mime` | texto o null | Solo si hay archivo | `audio/ogg`, `image/jpeg`, etc. |

**Respuesta 202 (captura creada):**

```json
{
  "recibido": true,
  "id_captura": 41,
  "estado": "pendiente_revision"
}
```

**Respuesta 200 (duplicado o remitente no autorizado):**

```json
{
  "recibido": true,
  "id_captura": 41,
  "estado": "pendiente_revision"
}
```

```json
{
  "recibido": true,
  "id_captura": null,
  "estado": "ignorado"
}
```

El bot **no** espera a que el usuario confirme: responde con un acuse corto y la app avisa cuando el gasto está registrado.

### 8.4 `GET /api/v1/outbox`

El bot consulta los mensajes que la app quiere enviar.

**Respuesta 200:**

```json
{
  "mensajes": [
    {
      "id": 12,
      "tipo": "texto",
      "destinatario": "573001234567",
      "texto": "Hoy gastaste $84.300. Restante de Alimentación: $215.700.",
      "adjunto_base64": null,
      "creado_en": 1795451600000
    },
    {
      "id": 13,
      "tipo": "texto",
      "destinatario": "573001234567",
      "texto": "Listo, registré tu gasto de $18.500 en Alimentación.",
      "adjunto_base64": null,
      "creado_en": 1795451765000
    }
  ]
}
```

| Campo | Tipo | Significado |
|---|---|---|
| `id` | entero | Id del mensaje en la cola; se usa para el `ack` |
| `tipo` | texto | `texto`, `audio` o `imagen` |
| `destinatario` | texto | Número en formato internacional sin `+` |
| `texto` | texto | Contenido o pie de foto. Puede ir vacío solo si hay adjunto |
| `adjunto_base64` | texto o null | Solo para audio/imagen |
| `creado_en` | entero | Epoch ms |

Los mensajes **no** se borran al entregarse: cambian de estado, para poder auditar qué se envió.

### 8.5 `POST /api/v1/outbox/{id}/ack`

El bot confirma el resultado del envío.

**Petición (éxito):**

```json
{ "estado": "enviado" }
```

**Petición (fallo):**

```json
{
  "estado": "error",
  "error": "WhatsApp no esta conectado (socket cerrado)"
}
```

**Respuesta 200:**

```json
{ "ok": true, "id": 12, "estado": "enviado" }
```

`estado` solo admite `enviado` o `error`; cualquier otro valor devuelve `400 PAYLOAD_INVALIDO`. Un segundo `ack` sobre el mismo id con el mismo estado devuelve `200` (idempotente); con estado distinto devuelve `409 CONFLICTO`.

---

## 9. Endpoints que expone el BOT (`127.0.0.1:8788`)

### 9.1 `GET /health`

**Respuesta 200:**

```json
{
  "conectado": true,
  "numero": "573009876543",
  "ultima_conexion": 1795451000000
}
```

| Campo | Tipo | Significado |
|---|---|---|
| `conectado` | booleano | Si la sesión de WhatsApp está activa |
| `numero` | texto o null | Número del bot, si la sesión lo conoce |
| `ultima_conexion` | entero o null | Epoch ms de la última conexión correcta |

### 9.2 `GET /api/v1/status`

Estado detallado de la sesión, útil para la pantalla de diagnóstico de la app.

```json
{
  "estado": "conectado",
  "conectado": true,
  "numero": "573009876543",
  "desde": 1795400000000,
  "ultima_conexion": 1795451000000,
  "mensajes_recibidos": 132,
  "mensajes_enviados": 87,
  "version": "0.1.0",
  "modo_mock": false
}
```

`estado` puede ser: `conectado`, `desconectado`, `esperando_codigo`, `cerrado` (sesión inválida, hay que revincular) o `mock`.

### 9.3 `POST /api/v1/send`

La app pide un envío inmediato (pantalla de prueba o aviso urgente). El uso normal de reportes va por la cola `/outbox` para no bloquear la app.

**Petición:**

```json
{
  "tipo": "texto",
  "destinatario": "573001234567",
  "texto": "Prueba de conexion desde Gestor Finanzas.",
  "adjunto_base64": null,
  "mime": null
}
```

**Respuesta 202:**

```json
{ "id_envio": 88, "estado": "en_cola" }
```

`estado` es `enviado` si WhatsApp respondió de inmediato, o `en_cola` si quedó pendiente por falta de conexión.

### 9.4 `POST /api/v1/config`

La app empuja la configuración al bot (horarios, destinatarios, modo silencioso).

**Petición:**

```json
{
  "destinatarios": ["573001234567"],
  "horarios_reporte": ["07:30", "13:00", "20:30"],
  "modo_silencioso": true,
  "zona_horaria": "America/Bogota"
}
```

**Respuesta 200:**

```json
{ "ok": true, "version": 4 }
```

La app llama a esta ruta en cada arranque si su `configuracion.version` es mayor que la que el bot reportó por última vez. `modo_silencioso: true` significa que el bot **no** responde a mensajes que no sean del número autorizado ni inicia conversaciones.

---

## 10. Modo mock (`MOCK_BOT=true`)

Con `MOCK_BOT=true` la app **no abre sockets**: simula al bot en memoria. Sirve para el emulador, donde no hay Termux ni WhatsApp.

| Situación | Comportamiento simulado |
|---|---|
| `GET /health` simulado | `{"conectado": true, "numero": "573000000000", "ultima_conexion": <ahora>}` |
| `GET /api/v1/status` simulado | `estado: "mock"`, contadores inventados y estables |
| `POST /api/v1/send` simulado | Responde `{id_envio: n, estado: "enviado"}` y guarda el mensaje en una bandeja de salida visible en la app |
| `POST /api/v1/config` simulado | Responde `{ok: true, version: n}` y guarda localmente |
| Mensaje entrante simulado | Un botón "simular mensaje" en Ajustes crea un `inbox` como si viniera de WhatsApp |
| Errores | Se pueden forzar desde Ajustes (`fallo de red`, `401`, `413`) para probar los caminos tristes |

Reglas del mock:

- **Cero red:** no se llama a `127.0.0.1:8788`, no se importa Baileys.
- **Mismos tipos y formas JSON** que el contrato real: si el mock funciona, el real también.
- La interfaz muestra siempre un aviso visible: "Bot simulado — los mensajes no salen del teléfono".
- `MOCK_BOT` se define en el entorno del bot y en la app por configuración (clave `bot_modo_mock`). Si los dos están activos, manda la app.

---

## 11. Secuencia completa: captura por WhatsApp y confirmación

```
1  Usuario escribe a WhatsApp: "Taxi 9.800"
2  WhatsApp -> bot: mensaje entrante (wamid...)
3  Bot -> app: POST /api/v1/inbox
      {"id_mensaje":"wamid.HBgM...","remitente":"573001234567",
       "tipo":"texto","timestamp":1795451700000,
       "texto":"Taxi 9.800","archivo_base64":null,"mime":null}
4  App: valida token, remitente autorizado, tamano; crea captura id 41
5  App -> bot: 202 {"recibido":true,"id_captura":41,"estado":"pendiente_revision"}
6  App: encola acuse de recibo en su outbox (id 12)
7  Bot: GET /api/v1/outbox  -> recibe id 12
8  Bot -> WhatsApp -> usuario: "Anotado. Confirma en la app para guardarlo."
9  Bot -> app: POST /api/v1/outbox/12/ack {"estado":"enviado"}
10 Usuario abre la app, revisa la captura 41, elige cuenta y categoria, confirma
11 App: crea transaccion (gasto, 980000 centavos, cuenta Efectivo, Alimentacion/Transporte)
12 App: encola aviso "Registrado: Taxi $9.800" (id 13)  ->  bot lo envia en <=30 s
13 App: marca la captura como confirmada y la enlaza a la transaccion
```

Variantes:

| Tipo | Cambios en la secuencia |
|---|---|
| Audio | Paso 3 con `tipo: "audio"` y `archivo_base64`; la app transcribe con whisper_edge antes del paso 10 |
| Imagen | Paso 3 con `tipo: "imagen"`; la app corre OCR, guarda el recibo y propone monto/fecha |
| Remitente no autorizado | Paso 4 responde `estado: "ignorado"`; no se crea captura ni acuse |
| Token incorrecto | Paso 4 responde `401 NO_AUTORIZADO`; el bot registra el fallo y no insiste |
| App bloqueada | Paso 4 responde `503 NO_DISPONIBLE`; el bot reintenta con espera creciente |

---

## 12. Tabla resumen de endpoints

| # | Método | Ruta | Servidor | Quién llama | Token | Idempotente | Fase |
|---|---|---|---|---|---|---|---|
| 1 | GET | `/api/v1/health` | App :8787 | Bot | No | Sí | 2 |
| 2 | GET | `/api/v1/config` | App :8787 | Bot | Sí | Sí | 2 |
| 3 | POST | `/api/v1/inbox` | App :8787 | Bot | Sí | Sí (`id_mensaje`) | 2 |
| 4 | GET | `/api/v1/outbox` | App :8787 | Bot | Sí | Sí | 2 |
| 5 | POST | `/api/v1/outbox/{id}/ack` | App :8787 | Bot | Sí | Sí | 2 |
| 6 | GET | `/health` | Bot :8788 | App | No | Sí | 2 |
| 7 | GET | `/api/v1/status` | Bot :8788 | App | Sí | Sí | 2 |
| 8 | POST | `/api/v1/send` | Bot :8788 | App | Sí | No (cada llamada es un envío) | 2 |
| 9 | POST | `/api/v1/config` | Bot :8788 | App | Sí | Sí (versión) | 2 |

Los reportes de la Fase 4 no agregan rutas: usan la misma cola `/outbox` con mensajes más largos y adjuntos PDF.

---

## 13. Versionado

- La versión vive en la ruta (`/api/v1`), no en una cabecera.
- Cambios compatibles (agregar un campo opcional, agregar un valor nuevo a un enum) **no** cambian la versión: el receptor debe ignorar campos desconocidos.
- Cambios incompatibles (quitar un campo, cambiar un tipo, cambiar el significado de un código) crean `/api/v2` y las dos versiones conviven mientras el usuario actualiza el bot.
- La app y el bot comparan en el arranque `health.version_app`/`status.version`; si hay salto de versión mayor, la app muestra un aviso de "actualiza el bot".
- El contrato lo implementa primero la app (servidor de prueba) y después el bot; nunca al revés.

---

## 14. Qué falta para que esto exista

| Pieza | Fase | Estado |
|---|---|---|
| Servidor HTTP de la app en `:8787` | 2 | No existe |
| Servidor HTTP del bot en `:8788` | 2 | No existe |
| Generación y comparación del token | 2 | No existe |
| Tablas `captura_entrante` (entrada) y `mensaje_salida` (cola y acuses) | 2 | No existe |
| Baileys conectado a WhatsApp | 2 | No instalado |
| Modo mock con bandeja simulada | 2 | No existe |
| Reportes por `/outbox` y PDF | 4 | No existe |

Cuando una pieza exista, se actualiza esta tabla y se anota la fecha. El detalle por fase está en [PHASES.md](PHASES.md); el modelo de datos que hay detrás, en [DATA_MODEL.md](DATA_MODEL.md).
