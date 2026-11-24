# Arquitectura de Gestor Finanzas

**Fase actual: 2 parte 1 (en implementación; este documento describe el estado al cerrar esta entrega).** En la Fase 1 quedaron implementados la base SQLite, las cuentas, las categorías y etiquetas, las transacciones manuales y el dashboard; en la **Fase 2 parte 1** se suman la **bandeja de capturas**, el **parser de texto en español** y el **servidor local `:8787`**. Siguen sin existir el bot real de WhatsApp (solo esqueleto), el OCR, la transcripción de audio y el servicio en primer plano.

**Para quién es este documento:** para el dueño del producto (que no programa) y para quien retome el código.

---

## 1. Resumen en tres frases

- Gestor Finanzas es una app Android de finanzas personales, de **uso personal** y **local-first**: los datos viven en el teléfono y la app funciona sin internet.
- Un **bot de WhatsApp** corre en el mismo teléfono y permite anotar gastos enviando un texto, un audio o una foto del recibo.
- La app es la dueña de los datos y de las reglas; el bot solo **transporta** mensajes entre WhatsApp y la app.

---

## 2. Los dos componentes

| | **App Flutter** | **Bot WhatsApp** |
|---|---|---|
| Qué es | La aplicación completa: pantallas, base de datos, cálculos, reportes, respaldos, cámara, micrófono | Un programa pequeño en Node.js que se conecta a WhatsApp |
| Dónde corre | Teléfono Android (APK final) o emulador | Teléfono Android, dentro de Termux, con un **número secundario** |
| Puerto local | **8787 (se implementa en la Fase 2)** | **8788 (pendiente Prompt 3)** |
| Guarda finanzas | **Sí** (SQLite) | No |
| Funciona sin el otro | Sí, con todas sus funciones manuales | No: sin app no tiene dónde entregar los mensajes |
| Tecnología | Flutter 3.50.1 / Dart 3.14, Riverpod, go_router, Drift | Node.js 24, Baileys (**aún no instalado**) |

**Regla de oro:** el bot nunca decide ni guarda un gasto. Recibe el mensaje, lo entrega a la app y la app responde qué hacer con él.

---

## 3. Vista general

```
+------------------------------- Telefono Android -------------------------------+
|                                                                                |
|   +--------------------------------+         +-------------------------------+  |
|   |  APP FLUTTER                   |         |  BOT WHATSAPP                 |  |
|   |  com.juanmartin.gestor_finanzas|         |  Node.js + Baileys (Termux)   |  |
|   |                                |  HTTP   |  numero secundario            |  |
|   |  Pantallas  (Riverpod)         |  local  |                               |  |
|   |  Reglas     (domain)           |<------->|  Recibe mensajes              |  |
|   |  Datos      (Drift/SQLite)     |  :8787  |  Los entrega a la app         |  |
|   |  Servidor local  ->  :8787     |  :8788  |  Envia respuestas al usuario  |  |
|   |                                |         |  Servidor local  ->  :8788    |  |
|   +---------------+----------------+         +---------------+---------------+  |
|                   |                                          |                  |
+-------------------|------------------------------------------|------------------+
                    | pantalla, camara, microfono             | WebSocket (Baileys)
                    v                                          v
              +-----------+                          +----------------------+
              |  Usuario  |                          | WhatsApp (servidores)|
              +-----------+                          +----------+-----------+
                                                                ^
                                                                | mensajes del
                                                                | usuario al bot
                                                          +-----+------+
                                                          |  Telefono  |
                                                          |  del dueno |
                                                          +------------+
```

Los dos procesos viven en el mismo teléfono y se hablan por `127.0.0.1` (loopback). No hay servidor en internet, no hay nube propia y no hay base de datos remota: el sistema completo funciona en modo avión salvo WhatsApp y Google Drive.

---

## 4. Qué vive dónde

| Responsabilidad | App Flutter | Bot WhatsApp | Documentos |
|---|---|---|---|
| Base de datos y reglas del dinero | **Sí** | No | [DATA_MODEL.md](DATA_MODEL.md) |
| Pantallas, formularios, gráficas | **Sí** | No | este documento, §13 |
| OCR de recibos | **Sí** (ML Kit, on-device) | No | [PHASES.md](PHASES.md), Fase 2 |
| Transcripción de audio | **Sí** (whisper_edge, dentro del APK) | No | [PHASES.md](PHASES.md), Fase 2 |
| Conexión con WhatsApp | No | **Sí** (Baileys, pendiente Prompt 3) | [API_CONTRACT.md](API_CONTRACT.md) |
| Recibir y encolar mensajes | Recibe por HTTP | **Sí** (pendiente Prompt 3) | [API_CONTRACT.md](API_CONTRACT.md) |
| Servidor HTTP de capturas | **Sí** (`:8787`, token, multipart) | No | [API_CONTRACT.md](API_CONTRACT.md) |
| Bandeja y revisión de capturas | **Sí** | No | [API_CONTRACT.md](API_CONTRACT.md) y [DECISIONS.md](DECISIONS.md), ADR-031 |
| Parser de texto en español | **Sí** (Dart puro en `domain/parsers/`) | No | [DECISIONS.md](DECISIONS.md), ADR-034 |
| Reportes diarios y PDF | **Sí** | Solo envía lo que la app produce | [PHASES.md](PHASES.md), Fase 4 |
| Respaldo en Google Drive | **Sí** | No | este documento, §10 |
| Credenciales y tokens | **Sí** (configuración) | Copia del token | [DECISIONS.md](DECISIONS.md), ADR-010 |
| Documentación | — | — | `docs/` |

---

## 5. Cómo se comunican

### 5.1 Reglas fijas

| Regla | Valor | Por qué |
|---|---|---|
| Dirección | `127.0.0.1` (loopback), nunca `0.0.0.0` | Ningún otro dispositivo de la red puede entrar |
| Transporte | HTTP/1.1 sin TLS | Es el mismo teléfono: no hay red que espiar |
| Autenticación | Cabecera `X-Bot-Token` en toda llamada salvo `GET /api/salud` | Evita que otra app del teléfono use el canal, sin pedir token para el chequeo de vida |
| Versión | Rutas de capturas sin prefijo de versión (contrato v2) | Un solo juego de rutas estables; la versión se documenta en el contrato, no en la URL |
| Formato | JSON UTF-8 | Legible y fácil de depurar en Termux |
| Servidores | App en **8787**, bot en **8788** | Cada uno escucha; ninguno se conecta a sí mismo |

### 5.2 Quién llama a quién

```
BOT/SIMULADOR --- POST /api/capturas/texto --> APP
BOT/SIMULADOR --- POST /api/capturas/foto  --> APP
BOT/SIMULADOR --- POST /api/audio          --> APP
BOT/SIMULADOR --- GET  /api/pendientes     --> APP
CUALQUIERA     --- GET  /api/salud         --> APP   (sin token)
APP            --- GET/POST :8788 ...      --> BOT   (pendiente Prompt 3)
```

El **bot empuja** lo que llega de WhatsApp; la cola de salida (`mensaje_salida`) y el sentido app → bot llegan en el **Prompt 3**, junto con el bot real.

El contrato completo, con ejemplos JSON, códigos de error y límites, está en [API_CONTRACT.md](API_CONTRACT.md).

### 5.3 El token

- Se genera en el **primer arranque**: cadena aleatoria de 64 caracteres hexadecimales, guardada en la app (tabla `configuracion`, clave `bot_token`).
- Se muestra, copia y regenera en Ajustes → Canal bot; al regenerarlo, el bot copiado deja de funcionar hasta actualizarlo.
- El bot lo recibe en su archivo de configuración local (`.env` en `whatsapp_bot/`, nunca subido a Git).
- Comparación en **tiempo constante** para no filtrar información por tiempo de respuesta.
- Si falta o no coincide: `401` con `{"error": {"codigo": "NO_AUTORIZADO", ...}}`.

---

## 6. Modo mock (simulador dentro de la app)

En el emulador de Android puede correr la app, pero **no** hay bot ni Termux. En la Fase 2, `MOCK_BOT` ya **no** simula el bot en memoria: es un **simulador dentro de la app** que llama por **HTTP real** a `127.0.0.1:8787` con el token, como lo haría el bot (ADR-032).

| Situación | `MOCK_BOT` | Qué pasa |
|---|---|---|
| Emulador, desarrollo | `true` | La app abre su servidor local y el simulador le envía capturas reales por HTTP, con el mismo token que usaría el bot |
| Teléfono real | `false` | La app habla con el bot verdadero por `127.0.0.1:8788` (Prompt 3) |

El modo mock se activa por configuración (tabla `configuracion`, clave `bot_modo_mock`) y es **visible siempre** en pantalla, para que nadie confunda un dato simulado con uno real. Su comportamiento exacto está en [API_CONTRACT.md](API_CONTRACT.md), §10.

El mock **sin red** del bot (dentro del proceso Node) se definirá en el **Prompt 3**.

---

## 7. Flujos principales

### 7.1 Captura de un gasto por texto

```
Usuario       Simulador / Bot          App (8787)                  SQLite
   |                 |                     |                          |
   | "gasté 18.500   |                     |                          |
   |  en mercado" -->|-- POST /api/  ---->|                          |
   |                 |   capturas/texto    |-- crea captura --------->|
   |                 |   {message_id,...}  |   origen bot, listo      |
   |                 |<-- 201 {captura_id,|                          |
   |                 |        estado} -----|                          |
   | abre la bandeja y revisa la propuesta |                          |
   |-------------------------------------->|                          |
   | confirma (cuenta, categoría, fecha)   |-- crea transacción ----->|
   |<-- saldo actualizado -----------------|                          |
```

Detalle importante: el bot (o el simulador) **no** adivina la categoría ni el monto final. La app
crea una **captura en estado `listo`** con una propuesta; el usuario la revisa, la corrige y
confirma o descarta. Un gasto mal clasificado es peor que uno que espera dos minutos
([DECISIONS.md](DECISIONS.md), ADR-031). El flujo detallado está en §7.5.

### 7.2 Captura por audio (Fase 2 parte 1: solo almacenar)

1. El bot o el simulador envía el audio a `POST /api/audio` (`multipart/form-data`).
2. La app lo guarda en `capturas/` y crea la captura con `canal = 'audio'`, `estado = 'pendiente'`.
3. **No hay transcripción todavía** (llega en la Fase 2.5): el usuario abre la captura, escucha el
   archivo y completa el formulario a mano.
4. Si el archivo no se puede guardar, la captura queda en `error` con `error_detalle`.

### 7.3 Captura por foto de un recibo (Fase 2 parte 1: solo almacenar)

1. El bot o el simulador envía la imagen a `POST /api/capturas/foto` (`multipart/form-data`).
2. La app la guarda en `capturas/` (nombre único por `message_id`) y crea la captura con
   `canal = 'foto'`, `estado = 'listo'` y `adjunto_path`.
3. **No hay OCR todavía** (llega en la Fase 2.4): el formulario se abre vacío con la foto visible
   para que el usuario escriba monto, categoría y fecha.
4. El hash/recibo y el enlace `recibo.transaccion_id` se activan con el OCR en 2.4.

### 7.4 Reporte saliente (Fase 4; cola pendiente del Prompt 3)

El diseño de cola de salida (`mensaje_salida`, `GET /outbox` cada 30 s, `POST /outbox/{id}/ack`)
**no está implementado** en la Fase 2 parte 1. Se construirá junto con el bot real (Prompt 3) y
los reportes diarios (Fase 4). Mientras tanto, la app no tiene forma de pedirle envíos al bot.

### 7.5 Captura por texto (simulador o bot)

1. Llega un mensaje (de WhatsApp o del simulador) y se envía a `POST /api/capturas/texto`.
2. La app crea la captura con `origen = 'bot'` y `estado = 'listo'`.
3. El parser propone tipo, monto, categoría, etiquetas, cuenta y confianza.
4. El usuario revisa en `/bandeja/:id`.
5. Al confirmar se crea la transacción con `origen = 'bot'`.
6. La captura queda `confirmado` con `transaccion_id`.

### 7.6 Captura por foto o audio

El archivo se guarda en la carpeta privada `capturas/`; la foto queda `listo` sin OCR y el audio queda `pendiente` sin transcripción. Ninguno crea una transacción hasta que el usuario la complete a mano. El OCR y la transcripción llegan en las fases 2.4 y 2.5.

---

## 8. Arranque y ciclo de vida

### 8.1 App

| Momento | Qué ocurre |
|---|---|
| Primer arranque | Crea la base SQLite y aplica las migraciones de Drift; el bloqueo con PIN/biometría llega en la Fase 5 |
| Apertura normal | Dashboard; el servidor HTTP arranca y escucha en `:8787` |
| Primer plano | Todas las funciones disponibles y el servidor local activo |
| Segundo plano | Android puede pausar el proceso. El servidor local puede dejar de responder hasta que la app vuelva |
| Cierre forzado | Los datos ya están guardados y el servidor se apaga; al reabrir, nada se pierde |

**Decisión de diseño:** el servidor HTTP arranca con la app y se detiene al cerrarla. **No hay servicio en primer plano todavía** (Fase 2.6): si Android mata la app, el bot no puede entregar mensajes hasta que se vuelva a abrir y debe reintentar. El puerto es configurable y, si está ocupado, Ajustes lo avisa y la app sigue funcionando **sin servidor**.

### 8.2 Bot en Termux

```
Abrir Termux
  -> cd ~/gestor_finanzas/whatsapp_bot
  -> npm start                  (ejecuta: node index.js)
  -> el bot carga la sesion de Baileys guardada en disco
  -> pide un codigo de vinculacion una sola vez (WhatsApp -> Dispositivos vinculados)
  -> queda escuchando mensajes y consultando la cola de la app
```

| Tema | Cómo se resuelve |
|---|---|
| Que no se duerma | `termux-wake-lock` mientras el bot corre |
| Que arranque solo tras reiniciar | Termux:Boot (se configura en la Fase 5) |
| Que Android no lo mate | Quitar la optimización de batería para Termux |
| Sesión de WhatsApp | Se guarda en la carpeta del bot; si se borra, hay que vincular de nuevo |
| Número | Secundario, dedicado solo al bot; el número principal no se usa |

---

## 9. Dónde se guardan los datos

| Dato | Dónde | Formato | Se respalda |
|---|---|---|---|
| Finanzas (cuentas, transacciones, etc.) | Base SQLite privada de la app, archivo `gestor_finanzas.sqlite` en `getApplicationDocumentsDirectory()`, resuelto por una única función `rutaBaseDatos()` | SQLite (Drift) | Sí |
| Fotos de recibos | Carpeta privada de la app, `recibos/<hash>.<ext>` | JPEG/PNG | Sí (copia) |
| Capturas recibidas | Carpeta privada de la app, `capturas/` (ruta relativa en `adjunto_path`) | JPEG/PNG/OGG | Sí (futuro) |
| Copia de seguridad previa a migrar | `gestor_finanzas.sqlite.backup`, en la misma carpeta de la base | SQLite | No |
| Audios temporales | Carpeta temporal; se borran tras transcribir | OGG/M4A | No |
| Token del bot | Tabla `configuracion` de la app + `.env` del bot | Texto | Sí (viaja en el respaldo) |
| Sesión de WhatsApp | Carpeta `whatsapp_bot/` del teléfono (Termux) | Archivos de Baileys | No (se revincula) |
| Respaldos | Google Drive, carpeta oculta de datos de la app | JSON + SQLite + recibos | — |

El archivo SQLite exacto es `getApplicationDocumentsDirectory()/gestor_finanzas.sqlite` y se resuelve con una única función `rutaBaseDatos()`; la apertura de Drift y el respaldo usan esa misma función, para que nunca haya dos rutas distintas.

La carpeta privada de la app **no** es accesible desde otras apps ni desde el explorador de archivos, pero sí desde una copia de seguridad del sistema o desde un teléfono con root. Ese riesgo está aceptado explícitamente (ver [DECISIONS.md](DECISIONS.md), ADR-007).

---

## 10. Almacenamiento y respaldo

Antes de abrir la base se copia el archivo SQLite a `.backup` en la misma carpeta (ruta única `rutaBaseDatos()`); si la migración falla se restaura y se avisa. Esto aplica a la migración v1 → v2 del **2026-11-24**.

**Qué se respalda:** la base de datos completa (copia del archivo o un JSON con todas las tablas), las fotos de recibos y un archivo `manifiesto.json` con versión del esquema, fecha y conteos. **Sin cifrado**, por decisión del dueño: los archivos deben poder abrirse y revisarse con cualquier herramienta.

**Dónde:** Google Drive, **App Data Folder** (carpeta oculta que no ocupa la cuota visible del usuario y no aparece en "Mi unidad").

**Cuándo:** manual desde Ajustes y automático una vez al día, cuando haya conexión y la app esté abierta.

**Restauración:** se descarga el respaldo, se verifica el manifiesto y la versión del esquema, se reemplaza la base local y se reaplican migraciones si el respaldo es más viejo. Si el respaldo es más nuevo que la app instalada, se avisa y no se toca nada.

Lo que **no** se respalda: la sesión de WhatsApp del bot y los audios temporales. Perderlos no pierde información financiera.

---

## 11. Seguridad aceptada

Estas decisiones son del dueño del producto y se documentan aquí para que nadie las "arregle" por sorpresa. El detalle y los motivos están en [DECISIONS.md](DECISIONS.md).

| Tema | Decisión | Riesgo asumido |
|---|---|---|
| Cifrado de datos | **No hay cifrado** de la base ni de los recibos | Quien tenga acceso físico o root al teléfono puede leer todo |
| Ocultar montos | **No se ocultan** montos: no hay "modo discreto" | Quien mire la pantalla ve las cifras |
| Respaldo | Google Drive sin cifrar, archivos legibles | Quien entre a la cuenta de Google puede leer los respaldos |
| Bloqueo de la app | Biometría con PIN de respaldo (`local_auth`) | Es una comodidad, no una barrera criptográfica |
| Canal app-bot | Token compartido + solo loopback | Otra app maliciosa con el token podría hablar con la app |
| Canal local de capturas | Token + loopback | Otra app con el token podría hablar con la app |
| Adjuntos de captura | Se guardan en la carpeta privada sin cifrar | Quien tenga root o una copia del sistema puede verlos |
| API de WhatsApp | Baileys, sin API oficial | Riesgo de bloqueo del número secundario |

Nadie más que el dueño usa el teléfono ni la app; por eso el esfuerzo se pone en que **no se pierdan datos**, no en esconderlos.

---

## 12. Restricciones del entorno

| Restricción | Efecto | Mitigación |
|---|---|---|
| El emulador no tiene WhatsApp | No se puede probar el canal real en desarrollo | Se prueba con el simulador de la app (`MOCK_BOT`, HTTP real a `127.0.0.1:8787`) |
| Bot y app comparten CPU y batería | Un reporte o una descarga pueden tardar | Trabajos cortos, sin bucles pesados, reintentos suaves |
| App cerrada → servidor apagado (sin *foreground service* aún; Fase 2.6) | Android puede matar el proceso y el bot no puede entregar hasta que la app se reabra | Servicio en primer plano con notificación (Fase 2.6); el bot reintenta |
| Termux y el "phantom process killer" (Android 12+) | El bot puede morir solo | `termux-wake-lock`, batería sin restricciones, guía en Fase 5 |
| WhatsApp no permite dos sesiones del mismo número | El bot necesita número secundario | Número aparte, documentado en Fase 5 |
| Baileys no es la API oficial | El número puede ser bloqueado | Número secundario dedicado, sin envíos masivos, solo el dueño escribe |
| Sin Android Studio | No hay emulador "de fábrica" ni inspector gráfico | SDK por línea de comandos (`android sdk`) + `avdmanager` (Fase 0, ya hecho) |
| Un solo desarrollador | Todo debe quedar documentado | Estos 5 documentos + README raíz |

**La app sigue funcionando 100 % sin internet.** El permiso `INTERNET` de Android es necesario para abrir sockets de loopback (`127.0.0.1`) y para el cliente HTTP del simulador; en la Fase 2 no hay ninguna llamada de salida a internet ni dependencia de servidores externos.

---

## 13. Capas internas de la app

La app se organiza en capas para que el dinero y las reglas no dependan de la pantalla:

| Carpeta | Qué contiene | Regla |
|---|---|---|
| `app/lib/core/` | Transversal: `config/` (constantes y versión), `router/` (go_router), `theme/` (colores y tipografía), `utils/` (formato de moneda y fechas, validaciones) | No conoce la base de datos ni las pantallas |
| `app/lib/domain/` | `entities/` (modelos puros), `parsers/` (parser de texto puro) y `usecases/` (cálculos de saldo, presupuesto, metas, conversión) | Dart puro, sin Flutter ni SQLite; **aquí vive la verdad del dinero** |
| `app/lib/data/` | `database/` (tablas Drift, migraciones, semilla), `repositories/` (acceso a datos, incluido el repositorio de capturas), `api/` (cliente del contrato del bot, Fase 2) y `providers.dart` (Riverpod) | Único lugar que escribe en SQLite o llama al bot |
| `app/lib/features/` | Una carpeta por función: `dashboard`, `accounts`, `transactions` y `settings` (implementadas en la Fase 1); `bandeja` (bandeja, captura manual y revisión, Fase 2.1); `budgets`, `debts`, `goals`, `reports` (fases 3–4) | No contiene fórmulas financieras: las pide a `domain` |
| `app/lib/services/` | Integraciones con el teléfono o la red: `whatsapp_bridge` (servidor local, token, multipart y almacenamiento de adjuntos), `ocr`, `audio`, `notifications`, `backup`, `exchange_rates` | Aíslan lo que depende de hardware, permisos o internet |
| `app/lib/main.dart` | Arranque: `MaterialApp.router`, tema, router | Lo más delgado posible |

**Regla de dependencias:** `features` → `domain` ← `data`, y `services` pueden usar `data` o `domain` pero nunca al revés. `domain` no importa nada de Flutter.

---

## 14. Mapa real de carpetas del repo

```
C:\.Proyectos\App finanzas\
├── README.md                     # puerta de entrada del proyecto
├── .gitignore                    # excluye build, .dart_tool, .env y llaves
├── docs\                         # esta documentacion (5 documentos)
│   ├── ARCHITECTURE.md           # este archivo
│   ├── API_CONTRACT.md           # contrato app <-> bot
│   ├── DATA_MODEL.md             # entidades, reglas e indices
│   ├── PHASES.md                 # plan de 6 fases
│   └── DECISIONS.md              # registro de decisiones
├── app\                          # APK Flutter (Fase 0: esqueleto)
│   ├── pubspec.yaml              # dependencias y version
│   ├── analysis_options.yaml     # reglas de estilo
│   ├── android\                  # com.juanmartin.gestor_finanzas, SDK 36 / minSdk 24
│   ├── assets\                   # iconos y, en la Fase 2, el modelo de voz
│   ├── test\                     # 68 pruebas: dinero, saldos, semilla, multimoneda, validación, parser, migración, HTTP y bandeja
│   └── lib\
│       ├── main.dart             # arranque: router, tema, providers globales
│       ├── core\
│       │   ├── config\           # AppConfig: nombre, version, fase, paquete
│       │   ├── router\           # go_router: rutas y guardas
│       │   ├── theme\            # tema claro y oscuro
│       │   └── utils\            # formato de moneda/fecha, validaciones
│       ├── data\
│       │   ├── api\              # cliente HTTP del contrato (Prompt 3)
│       │   ├── database\         # tablas Drift, migraciones, respaldo previo y semilla
│       │   ├── repositories\     # acceso a datos por entidad
│       │   │   └── capturas_repository.dart  # repositorio de capturas (Fase 2)
│       │   └── providers.dart    # proveedores Riverpod
│       ├── domain\
│       │   ├── entities\         # modelos puros (cuenta, transaccion, meta...)
│       │   ├── parsers\          # parser de texto en español (Fase 2)
│       │   └── usecases\         # calculos: saldo, restante, avance, conversion
│       ├── features\
│       │   ├── dashboard\        # inicio: saldos, consolidado y últimos movimientos (Fase 1)
│       │   ├── accounts\         # cuentas (Fase 1)
│       │   ├── transactions\     # movimientos manuales y filtros (Fase 1)
│       │   ├── bandeja\          # bandeja, captura manual y revisión de capturas (Fase 2)
│       │   ├── budgets\          # presupuestos (Fase 3)
│       │   ├── debts\            # deudas y creditos (Fase 3)
│       │   ├── goals\            # metas y aportes (Fase 3)
│       │   ├── reports\          # graficas y PDF (Fase 4)
│       │   └── settings\         # ajustes, categorias, etiquetas, monedas (Fase 1)
│       └── services\
│           ├── whatsapp_bridge\  # servidor local :8787, token, multipart y adjuntos (Fase 2)
│           ├── ocr\              # ML Kit y almacenamiento de recibos (Fase 2)
│           ├── audio\            # grabacion y transcripcion (Fase 2)
│           ├── notifications\    # avisos locales (Fase 3)
│           ├── backup\           # Google Drive (Fase 4)
│           └── exchange_rates\   # tasas diarias (Fase 4)
└── whatsapp_bot\                 # bot Node.js (esqueleto hasta el Prompt 3)
    ├── README.md                 # que hace, como correrlo y que falta
    ├── package.json              # scripts; Baileys entra en el Prompt 3
    ├── index.js                  # arranque; hoy solo imprime un mensaje
    └── (auth\, .env y src\ se agregan en el Prompt 3)
```

Las carpetas `build/`, `.dart_tool/` y `.idea/` las genera la herramienta y no se documentan ni se suben al repositorio. El andamiaje existe desde la Fase 0; la Fase 1 lo llenó con la app financiera y la Fase 2 parte 1 agrega `domain/parsers/`, `features/bandeja/`, `services/whatsapp_bridge/` (servidor local) y el repositorio de capturas.

---

## 15. Qué no existe todavía al cerrar la Fase 2 parte 1

- **Bot de WhatsApp**: solo el esqueleto en `whatsapp_bot/`; Baileys **no está instalado** (llega en el Prompt 3).
- **Servidor del bot (`:8788`)**: no existe. El servidor local de la app (`:8787`) sí.
- **OCR y transcripción de audio**: las fotos y los audios se guardan, pero sin leer ni transcribir (fases 2.4 y 2.5).
- **Servicio en primer plano**: no existe (Fase 2.6), así que el servidor se apaga con la app.
- **Cola de salida (`mensaje_salida`)**: no existe; llega en el Prompt 3 con el bot real.
- **Reportes, PDF, notificaciones y Google Drive**: sus paquetes se instalan cuando llegue su fase.
- **Presupuestos, deudas, créditos, metas y recurrentes**: solo están documentados en [DATA_MODEL.md](DATA_MODEL.md).
- **PIN/biometría**: pospuesto a la Fase 5.
- **Conversión automática de monedas**: las tasas son manuales; la actualización diaria llega en la Fase 4.

Lo que sí queda disponible al cerrar esta entrega: base SQLite con semilla, CRUD de cuentas/categorías/subcategorías/etiquetas, transacciones manuales (ingreso, gasto y transferencia con dos montos), filtros, dashboard con multimoneda y tasas manuales, la **bandeja de capturas** con su revisión, el **parser de texto en español**, el **servidor local `:8787`** con token e idempotencia, el **simulador de bot** y pruebas automatizadas. Ver [PHASES.md](PHASES.md).

---

## 16. Documentos relacionados

| Si quieres… | Lee |
|---|---|
| Ver campos, tipos y reglas de cada tabla | [DATA_MODEL.md](DATA_MODEL.md) |
| Ver rutas, JSON y errores del canal app-bot | [API_CONTRACT.md](API_CONTRACT.md) |
| Saber en qué orden se construye y cómo se sabe que terminó | [PHASES.md](PHASES.md) |
| Entender por qué se eligió cada tecnología | [DECISIONS.md](DECISIONS.md) |
| Instalar el proyecto desde cero | `README.md` de la raíz |
