# Arquitectura de Gestor Finanzas

**Fase actual: 1 (MVP local, completada).** Este documento describe el sistema **objetivo**: lo que se construirá en las fases 2 a 5, además de lo que ya existe. En la Fase 1 ya están implementados la base SQLite, las cuentas, las categorías y etiquetas, las transacciones manuales y el dashboard; todavía **no** existen el bot de WhatsApp (solo esqueleto), el OCR, el audio ni los respaldos.

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
| Puerto local | **8787** | **8788** |
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
| Conexión con WhatsApp | No | **Sí** (Baileys) | [API_CONTRACT.md](API_CONTRACT.md) |
| Recibir y encolar mensajes | Recibe por HTTP | **Sí** | [API_CONTRACT.md](API_CONTRACT.md) |
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
| Autenticación | Cabecera `X-Bot-Token` en **toda** llamada | Evita que otra app del teléfono use el canal |
| Versión | Prefijo `/api/v1` | Permite cambiar el contrato sin romper el bot |
| Formato | JSON UTF-8 | Legible y fácil de depurar en Termux |
| Servidores | App en **8787**, bot en **8788** | Cada uno escucha; ninguno se conecta a sí mismo |

### 5.2 Quién llama a quién

```
BOT  --- POST /api/v1/inbox ---------------->  APP     (entrega mensaje entrante)
BOT  --- GET  /api/v1/outbox --------------->  APP     (pide mensajes por enviar)
BOT  --- POST /api/v1/outbox/{id}/ack ------>  APP     (avisa si se envió o falló)
APP  --- GET  /health ---------------------->  BOT     (esta vivo?)
APP  --- GET  /api/v1/status --------------->  BOT     (sesion de WhatsApp)
APP  --- POST /api/v1/send ----------------->  BOT     (envio directo, pantalla de prueba)
APP  --- POST /api/v1/config --------------->  BOT     (horarios y destinatarios)
```

El **bot empuja** lo que llega de WhatsApp, y **el bot consulta** lo que la app quiere enviar (patrón outbox). Así la app nunca se queda esperando a WhatsApp: escribe el mensaje en su cola y sigue.

El contrato completo, con ejemplos JSON, códigos de error y límites, está en [API_CONTRACT.md](API_CONTRACT.md).

### 5.3 El token

- Se genera una vez (cadena aleatoria larga) y se guarda en la app, en la tabla `configuracion` (ver [DATA_MODEL.md](DATA_MODEL.md)).
- El bot lo recibe en su archivo de configuración local (`.env` en `whatsapp_bot/`, nunca subido a Git).
- Comparación en **tiempo constante** para no filtrar información por tiempo de respuesta.
- Si falta o no coincide: `401` con `{"error": {"codigo": "NO_AUTORIZADO", ...}}`.

---

## 6. Modo mock (emulador sin bot)

En el emulador de Android puede correr la app, pero **no** hay bot ni Termux. Para poder trabajar toda la Fase 2 sin bot, la app tiene un interruptor:

| Situación | `MOCK_BOT` | Qué pasa |
|---|---|---|
| Emulador, desarrollo | `true` | La app simula el bot: inventa mensajes, horarios y respuestas; **no abre ningún socket** |
| Teléfono real | `false` | La app habla con el bot verdadero por `127.0.0.1:8788` |

El modo mock se activa por configuración (tabla `configuracion`, clave `bot_modo_mock`) y siempre es **visible en pantalla**, para que nadie confunda un dato simulado con uno real. Su comportamiento exacto está en [API_CONTRACT.md](API_CONTRACT.md), §10.

---

## 7. Flujos principales

### 7.1 Captura de un gasto por texto

```
Usuario        WhatsApp        Bot (8788)              App (8787)             SQLite
   |              |                |                       |                     |
   |  "Almuerzo   |                |                       |                     |
   |   18.500" -->|                |                       |                     |
   |              |-- Baileys ---->|                       |                     |
   |              |                |-- POST /inbox ------->|                     |
   |              |                |   {id_mensaje,...}    |-- guarda captura -->|
   |              |                |                       |   estado pendiente  |
   |              |                |<-- 202 {id_captura}---|                     |
   |              |<-- confirmacion|                       |                     |
   |<-- "Registre $18.500" --------|                       |                     |
   |              |                |                       |                     |
   |  abre la app y revisa la captura pendiente            |                     |
   |------------------------------------------------------>|                     |
   |  confirma (cuenta, categoria, fecha)                  |-- crea transaccion ->|
   |<-- saldo actualizado ---------------------------------|                     |
```

Detalle importante: el bot **no** adivina la categoría ni el monto final. La app crea una **captura pendiente de revisión**; el usuario confirma o descarta. Esto es deliberado: un gasto mal clasificado es peor que un gasto que espera dos minutos.

### 7.2 Captura por audio

Igual que el texto, con dos pasos extra dentro de la app:

1. El bot descarga el audio de WhatsApp y lo entrega en `archivo_base64` (`tipo: "audio"`).
2. La app lo escribe en su carpeta temporal y lo transcribe con **whisper_edge** en español, sin internet.
3. El texto transcrito llena el borrador de la captura y sigue el mismo camino de revisión.
4. Si la transcripción falla o queda vacía, la captura se marca para revisión con el audio adjunto y un aviso claro.

### 7.3 Captura por foto de un recibo

1. El bot entrega la imagen (`tipo: "imagen"`, `mime: "image/jpeg"`).
2. La app guarda el archivo en su carpeta privada de recibos y calcula su **hash** (para no duplicar).
3. **ML Kit Text Recognition** lee el texto en el teléfono. Se guardan el texto plano y el JSON con posiciones.
4. La app propone monto, fecha y comercio; el usuario corrige y confirma.
5. Al confirmar se crea la transacción y se enlaza al recibo (`recibo.transaccion_id`).

### 7.4 Reporte saliente (tres veces al día)

```
Hora programada (ej. 20:30)
        |
        v
APP: arma el reporte del dia (gastos por categoria, total, presupuesto restante)
        |
        v
APP: inserta mensaje en su cola de salida (tabla auxiliar de outbox)
        |
        v
BOT: en su siguiente consulta (cada 30 s aprox.)  GET /api/v1/outbox
        |
        v
BOT: envia por WhatsApp al numero autorizado
        |
        v
BOT: POST /api/v1/outbox/{id}/ack  {estado: "enviado"}
        |
        v
APP: marca el mensaje como entregado (no se repite)
```

Si el bot está apagado, el mensaje **espera en la cola** y sale cuando vuelva. Si WhatsApp falla, el bot hace `ack` con `estado: "error"` y la app muestra el fallo al usuario; no se reintenta en silencio.

---

## 8. Arranque y ciclo de vida

### 8.1 App

| Momento | Qué ocurre |
|---|---|
| Primer arranque | Crea la base SQLite, aplica migraciones de Drift, pide PIN (y ofrece biometría con `local_auth`) |
| Apertura normal | Bloqueo con biometría/PIN; al desbloquear, dashboard |
| Primer plano | Todas las funciones disponibles; el servidor local `:8787` escucha |
| Segundo plano | Android puede pausar el proceso. El servidor local deja de responder hasta que la app vuelva |
| Cierre forzado | Los datos ya están guardados; al reabrir, nada se pierde |

**Decisión de diseño:** para que el bot pueda entregar mensajes con la app cerrada, la Fase 2 añadirá un **servicio en primer plano** con notificación permanente ("Gestor Finanzas escuchando al bot"). Sin ese servicio, Android puede matar el proceso y el bot recibirá errores de conexión (que debe reintentar). En Fase 0 no existe nada de esto.

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
| Finanzas (cuentas, transacciones, etc.) | Base SQLite privada de la app, archivo `gestor_finanzas.sqlite` | SQLite (Drift) | Sí |
| Fotos de recibos | Carpeta privada de la app, `recibos/<hash>.<ext>` | JPEG/PNG | Sí (copia) |
| Audios temporales | Carpeta temporal; se borran tras transcribir | OGG/M4A | No |
| Token del bot | Tabla `configuracion` de la app + `.env` del bot | Texto | Sí (viaja en el respaldo) |
| Sesión de WhatsApp | Carpeta `whatsapp_bot/` del teléfono (Termux) | Archivos de Baileys | No (se revincula) |
| Respaldos | Google Drive, carpeta oculta de datos de la app | JSON + SQLite + recibos | — |

La carpeta privada de la app **no** es accesible desde otras apps ni desde el explorador de archivos, pero sí desde una copia de seguridad del sistema o desde un teléfono con root. Ese riesgo está aceptado explícitamente (ver [DECISIONS.md](DECISIONS.md), ADR-007).

---

## 10. Almacenamiento y respaldo

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
| API de WhatsApp | Baileys, sin API oficial | Riesgo de bloqueo del número secundario |

Nadie más que el dueño usa el teléfono ni la app; por eso el esfuerzo se pone en que **no se pierdan datos**, no en esconderlos.

---

## 12. Restricciones del entorno

| Restricción | Efecto | Mitigación |
|---|---|---|
| El emulador no tiene bot ni Termux | No se puede probar WhatsApp real en desarrollo | Modo mock (`MOCK_BOT=true`) desde la Fase 2 |
| Bot y app comparten CPU y batería | Un reporte o una descarga pueden tardar | Trabajos cortos, sin bucles pesados, reintentos suaves |
| Android puede matar procesos en segundo plano | El servidor `:8787` deja de responder | Servicio en primer plano con notificación (Fase 2) |
| Termux y el "phantom process killer" (Android 12+) | El bot puede morir solo | `termux-wake-lock`, batería sin restricciones, guía en Fase 5 |
| WhatsApp no permite dos sesiones del mismo número | El bot necesita número secundario | Número aparte, documentado en Fase 5 |
| Baileys no es la API oficial | El número puede ser bloqueado | Número secundario dedicado, sin envíos masivos, solo el dueño escribe |
| Sin Android Studio | No hay emulador "de fábrica" ni inspector gráfico | SDK por línea de comandos (`android sdk`) + `avdmanager` (Fase 0, ya hecho) |
| Un solo desarrollador | Todo debe quedar documentado | Estos 5 documentos + README raíz |

---

## 13. Capas internas de la app

La app se organiza en capas para que el dinero y las reglas no dependan de la pantalla:

| Carpeta | Qué contiene | Regla |
|---|---|---|
| `app/lib/core/` | Transversal: `config/` (constantes y versión), `router/` (go_router), `theme/` (colores y tipografía), `utils/` (formato de moneda y fechas, validaciones) | No conoce la base de datos ni las pantallas |
| `app/lib/domain/` | `entities/` (modelos puros) y `usecases/` (cálculos de saldo, presupuesto, metas, conversión) | Dart puro, sin Flutter ni SQLite; **aquí vive la verdad del dinero** |
| `app/lib/data/` | `database/` (tablas Drift, migraciones, semilla), `repositories/` (acceso a datos), `api/` (cliente del contrato del bot, Fase 2) y `providers.dart` (Riverpod) | Único lugar que escribe en SQLite o llama al bot |
| `app/lib/features/` | Una carpeta por función: `dashboard`, `accounts`, `transactions` y `settings` (implementadas en la Fase 1); `capture` (Fase 2); `budgets`, `debts`, `goals`, `reports` (fases 3–4) | No contiene fórmulas financieras: las pide a `domain` |
| `app/lib/services/` | Integraciones con el teléfono o la red: `whatsapp_bridge`, `ocr`, `audio`, `notifications`, `backup`, `exchange_rates` | Aíslan lo que depende de hardware, permisos o internet |
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
│   ├── test\                     # 37 pruebas: dinero, saldos, semilla, multimoneda, validación
│   └── lib\
│       ├── main.dart             # arranque: router, tema, providers globales
│       ├── core\
│       │   ├── config\           # AppConfig: nombre, version, fase, paquete
│       │   ├── router\           # go_router: rutas y guardas
│       │   ├── theme\            # tema claro y oscuro
│       │   └── utils\            # formato de moneda/fecha, validaciones
│       ├── data\
│       │   ├── api\              # cliente HTTP del contrato (Fase 2)
│       │   ├── database\         # tablas Drift, migraciones y semilla (Fase 1)
│       │   ├── repositories\     # acceso a datos por entidad (Fase 1)
│       │   └── providers.dart    # proveedores Riverpod (Fase 1)
│       ├── domain\
│       │   ├── entities\         # modelos puros (cuenta, transaccion, meta...)
│       │   └── usecases\         # calculos: saldo, restante, avance, conversion
│       ├── features\
│       │   ├── dashboard\        # inicio: saldos, consolidado y últimos movimientos (Fase 1)
│       │   ├── accounts\         # cuentas (Fase 1)
│       │   ├── transactions\     # movimientos manuales y filtros (Fase 1)
│       │   ├── capture\          # bandeja de capturas y revision (Fase 2)
│       │   ├── budgets\          # presupuestos (Fase 3)
│       │   ├── debts\            # deudas y creditos (Fase 3)
│       │   ├── goals\            # metas y aportes (Fase 3)
│       │   ├── reports\          # graficas y PDF (Fase 4)
│       │   └── settings\         # ajustes, categorias, etiquetas, monedas (Fase 1)
│       └── services\
│           ├── whatsapp_bridge\  # servidores 8787/8788 y cliente del bot (Fase 2)
│           ├── ocr\              # ML Kit y almacenamiento de recibos (Fase 2)
│           ├── audio\            # grabacion y transcripcion (Fase 2)
│           ├── notifications\    # avisos locales (Fase 3)
│           ├── backup\           # Google Drive (Fase 4)
│           └── exchange_rates\   # tasas diarias (Fase 4)
└── whatsapp_bot\                 # bot Node.js (Fase 0: esqueleto)
    ├── README.md                 # que hace, como correrlo y que falta
    ├── package.json              # scripts; Baileys entra en la Fase 2
    ├── index.js                  # arranque; hoy solo imprime un mensaje
    └── (auth\, .env y src\ se agregan en la Fase 2)
```

Las carpetas `build/`, `.dart_tool/` y `.idea/` las genera la herramienta y no se documentan ni se suben al repositorio. En la Fase 0 las carpetas de `lib/` existen vacías (con un `.gitkeep`) o con un archivo mínimo; su contenido real llega en la Fase 1. El andamiaje ya está creado: `app/` (con `main.dart`, `core/config`, `core/router` y `features/welcome`) y `whatsapp_bot/` (con `index.js`) forman parte de esta misma entrega.

---

## 15. Qué no existe todavía (al terminar la Fase 1)

- **Bot de WhatsApp**: solo el esqueleto en `whatsapp_bot/`; Baileys **no está instalado**.
- **Servidores HTTP**: ni el `:8787` de la app ni el `:8788` del bot.
- **OCR, voz, notificaciones, PDF, Google Drive**: sus paquetes se instalan cuando llegue su fase.
- **Presupuestos, deudas, créditos, metas y recurrentes**: solo están documentados en [DATA_MODEL.md](DATA_MODEL.md).
- **PIN/biometría**: pospuesto a la Fase 5.
- **Conversión automática de monedas**: en la Fase 1 las tasas son manuales; la actualización diaria llega en la Fase 4.

Lo que sí existe: base SQLite con semilla, CRUD de cuentas/categorías/subcategorías/etiquetas, transacciones manuales (ingreso, gasto y transferencia con dos montos), filtros, dashboard con multimoneda y tasas manuales, y pruebas automatizadas. Ver [PHASES.md](PHASES.md), Fase 1.

---

## 16. Documentos relacionados

| Si quieres… | Lee |
|---|---|
| Ver campos, tipos y reglas de cada tabla | [DATA_MODEL.md](DATA_MODEL.md) |
| Ver rutas, JSON y errores del canal app-bot | [API_CONTRACT.md](API_CONTRACT.md) |
| Saber en qué orden se construye y cómo se sabe que terminó | [PHASES.md](PHASES.md) |
| Entender por qué se eligió cada tecnología | [DECISIONS.md](DECISIONS.md) |
| Instalar el proyecto desde cero | `README.md` de la raíz |
