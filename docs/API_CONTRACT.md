# Contrato de API — App ↔ Bot (v2 · capturas)

**Estado: Fase 2, parte 1 (2026-11-24).** La app expone el servidor local de capturas en
`127.0.0.1:8787` en esta misma entrega; el **bot real de WhatsApp escribe en el Prompt 3**. Las
rutas de cola de salida (`/outbox`, `/ack`) y el servidor del bot en `:8788` quedan documentadas
como **pendientes** y no se implementan todavía.

Este contrato reemplaza al diseño `/api/v1/inbox` de la Fase 0, que **nunca se implementó**.
Las rutas actuales son las aprobadas en el Prompt 2 (Opción A: rutas exactas, sin prefijo de
versión en la ruta). Ver §13 para la política de cambios incompatibles.

Los dos procesos corren en el mismo teléfono Android: la **app Flutter** y el **bot Node.js**
de WhatsApp. La app es la dueña de los datos y de las reglas; el bot solo transporta mensajes.

---

## 1. Principios

| Principio | Regla |
|---|---|
| Solo loopback | Se escucha en `127.0.0.1`; jamás en `0.0.0.0` ni en una IP de la red |
| La app manda | El bot no decide montos ni categorías: entrega el mensaje y la app propone; **el usuario confirma** |
| Nada automático | Una captura **nunca** crea una transacción por sí sola ([DECISIONS.md](DECISIONS.md), ADR-031) |
| Todo autenticado | `X-Bot-Token` obligatorio en cada llamada, salvo `GET /api/salud` |
| JSON siempre | Cuerpo y respuesta en JSON UTF-8, salvo los archivos, que van en `multipart/form-data` |
| Errores uniformes | Un único formato de error, siempre con `codigo` y `mensaje` |
| Idempotente | Reenviar el mismo `message_id` no duplica capturas |
| Sin estado compartido | El bot puede reiniciarse sin perder datos de finanzas |
| Sin internet | Todo ocurre en el teléfono; el contrato no requiere red de salida |

---

## 2. Direcciones y puertos

| Servidor | Escucha en | Quién le habla | Estado |
|---|---|---|---|
| App Flutter | `http://127.0.0.1:8787` (configurable en Ajustes) | El bot / el simulador | **Implementado en Fase 2.1–2.2** |
| Bot Node.js | `http://127.0.0.1:8788` | La app | Pendiente (Prompt 3) |

El puerto de la app se guarda en `configuracion` (clave `bot_puerto_app`) y vale **8787** por
defecto. Si está ocupado, la app lo informa en Ajustes y sigue funcionando sin servidor (el
resto de la app no depende de él).

---

## 3. Autenticación

Cada petición protegida lleva:

```http
POST /api/capturas/texto HTTP/1.1
Host: 127.0.0.1:8787
Content-Type: application/json
X-Bot-Token: 7f3c9a1e5b2d48c6a0f1e9d7c3b5a8f2
```

| Aspecto | Definición |
|---|---|
| Cabecera | `X-Bot-Token` |
| Generación | La app genera una cadena aleatoria de 64 caracteres hexadecimales en el primer arranque (clave `bot_token`) |
| Dónde se ve | Ajustes → **Canal bot**: se muestra, se copia y se puede regenerar |
| Comparación | **Tiempo constante** (no comparar con `==`) |
| Falta la cabecera / token incorrecto | `401` `NO_AUTORIZADO` (mismo mensaje, a propósito) |
| Rotación | Al regenerar, el bot copiado deja de funcionar hasta que el usuario actualice el suyo |
| Transporte | El token **no** viaja en la URL ni en el cuerpo |

Respuesta de error:

```json
{
  "error": {
    "codigo": "NO_AUTORIZADO",
    "mensaje": "Falta el token o no coincide."
  }
}
```

**Única excepción:** `GET /api/salud` no exige token. No revela datos: solo si el servidor está
vivo y la versión de la app.

---

## 4. Formato de errores

Todo error usa exactamente esta forma (igual que en el contrato anterior):

```json
{
  "error": {
    "codigo": "PAYLOAD_INVALIDO",
    "mensaje": "El campo 'texto' es obligatorio.",
    "campo": "texto"
  }
}
```

`campo` es opcional y solo aparece cuando el problema es un campo concreto.

| Código | HTTP | Cuándo | Qué debe hacer el cliente |
|---|---|---|---|
| `NO_AUTORIZADO` | 401 | Token ausente o incorrecto | Corregir la configuración; no reintentar en bucle |
| `PAYLOAD_INVALIDO` | 400 | JSON mal formado, campo obligatorio ausente o valor fuera de rango | Corregir; reintentar no sirve |
| `DEMASIADO_GRANDE` | 413 | Archivo sobre 8 MB o cuerpo sobre el límite (§6) | Reducir el archivo |
| `NO_ENCONTRADO` | 404 | Ruta inexistente o `id` de captura inexistente | Verificar la ruta |
| `CONFLICTO` | 409 | `message_id` ya usado (duplicado) | **No reintentar**: la captura ya existe; usar el `captura_id` devuelto |
| `NO_DISPONIBLE` | 503 | La app está arrancando o la base no está lista | Reintentar con espera creciente |
| `ERROR_INTERNO` | 500 | Fallo inesperado | Reintentar una vez; si persiste, reportar |

Regla de reintentos (lado bot): esperar 2 s, 5 s, 15 s, 30 s, 60 s; **nunca** reintentar
`400`, `401`, `404`, `409` ni `413`.

### 4.1 Respuesta de duplicado

Además del error estándar, el `409` incluye el id de la captura ya existente para que el bot
pueda responder al usuario sin adivinar (decisión D3):

```json
{
  "error": {
    "codigo": "CONFLICTO",
    "mensaje": "El message_id ya fue procesado."
  },
  "captura_id": 41
}
```

---

## 5. Convenciones de datos

| Dato | Formato | Ejemplo |
|---|---|---|
| Fechas de calendario | `"YYYY-MM-DD"` | `"2026-11-24"` |
| Instantes | entero, **epoch en milisegundos** | `1795451760000` |
| Dinero | entero, **centavos** (nunca decimal) | `1850000` = $18.500 COP |
| Moneda | ISO 4217, 3 letras mayúsculas | `"COP"`, `"USD"` |
| Booleanos | `true` / `false` | `true` |
| Ids | entero positivo | `41` |
| `canal` | `texto`, `audio`, `foto` o `app` | `"foto"` |
| `origen` | `mock`, `bot` o `manual` | `"bot"` |
| `estado` de captura | `pendiente`, `procesando`, `listo`, `confirmado`, `descartado`, `error` | `"listo"` |
| Texto libre | UTF-8, máximo 4.000 caracteres | `"Almuerzo 18.500"` |

Los nombres de campos van en español; los identificadores de código, en inglés o neutro.

---

## 6. Límites

| Límite | Valor | Motivo |
|---|---|---|
| Tamaño máximo por archivo (foto o audio) | **8 MB** | Cabe un recibo o una nota de voz sin llenar la memoria |
| Tamaño máximo del cuerpo | 8 MB + cabeceras | Es el mismo límite, medido antes de procesar |
| Texto del mensaje | 4.000 caracteres | Más que eso no es un gasto |
| Imagen | JPEG/PNG/WebP | Lo que manda WhatsApp |
| Audio | OGG/Opus, M4A, MP3, AMR | Notas de voz típicas |
| Tiempo de espera por petición | 15 s | Antes de eso, papelera y reintento |
| Timeout del servidor | 30 s por petición | Evita peticiones colgadas |

El límite se valida **antes** de escribir el archivo: si llegan 12 MB, se responde `413` y no se
guarda nada.

---

## 7. Idempotencia

El bot identifica cada mensaje con `message_id` (el identificador de WhatsApp). Se guarda en
`captura_entrante.message_id_externo`, con **índice único parcial** (solo entre no nulos).

| Caso | Comportamiento |
|---|---|
| `message_id` nunca visto | Se crea la captura y se responde `201` con `{captura_id, estado}` |
| `message_id` repetido | Se responde `409 CONFLICTO` con el `captura_id` existente; **no se crea otra captura** |
| Sin `message_id` | `400 PAYLOAD_INVALIDO` (obligatorio en las rutas del bot) |
| Captura creada desde la app (manual) | No lleva `message_id` (es `NULL`); la unicidad parcial lo permite |

Reenviar el mismo mensaje es seguro: el bot puede reintentar tras un corte sin duplicar nada.

---

## 8. Endpoints que expone la APP (`127.0.0.1:8787`)

### 8.1 `GET /api/salud` — sin token

Sirve para saber si el servidor está vivo. No revela datos.

**Respuesta 200:**

```json
{ "ok": true, "version": "0.3.0" }
```

| Campo | Tipo | Significado |
|---|---|---|
| `ok` | booleano | Siempre `true` si el servidor responde |
| `version` | texto | Versión de la app que corre el servidor |

### 8.2 `POST /api/capturas/texto` — con token

Recibe un mensaje de texto (escrito por el usuario en WhatsApp y reenviado por el bot, o
generado por el simulador interno). Crea la captura, corre el **parser en español** y, si
obtiene **tipo, monto y cuenta**, registra la transacción automáticamente (sin revisión). Si
falta algún dato, devuelve `faltantes` para que el bot pregunte por chat.

**Petición:**

```json
{
  "message_id": "wamid.HBgMNTczMDAxMjM0NTY3FQIAEhgg",
  "texto": "gasté 18.500 en mercado",
  "canal": "texto",
  "timestamp": 1795451700000
}
```

| Campo | Tipo | Obligatorio | Regla |
|---|---|---|---|
| `message_id` | texto | Sí | 1–200 caracteres; llave de idempotencia |
| `texto` | texto | Sí | 1–4.000 caracteres |
| `canal` | texto | Sí | `texto` o `audio` (texto transcrito en una fase posterior) |
| `timestamp` | entero | Sí | Epoch ms; no puede ser futuro por más de 5 minutos |

**Respuesta 201 (registro automático):**

```json
{
  "captura_id": 41,
  "estado": "confirmado",
  "transaccion_id": 88,
  "resumen": "Gasto · $ 18.500 · Alimentación",
  "faltantes": [],
  "cuenta_nombre": "Efectivo"
}
```

**Respuesta 201 (faltan datos):**

```json
{
  "captura_id": 42,
  "estado": "listo",
  "resumen": "Gasto · $ 20.000 · Otros",
  "faltantes": ["cuenta"]
}
```

La captura queda con `origen = 'bot'`, `canal = 'texto'` y `propuesta_json` con tipo, monto,
categoría/subcategoría, etiquetas y cuenta. `faltantes` puede incluir `tipo`, `monto` y
`cuenta`; la categoría faltante se propone como `Otros` y no bloquea el registro. Para
completar los datos faltantes se usa `POST /api/capturas/{id}/confirmar`.

**Errores:** `400` (falta un campo, texto vacío, timestamp inválido), `401`, `409` (duplicado),
`413` si el cuerpo excede el límite.

### 8.3 `POST /api/capturas/foto` — con token, `multipart/form-data`

Recibe una foto del recibo y ejecuta **OCR offline con ML Kit**. Si el parser de recibos
encuentra el monto, la transacción se registra automáticamente; si no, responde con
`faltantes: ["monto"]` para que el bot pregunte.

**Campos del formulario:**

| Campo | Tipo | Obligatorio | Regla |
|---|---|---|---|
| `message_id` | texto | Sí | Idempotencia |
| `timestamp` | entero | Sí | Epoch ms (fecha de recepción) |
| `archivo` | archivo | Sí | JPEG/PNG/WebP, ≤ 8 MB |

**Respuesta 201 con monto (auto-registro):**

```json
{
  "captura_id": 42,
  "estado": "confirmado",
  "transaccion_id": 90,
  "monto_centavos": 4500000,
  "comercio": "SUPERMERCADO EXITO",
  "resumen": "SUPERMERCADO EXITO · $ 45.000",
  "faltantes": [],
  "incompleta": false
}
```

**Respuesta 201 sin monto:** `{ "captura_id": 43, "estado": "listo", "comercio": "…",
"resumen": "…", "faltantes": ["monto"] }`. El bot pregunta el monto y luego usa
`POST /api/capturas/{id}/confirmar` con `monto_centavos`.

La captura queda `canal = 'foto'`, `origen = 'bot'`, `estado = 'listo'`, `adjunto_path` con la
ruta relativa dentro de la carpeta privada `capturas/` y `propuesta_json` vacía (el OCR llega
en la Fase 2.4).

**Errores:** `400` (falta `message_id` o archivo), `401`, `413` (archivo > 8 MB),
`409` (duplicado).

### 8.4 `POST /api/audio` — con token, `multipart/form-data`

Recibe una nota de voz. En esta fase **no hay transcripción**: el archivo se guarda y la
captura queda `pendiente`.

**Campos del formulario:**

| Campo | Tipo | Obligatorio | Regla |
|---|---|---|---|
| `message_id` | texto | Sí | Idempotencia |
| `timestamp` | entero | Sí | Epoch ms |
| `archivo` | archivo | Sí | OGG/Opus, M4A, MP3, AMR, ≤ 8 MB |

**Respuesta 201:**

```json
{ "captura_id": 43, "estado": "pendiente" }
```

La captura queda `canal = 'audio'`, `origen = 'bot'`, `adjunto_path` con la ruta del archivo y
sin propuesta (la transcripción offline llega en la Fase 2.5).

**Errores:** `400`, `401`, `413`, `409`.

### 8.5 `GET /api/pendientes` — con token

Conteo de capturas que el usuario todavía no atendió, para que el bot decida si avisar por
WhatsApp.

**Respuesta 200:**

```json
{
  "pendientes": 2,
  "listos": 1,
  "total": 3
}
```

`pendientes` = capturas en estado `pendiente` o `procesando`; `listos` = en `listo`; `total` =
suma de ambos. No incluye confirmadas ni descartadas.

### 8.6 `GET /api/cuentas` — con token

Devuelve las cuentas activas para que el bot pregunte cuál usar cuando el mensaje no la
menciona.

```json
{
  "cuentas": [
    { "id": 1, "nombre": "Efectivo", "moneda": "COP" },
    { "id": 2, "nombre": "Cuenta de ahorros", "moneda": "COP" }
  ]
}
```

### 8.7 `POST /api/capturas/{id}/confirmar` — con token

Completa una captura con los datos que el usuario respondió por chat y la registra. Es
idempotente a nivel de captura: si ya está confirmada responde `409`.

**Petición** (todos los campos son opcionales; se combinan con la propuesta existente):

```json
{
  "cuenta_id": 1,
  "monto_centavos": 1850000,
  "tipo": "gasto"
}
```

**Respuesta 200:**

```json
{
  "captura_id": 42,
  "estado": "confirmado",
  "transaccion_id": 89,
  "resumen": "Gasto · $ 18.500 · Alimentación"
}
```

**Errores:** `400 FALTAN_DATOS` (incluye `faltantes` en la raíz), `401`, `404` y `409` si ya
fue confirmada.

### 8.8 Rutas del contrato anterior (retiradas)

| Ruta anterior | Estado |
|---|---|
| `GET /api/v1/health` | **Retirada.** Sustituida por `GET /api/salud` |
| `POST /api/v1/inbox` | **Retirada.** Sustituida por `/api/capturas/texto`, `/api/capturas/foto` y `/api/audio` |
| `GET /api/v1/config` | **Retirada.** La configuración viaja en el prompt/configuración del bot (Prompt 3) |
| `GET /api/v1/outbox` y `POST /api/v1/outbox/{id}/ack` | **Pendientes (Prompt 3)** |
| `POST /api/v1/send` (servidor del bot) | **Pendiente (Prompt 3)** |

Ninguna de estas rutas llegó a implementarse en la Fase 0 ni existían datos que migrar.

---

## 9. Endpoints del BOT (`127.0.0.1:8788`) — pendientes del Prompt 3

Se documentan aquí para no perder el diseño, pero **no están implementados**:

| Ruta | Para qué |
|---|---|
| `GET /salud` | Estado de la sesión de WhatsApp |
| `POST /api/enviar` | Envío inmediato (confirmaciones y reportes) |
| `GET /api/estado` | Diagnóstico de la sesión |

Las rutas exactas y sus cuerpos se cerrarán en el Prompt 3, cuando se implemente Baileys. No
forman parte de la entrega de la Fase 2 parte 1.

---

## 10. Modo mock (`MOCK_BOT`)

En la Fase 2 el modo mock **no simula el bot en memoria**: es un **simulador dentro de la app**
que hace una **llamada HTTP real** al servidor local, con el token guardado, exactamente como
lo haría el bot (decisión D6 / ADR-032). Así se prueba el servidor de verdad desde el emulador.

| Aspecto | Comportamiento |
|---|---|
| Activación | Ajustes → Canal bot → `MOCK_BOT` (clave `bot_modo_mock`; `1` por defecto en desarrollo) |
| Pantalla | Ajustes → Avanzado → **Simulador de bot** (solo visible con `MOCK_BOT` activo) |
| Mensaje de texto | Pide un texto (y opcionalmente un `message_id`), envía `POST /api/capturas/texto` |
| Imagen | Elige un archivo del teléfono y envía `POST /api/capturas/foto` |
| Audio | Elige un archivo del teléfono y envía `POST /api/audio` |
| Token | Usa el token real de la app |
| Aviso | La pantalla muestra siempre "Bot simulado — usa el servidor local de la app" |
| Internet | **No hay red de salida**: todo va a `127.0.0.1` |
| Al terminar | Navega a `/bandeja` para ver la captura recién creada |

El modo mock del **bot** (sin red, dentro del proceso Node) se definirá en el Prompt 3.

---

## 11. Secuencia completa: captura por texto y confirmación

```
1  Usuario escribe en WhatsApp "gasté 18.500 en mercado" (o en el simulador de la app)
2  Bot (o simulador) -> app: POST /api/capturas/texto
       {"message_id":"wamid...","texto":"gasté 18.500 en mercado",
        "canal":"texto","timestamp":1795451700000}
3  App: valida token, tamaño e idempotencia; crea captura 41 (origen bot, estado listo)
4  App: corre el parser y guarda propuesta_json:
       {"tipo":"gasto","monto_centavos":1850000,"categoria":"Alimentación",
        "confianza":"alta","faltantes":[]}
5  App -> bot: 201 {"captura_id":41,"estado":"listo"}
6  Usuario abre la app: ve el badge de la bandeja (41) y entra a revisar
7  Revisión: formulario de transacción prellenado con la propuesta; el usuario corrige si hace falta
8  Usuario confirma: se crea la transacción (gasto $18.500, Alimentación, origen bot)
9  App: captura pasa a "confirmado", se guarda transaccion_id y procesada_at
```

Variantes:

| Caso | Cambios |
|---|---|
| Foto | Paso 2 usa `/api/capturas/foto` (multipart); la captura queda `listo` sin propuesta, pendiente de revisión manual (OCR después) |
| Audio | Paso 2 usa `/api/audio` (multipart); la captura queda `pendiente` (transcripción después) |
| Parser incompleto | Paso 4 deja `confianza: baja` y `faltantes`; la UI resalta la captura y abre el formulario vacío con el texto crudo visible |
| Duplicado | Paso 3 responde `409` con `captura_id`; no se crea nada |
| Token inválido | `401`; el bot no insiste |
| App cerrada | El servidor no está escuchando: el cliente recibe error de conexión y reintenta cuando la app vuelva (ver §12) |

---

## 12. Ciclo de vida del servidor

- El servidor arranca cuando la app se abre y queda protegido por un **servicio en primer plano**
  con notificación persistente (ADR-042). Sigue escuchando con la app en segundo plano e incluso
  después de cerrarla desde la pantalla de recientes.
- Si el usuario **fuerza la detención** desde Ajustes de Android, el proceso muere y el servidor
  se apaga hasta que vuelva a abrir la app. Lo mismo tras reiniciar el teléfono: hay que abrir la
  app una vez para que arranque el servicio.
- Mientras el servidor esté vivo, el bot entrega en el momento; si no, encola y reintenta cada
  30 s.
- El estado del servidor (escuchando / error / puerto ocupado) se muestra en Ajustes → Canal bot.

Documentado en [ARCHITECTURE.md](ARCHITECTURE.md) y [DECISIONS.md](DECISIONS.md) (ADR-042,
que reemplaza la limitación de ADR-036).

---

## 13. Versionado

- La versión del contrato es **2** (Fase 2, capturas). Se identifica en este documento.
- Las rutas aprobadas **no llevan prefijo de versión** (decisión del dueño, Opción A): son
  `/api/salud`, `/api/capturas/...`, `/api/audio` y `/api/pendientes`.
- Cambios **compatibles** (agregar un campo opcional o un valor nuevo a un enum que el receptor
  pueda ignorar) no cambian la versión.
- Cambios **incompatibles** publican rutas `/api/v2/...` y mantienen las actuales como alias
  mientras el bot se actualiza; las rutas sin versión quedan congeladas tal como están aquí.
- El diseño `/api/v1/inbox` de la Fase 0 **nunca se implementó** y queda retirado.

---

## 14. Tabla resumen de endpoints

| # | Método | Ruta | Servidor | Token | Idempotente | Estado |
|---|---|---|---|---|---|---|
| 1 | GET | `/api/salud` | App :8787 | No | Sí | Implementado (Fase 2.2) |
| 2 | POST | `/api/capturas/texto` | App :8787 | Sí | Sí (`message_id`) | Implementado (Fase 2.2) |
| 3 | POST | `/api/capturas/foto` | App :8787 | Sí | Sí (`message_id`) | Implementado (Fase 2.2) |
| 4 | POST | `/api/audio` | App :8787 | Sí | Sí (`message_id`) | Implementado (Fase 2.2) |
| 5 | GET | `/api/pendientes` | App :8787 | Sí | Sí | Implementado (Fase 2.2) |
| 6 | GET | `/api/cuentas` | App :8787 | Sí | Sí | Implementado (registro directo) |
| 7 | POST | `/api/capturas/{id}/confirmar` | App :8787 | Sí | Por captura | Implementado (registro directo) |
| 8 | GET | `/salud` | Bot :8788 | No | Sí | Pendiente (Fase 4) |
| 9 | POST | `/api/enviar` | Bot :8788 | Sí | No | Pendiente (Fase 4) |
| 10 | GET | `/api/estado` | Bot :8788 | Sí | Sí | Pendiente (Fase 4) |

---

## 15. Qué falta para cerrar el canal

| Pieza | Fase | Estado |
|---|---|---|
| Servidor HTTP de la app en `:8787` con token, límites e idempotencia | 2.2 | **Implementado** |
| Tabla `captura_entrante` y bandeja de revisión | 2.1 | **Implementado** |
| Parser de texto en español | 2.1 | **Implementado** |
| Simulador de bot dentro de la app | 2.2 | **Implementado** |
| Bot real con Baileys en Termux | Prompt 3 | **Implementado** |
| Registro directo desde el bot y preguntas por datos faltantes | Prompt 3 | **Implementado** |
| Cola de salida y acuses (`mensaje_salida`) | Fase 4 | No existe |
| OCR de recibos | Fase 2.4 | No existe |
| Transcripción de audio offline | Fase 2.5 | No existe |
| Servicio en primer plano | Fase 2.6 | No existe |
| Reportes por WhatsApp | Fase 4 | No existe |
