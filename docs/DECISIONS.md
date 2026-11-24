# Registro de decisiones — Gestor Finanzas

Cada decisión cerrada del proyecto queda aquí con su motivo, sus consecuencias y lo que se descartó. El objetivo es que dentro de seis meses —o si otra persona toma el proyecto— nadie "mejore" algo que se decidió a propósito.

**Formato:** ADR (Architecture Decision Record) en tabla, uno por entrada. Fecha de cierre de todas las decisiones iniciales: **2026-11-23**.

**Cómo se usa:**
- Una decisión aceptada no se cambia por conveniencia: se propone una nueva entrada que la reemplace y se marca la anterior como `Reemplazada por ADR-xxx`.
- Si aparece un tema no cubierto, se agrega una entrada nueva con la plantilla del final.
- Las decisiones marcadas **"solo el dueño"** no se tocan sin su aprobación explícita, aunque técnicamente sean discutibles.

---

## Resumen

| ID | Tema | Decisión en una línea | Estado |
|---|---|---|---|
| ADR-001 | Stack de la app | Flutter 3.50.1 / Dart 3.14.0 | Aceptada |
| ADR-002 | Estado de la interfaz | Riverpod | Aceptada |
| ADR-003 | Navegación | go_router | Aceptada |
| ADR-004 | Persistencia | Drift sobre SQLite, local-first 100 % offline | Aceptada |
| ADR-005 | Dinero | Enteros de centavos, nunca decimales | Aceptada |
| ADR-006 | Monedas | COP base, multimoneda con conversión diaria | Aceptada |
| ADR-007 | Privacidad | Sin cifrado y sin ocultar montos | Aceptada (solo el dueño) |
| ADR-008 | Respaldo | Google Drive App Data Folder, sin cifrado | Aceptada (solo el dueño) |
| ADR-009 | WhatsApp | Bot con Baileys en Termux, número secundario, sin API oficial | Aceptada |
| ADR-010 | Canal app-bot | HTTP en loopback, token compartido, contrato v1 | Aceptada |
| ADR-011 | Emulador sin bot | Modo mock activable por configuración | Aceptada |
| ADR-012 | OCR | Google ML Kit Text Recognition on-device | Aceptada |
| ADR-013 | Voz | whisper_edge offline dentro del APK | Aceptada |
| ADR-014 | Ritmo de entrega | Emulador desde el día 0, APK al final | Aceptada |
| ADR-015 | Alcance de la Fase 0 | Sin funciones financieras ni paquetes pesados | Aceptada |
| ADR-016 | Idioma | Documentación en español sencillo | Aceptada |
| ADR-017 | Instalación en Windows | Modo usuario, sin administrador | Aceptada |
| ADR-018 | Herramientas gráficas | Sin Android Studio | Aceptada (solo el dueño) |
| ADR-019 | Versiones | Flutter 3.50.1, Dart 3.14, JDK 21, SDK 36/minSdk 24, Node 24, Git 2.56.1 | Aceptada |
| ADR-020 | Puertos | App 8787, bot 8788 | Aceptada |
| ADR-021 | Paquete Android | `com.juanmartin.gestor_finanzas` | Aceptada |
| ADR-022 | Documentación | 5 documentos en `docs/` + README raíz | Aceptada |
| ADR-023 | Capturas | Revisión y confirmación humana antes de guardar | Aceptada |
| ADR-024 | Transferencias | Dos montos: origen y destino, con `moneda_destino` | Aceptada |
| ADR-025 | Estados de transacción | `estado` (confirmada/pendiente) y `origen` (manual/bot/importado) desde el inicio | Aceptada |
| ADR-026 | Tasas de cambio | Manuales en la Fase 1; conversión automática en la Fase 4 | Aceptada |
| ADR-027 | Semilla de categorías | Semilla una sola vez y predefinidas editables/borrables | Aceptada |
| ADR-028 | Catálogo de monedas | Lista fija en código, sin tabla | Aceptada |
| ADR-029 | Borrado lógico | Índices únicos parciales sobre registros vigentes | Aceptada |
| ADR-030 | API de capturas | Rutas v2 sin prefijo de versión; solo `/api/salud` sin token | Aceptada |
| ADR-031 | Bandeja de capturas | Ninguna transacción sin confirmación humana | Aceptada |
| ADR-032 | Simulador de bot | `MOCK_BOT` hace HTTP real a `127.0.0.1:8787` | Aceptada |
| ADR-033 | Adjuntos de captura | Carpeta privada `capturas/`, sin cifrado | Aceptada |
| ADR-034 | Parser de texto | Heurístico, con confianza y campos faltantes | Aceptada |
| ADR-035 | Cuenta por defecto | Configurable en Ajustes (`captura_cuenta_id`) | Aceptada |
| ADR-036 | Servidor de capturas | Loopback sin servicio en primer plano (parte 1) | Aceptada |

---

## ADR-001 — Flutter y Dart como stack de la app

| Campo | Contenido |
|---|---|
| ID | ADR-001 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | La app se construye en **Flutter 3.50.1 con Dart 3.14.0**, un solo código para Android, con paquetes del ecosistema oficial y comunitario. |
| Contexto | El producto es un APK Android de uso personal, con gráficas, cámara, micrófono, PDF y notificaciones. El dueño no programa y necesita un solo entorno de desarrollo. |
| Consecuencias | Un único lenguaje para toda la app; el mismo código podría correr en escritorio para pruebas; dependencia del ecosistema de paquetes y de sus versiones. Los paquetes nativos (ML Kit, biometría) obligan a confirmar compatibilidad con Android 36. |
| Alternativas descartadas | Kotlin/Android nativo (más control, mucho más código y otra curva de aprendizaje); React Native (segunda cadena de herramientas y peor integración con ML Kit local); app web/PWA (sin acceso cómodo a cámara, archivos ni notificaciones fiables). |

## ADR-002 — Riverpod para el estado

| Campo | Contenido |
|---|---|
| ID | ADR-002 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | El estado de la interfaz y la inyección de dependencias se manejan con **Riverpod**, con proveedores por función y estado derivado para los cálculos de pantalla. |
| Contexto | Hay muchas pantallas que dependen de los mismos datos (saldos, transacciones, presupuestos) y deben refrescarse al cambiar un registro, sin pasar parámetros por media app. |
| Consecuencias | Proveedores testeables sin widget tests; hay que respetar la regla de que las fórmulas de dinero viven en `domain/`, no en los proveedores; curva inicial de aprendizaje. |
| Alternativas descartadas | `setState` puro (imposible de escalar); Provider (más limitado para dependencias asíncronas); BLoC (más ceremonioso para un solo desarrollador); GetX (mezcla estado, rutas y navegación en un paquete, difícil de auditar). |

## ADR-003 — go_router para la navegación

| Campo | Contenido |
|---|---|
| ID | ADR-003 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | Las rutas se definen con **go_router**, con rutas declarativas y guardas para el bloqueo por PIN/biometría. |
| Contexto | Hay pantallas con parámetros (detalle de cuenta, edición de transacción) y una pantalla de bloqueo que debe interponerse antes de cualquier ruta protegida. |
| Consecuencias | Rutas centralizadas y verificables; el botón "atrás" de Android se comporta de forma predecible; una sola fuente de verdad para la navegación. Menos flexibilidad que rutas armadas a mano con `Navigator`. |
| Alternativas descartadas | `Navigator` 1.0 con rutas nombradas (estado disperso, difícil de probar); `auto_route` (generación de código extra para un beneficio pequeño). |

## ADR-004 — Drift sobre SQLite, local-first y 100 % offline

| Campo | Contenido |
|---|---|
| ID | ADR-004 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | La base de datos es **SQLite administrada por Drift**, y la app es **local-first**: todas las funciones financieras trabajan con datos locales y sin internet. |
| Contexto | Es información personal que debe seguir disponible en modo avión, en el bus y sin depender de servidores gratuitos que se duermen o desaparecen. |
| Consecuencias | Consultas tipadas y migraciones versionadas; los respaldos son un archivo que se puede copiar; no hay "sincronización" ni conflictos entre dispositivos. El esquema debe diseñarse con cuidado porque cambiarlo después cuesta (ver [DATA_MODEL.md](DATA_MODEL.md), §8.1). |
| Alternativas descartadas | Hive/Isar (rápidos, pero consultas y reportes por fecha/categoría más débiles); base en la nube (rompe offline y añade cuenta, red y costo); archivos JSON planos (sin transacciones ni índices). |

## ADR-005 — Dinero en centavos enteros

| Campo | Contenido |
|---|---|
| ID | ADR-005 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | Todo monto se guarda y se calcula como **entero de centavos** (`INTEGER` / `int`). Nunca `double` ni `float`. La única excepción decimal es la **tasa de cambio**, que es un factor, no dinero. |
| Contexto | Los decimales binarios producen errores de centavos al sumar y restar repetidamente, y en finanzas personales un centavo que no cuadra destruye la confianza en el reporte. |
| Consecuencias | Sumas y comparaciones exactas; hay que dividir por 100 solo al mostrar; las entradas del usuario se convierten a centavos en un único lugar (`core/`); las tasas se redondean al centavo únicamente al convertir. |
| Alternativas descartadas | `double` (errores acumulados); `decimal` de paquete externo (más peso sin resolver nada que los centavos no resuelvan); guardar pesos en vez de centavos (pierde precisión con dólares y tasas). |

## ADR-006 — COP como base, multimoneda con conversión diaria

| Campo | Contenido |
|---|---|
| ID | ADR-006 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | La moneda base es el **peso colombiano (COP)**. Se pueden registrar cuentas y transacciones en otras monedas; los reportes convierten a COP con la **tasa del día** guardada en `tasa_cambio`. |
| Contexto | El dueño vive en Colombia pero puede tener cuentas en dólares o recibir pagos en otra moneda; necesita un total coherente en pesos. |
| Consecuencias | Cada transacción conserva su moneda original y la tasa usada; el total siempre se puede recomponer; si falta la tasa del día se usa la última anterior y se marca el monto como "sin convertir" en vez de inventarlo. Los reportes históricos no cambian cuando cambia la tasa de hoy. |
| Alternativas descartadas | Solo COP (no cubre cuentas en dólares); convertir todo al registrar (pierde el monto original); actualizar tasas en tiempo real (paga red y cuotas por algo que se revisa una vez al día). |

## ADR-007 — Sin cifrado de datos y sin ocultar montos *(decisión del dueño)*

| Campo | Contenido |
|---|---|
| ID | ADR-007 |
| Fecha | 2026-11-23 |
| Estado | Aceptada — solo el dueño puede cambiarla |
| Decisión | **No se cifra** la base de datos, ni los recibos, ni los archivos exportados. **No existe modo discreto** ni forma de ocultar montos en pantalla. |
| Contexto | La app es de uso personal en un teléfono que solo usa el dueño. El cifrado complica los respaldos (no se podrían leer), arriesga pérdida total si se olvida la clave y agrega trabajo en cada fase. |
| Consecuencias | Cualquiera con acceso físico, root o una copia de seguridad del sistema puede leer todo. El bloqueo con biometría/PIN es comodidad, no seguridad criptográfica. Los respaldos son legibles por diseño. Si el teléfono se pierde, la información financiera queda expuesta: **riesgo aceptado**. |
| Alternativas descartadas | Cifrado de SQLite con SQLCipher (clave que recordar, respaldos ilegibles); cifrado solo de los respaldos (contradice la legibilidad pedida); ocultar montos tras un gesto (el dueño lo descartó explícitamente). |

## ADR-008 — Respaldo en Google Drive sin cifrado

| Campo | Contenido |
|---|---|
| ID | ADR-008 |
| Fecha | 2026-11-23 |
| Estado | Aceptada — solo el dueño puede cambiarla |
| Decisión | El respaldo se guarda en la **carpeta de datos de la app de Google Drive** (App Data Folder), **sin cifrado**, con archivos legibles (base SQLite, recibos y un manifiesto JSON). |
| Contexto | Hay que sobrevivir a la pérdida o cambio del teléfono sin pagar almacenamiento ni montar un servidor, y poder revisar el respaldo con herramientas comunes si algo sale mal. |
| Consecuencias | La carpeta no ocupa la cuota visible del usuario ni aparece en "Mi unidad"; restaurar exige la misma cuenta de Google; quien entre a esa cuenta puede leer los datos; si el permiso OAuth caduca, hay que renovarlo a mano. |
| Alternativas descartadas | Cifrado antes de subir (respaldos ilegibles, ADR-007); exportar a "Mi unidad" (aparece en la vista normal y se comparte por error con más facilidad); servidor propio (costo y mantenimiento). |

## ADR-009 — Bot de WhatsApp con Baileys en Termux, número secundario

| Campo | Contenido |
|---|---|
| ID | ADR-009 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | El bot se escribe en **Node.js** y se conecta a WhatsApp con **Baileys** (biblioteca no oficial) desde **Termux, en el mismo teléfono**, usando un **número secundario**. No se usa la API oficial de WhatsApp. |
| Contexto | Se quiere registrar gastos desde WhatsApp sin pagar mensajes, sin servidor en la nube y sin depender de una empresa intermedia. |
| Consecuencias | Conversación real con WhatsApp sin costo; el teléfono debe quedar encendido y con Termux vivo; la sesión hay que vincularla una vez y se puede caer; **existe riesgo de bloqueo del número** (se usa uno secundario, no el principal); no hay soporte ni estabilidad garantizada por WhatsApp. |
| Alternativas descartadas | API oficial de Meta (requiere verificación, cuenta de empresa y costo por conversación); webhooks en la nube (servidor y costo); Telegram (el dueño quiere WhatsApp). |

## ADR-010 — Comunicación HTTP en loopback con token y contrato v1

| Campo | Contenido |
|---|---|
| ID | ADR-010 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | La app y el bot se hablan por **HTTP JSON en `127.0.0.1`**, con la cabecera **`X-Bot-Token`** en toda llamada, rutas versionadas **`/api/v1`**, y una cola de salida con acuses (patrón outbox). |
| Contexto | Los dos procesos viven en el mismo teléfono y necesitan un canal simple, depurable desde Termux, que no exponga datos a la red local. |
| Consecuencias | Se puede probar cada lado por separado con `curl`; el token evita que otra app use el canal; el modo outbox hace que la app no dependa de que WhatsApp esté conectado; si la app está cerrada el bot recibe `503` y reintenta. Detalle en [API_CONTRACT.md](API_CONTRACT.md). |
| Alternativas descartadas | Sockets propietarios o archivos compartidos (frágiles, sin acuses); gRPC (más peso para dos procesos locales); exponer el servidor en `0.0.0.0` (abre la app a la red). |

## ADR-011 — Modo mock para el emulador

| Campo | Contenido |
|---|---|
| ID | ADR-011 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | La app incluye un **modo mock** (`MOCK_BOT=true`) que simula al bot sin abrir sockets: mensajes entrantes inventados, respuestas simuladas y errores forzables. |
| Contexto | El emulador no puede correr Termux ni un número de WhatsApp, pero toda la Fase 2 debe desarrollarse y probarse ahí. |
| Consecuencias | Se desarrolla y demuestra la captura sin teléfono real; el mock se marca siempre en pantalla para no confundir datos simulados; hay que mantener el mock sincronizado con el contrato real. |
| Alternativas descartadas | Probar solo en teléfono real (frena todo el trabajo); usar un bot falso en otra máquina (más piezas, más red); saltarse la Fase 2 en el emulador (deja el canal sin probar hasta el final). |

## ADR-012 — OCR con Google ML Kit Text Recognition on-device

| Campo | Contenido |
|---|---|
| ID | ADR-012 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | La lectura de recibos usa **Google ML Kit Text Recognition** ejecutado en el teléfono, sin enviar imágenes a ningún servidor. |
| Contexto | Las fotos de recibos pueden tener datos sensibles y el OCR debe funcionar sin internet y sin costo por uso. |
| Consecuencias | Funciona offline y en un segundo o dos; el modelo viaja en el APK (más tamaño); la calidad depende de la foto, así que siempre hay revisión humana; no se interpreta el texto automáticamente: se propone y el usuario confirma. |
| Alternativas descartadas | Servicio OCR en la nube (sube datos, necesita red y cuota); Tesseract (peor con recibos térmicos y en español); transcripción manual (anula el beneficio). |

## ADR-013 — Voz con whisper_edge offline dentro del APK

| Campo | Contenido |
|---|---|
| ID | ADR-013 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | La transcripción de notas de voz se hace con **whisper_edge**, en español, **dentro del APK**, sin internet. |
| Contexto | Las notas de voz son la forma más rápida de anotar un gasto desde WhatsApp o desde la app; el audio no debe salir del teléfono. |
| Consecuencias | Privacidad total y funcionamiento offline; el modelo ocupa espacio y consume CPU, y la transcripción de audios largos puede tardar; si falla, la captura queda pendiente con el audio para revisar. |
| Alternativas descartadas | Servicio de voz en la nube (sube audio, necesita red); dictado del teclado de Android (no controlamos el proceso ni la calidad en español); transcribir en el bot (duplicaría el modelo en Termux). |

## ADR-014 — Emulador desde el día 0 y APK al final

| Campo | Contenido |
|---|---|
| ID | ADR-014 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | Todo el desarrollo se prueba primero en el **emulador API 36 (Google APIs)**; el **APK firmado** y las pruebas en teléfono real llegan en la **Fase 5**, con un adelanto de pruebas reales a partir de la Fase 2 (bot). |
| Contexto | El emulador permite iterar rápido, no gasta batería del teléfono y se puede reiniciar si algo se rompe. |
| Consecuencias | Ciclos de prueba cortos y entorno reproducible; el emulador no tiene Termux ni WhatsApp, así que el bot se prueba en el teléfono real desde la Fase 2; el rendimiento real se descubre tarde, mitigado con pruebas en la Fase 5. |
| Alternativas descartadas | Desarrollar directo en el teléfono (lento, riesgoso y sin depurador cómodo); esperar al final para probar todo (errores descubiertos demasiado tarde). |

## ADR-015 — Fase 0 sin funciones financieras ni paquetes pesados

| Campo | Contenido |
|---|---|
| ID | ADR-015 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | La Fase 0 entrega **entorno, documentación y esqueletos**; no implementa nada financiero y **no instala** Baileys, Google Drive ni whisper. |
| Contexto | Empezar por el andamiaje evita escribir lógica sobre decisiones que todavía se están tomando; las dependencias pesadas agregan fallos de compilación que distraen del objetivo. |
| Consecuencias | Un proyecto que compila desde el primer día y una documentación acordada antes del código; hay que resistir la tentación de adelantar funciones; las dependencias entran exactamente cuando su fase las necesita. |
| Alternativas descartadas | Instalar todo de entrada "por si acaso" (fallos cruzados sin beneficio); empezar por pantallas (decisiones de datos tarde y caras); posponer la documentación (riesgo de que cada parte entienda distinto el contrato). |

## ADR-016 — Documentación en español sencillo

| Campo | Contenido |
|---|---|
| ID | ADR-016 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | Toda la documentación se escribe en **español sencillo**, pensada para alguien que no programa, con identificadores de código en inglés/neutro y nombres de datos en español. |
| Contexto | El dueño del producto no programa y necesita entender y aprobar las decisiones; el código lo lee él mismo en el futuro. |
| Consecuencias | Explicaciones con ejemplos, tablas y analogías; los términos técnicos se definen la primera vez que aparecen; no se traduce el código (las variables siguen en inglés) para no romper convenciones. |
| Alternativas descartadas | Documentación solo en inglés (excluye al dueño); documentación informal sin estructura (no sirve de referencia); dejar el conocimiento en la cabeza del desarrollador. |

## ADR-017 — Instalación de herramientas en modo usuario, sin administrador

| Campo | Contenido |
|---|---|
| ID | ADR-017 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | Flutter, JDK, Android SDK, Node y Git se instalan **en el perfil del usuario**, sin permisos de administrador, con `UAC` activo. Las variables de entorno son de usuario, no de sistema. |
| Contexto | El equipo tiene UAC activo y el dueño no quiere (ni necesita) privilegios de administrador para desarrollar. |
| Consecuencias | Nada se instala en `Program Files`; las rutas llevan el nombre del usuario; algunos instaladores clásicos no sirven y hay que usar archivos ZIP o el CLI `android sdk`; si otra cuenta de Windows usa el equipo, no ve las herramientas. |
| Alternativas descartadas | Instalar como administrador (pide credenciales y ensucia el sistema); contenedores o máquinas virtuales (más peso para un solo desarrollador); WSL (el APK y el emulador se manejan mejor en Windows). |

## ADR-018 — Sin Android Studio *(decisión del dueño)*

| Campo | Contenido |
|---|---|
| ID | ADR-018 |
| Fecha | 2026-11-23 |
| Estado | Aceptada — solo el dueño puede cambiarla |
| Decisión | No se usa **Android Studio**. El desarrollo es con el SDK de línea de comandos, `flutter`, `android sdk`, `avdmanager` y un editor ligero. |
| Contexto | El dueño prefiere un entorno liviano y no quiere descargar varios gigabytes de IDE que no va a usar. |
| Consecuencias | Menos consumo de disco y RAM; se pierden el inspector de layouts y el asistente de emuladores, así que el AVD se crea por comando; la guía de instalación debe ser explícita (Fase 0, ya cumplida). |
| Alternativas descartadas | Android Studio completo (pesado, con herramientas que no se usan); VS Code con extensión de Android (sigue dependiendo del SDK, pero es compatible y aceptable como editor). |

## ADR-019 — Versiones fijadas de herramientas

| Campo | Contenido |
|---|---|
| ID | ADR-019 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | Se fijan **Flutter 3.50.1, Dart 3.14.0, JDK Temurin 21, Android SDK 36 con minSdk 24, Node 24.21 y Git 2.56.1**. Las actualizaciones se hacen como decisión aparte. |
| Contexto | Un proyecto que cambia de versión a mitad de camino rompe compilaciones y hace irrepetibles las instrucciones de instalación. |
| Consecuencias | Cualquier máquina con estas versiones reproduce el proyecto; las dependencias deben ser compatibles con Dart 3.14; actualizar exige probar el APK y anotar la nueva decisión. |
| Alternativas descartadas | Usar siempre la última versión (sorpresas constantes); no fijar nada (imposible reconstruir el entorno); quedarse en versiones muy viejas (sin soporte de Android 36). |

## ADR-020 — Puertos 8787 y 8788

| Campo | Contenido |
|---|---|
| ID | ADR-020 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | El servidor de la app usa el puerto **8787** y el del bot el **8788**. Son fijos y no se negocian en tiempo de ejecución. |
| Contexto | Los dos procesos necesitan direcciones predecibles, y 8787 es el puerto que ya se venía usando para el canal local del proyecto. |
| Consecuencias | Configuración simple (dos constantes); si un puerto está ocupado, el proceso falla con un mensaje claro en vez de cambiar en silencio; probar con `curl` es inmediato. |
| Alternativas descartadas | Puerto dinámico (habría que descubrirlo y guardarlo, más piezas y más fallos); un solo puerto compartido (imposible: son dos procesos); puertos habituales como 3000/8000 (más colisiones con otras herramientas). |

## ADR-021 — Nombre de paquete `com.juanmartin.gestor_finanzas`

| Campo | Contenido |
|---|---|
| ID | ADR-021 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | El `applicationId` de Android es **`com.juanmartin.gestor_finanzas`**, con `compileSdk 36`, `targetSdk 36` y `minSdk 24`. |
| Contexto | El paquete identifica la app en el teléfono, en las actualizaciones y en el respaldo; debe ser único y estable para siempre. |
| Consecuencias | Cambiarlo después obliga a reinstalar y a migrar datos, así que se fija ahora; `minSdk 24` cubre teléfonos desde Android 7 sin sacrificar funciones; `targetSdk 36` cumple los requisitos actuales de Google. |
| Alternativas descartadas | `com.example.*` (prohibido y sin identidad); nombres con guiones o mayúsculas (inválidos en Android); `minSdk` más alto (dejaría fuera teléfonos viejos que el dueño podría usar). |

## ADR-022 — Cinco documentos en `docs/` y un README raíz

| Campo | Contenido |
|---|---|
| ID | ADR-022 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | La documentación se organiza en **cinco documentos** dentro de `docs/` — [ARCHITECTURE.md](ARCHITECTURE.md), [API_CONTRACT.md](API_CONTRACT.md), [DATA_MODEL.md](DATA_MODEL.md), [PHASES.md](PHASES.md), [DECISIONS.md](DECISIONS.md) — y un **`README.md`** en la raíz como puerta de entrada. |
| Contexto | Hay que evitar el extremo de un solo documento gigante y el de veinte archivos que nadie lee; cada lector busca algo distinto (visión, contrato, datos, plan, motivos). |
| Consecuencias | Cada documento es autónomo y se puede leer solo; los enlaces cruzados usan rutas relativas; el README cuenta el estado del proyecto y lleva a cada documento. Un tema nuevo debe encajar en uno de los cinco o crear una decisión. |
| Alternativas descartadas | Un único `DOC.md` (crece sin límite); documentación por carpeta de código (se desactualiza y duplica); wiki externa (sale del repo y se olvida). |

## ADR-023 — Revisión y confirmación humana antes de guardar una captura

| Campo | Contenido |
|---|---|
| ID | ADR-023 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | Ninguna captura (texto, audio u OCR) crea una transacción directamente: entra a una bandeja como **pendiente de revisión** y solo se guarda cuando el usuario confirma. |
| Contexto | El OCR se equivoca con recibos arrugados y la transcripción confunde "dieciocho" con "ochenta". Un gasto mal registrado es peor que un gasto que espera dos minutos. |
| Consecuencias | Datos confiables y corrección fácil antes de guardar; el flujo tiene un paso extra que el usuario debe atender; la bandeja de pendientes debe ser visible y no acumularse sin aviso. |
| Alternativas descartadas | Guardado automático con edición posterior (los errores se quedan y contaminan reportes); confirmación solo para imágenes (la voz también se equivoca); reglas mágicas de confianza según el texto (impredecibles). |

## ADR-024 — Transferencias con dos montos

| Campo | Contenido |
|---|---|
| ID | ADR-024 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | Una transferencia guarda **`monto_centavos`** (lo que sale de la cuenta origen) y **`monto_destino_centavos`** (lo que entra en la cuenta destino), junto con **`moneda_destino`**. |
| Contexto | Cuando las cuentas están en monedas distintas, el usuario conoce los dos montos reales (lo que le descontaron y lo que le abonaron) y no quiere que la app derive el destino con una tasa. |
| Consecuencias | La tasa efectiva se calcula de los dos montos (`monto_destino_centavos / monto_centavos`) y se guarda en la transacción; el saldo de cada cuenta usa su propio monto y no necesita multiplicar por la tasa; si las monedas son iguales, ambos montos coinciden. |
| Alternativas descartadas | Derivar el monto destino con la tasa del día (no coincide con el banco y obliga a corregir después); guardar solo el monto origen (el saldo de la cuenta destino queda mal). |

## ADR-025 — `estado` y `origen` en `transaccion`

| Campo | Contenido |
|---|---|
| ID | ADR-025 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | La transacción incluye **`estado`** (`confirmada` por defecto, `pendiente` reservado para el bot) y **`origen`** (`manual` por defecto, `bot`, `importado`) desde la Fase 1. |
| Contexto | La Fase 2 crea capturas pendientes y conviene distinguirlas sin migrar la tabla después; también se quiere saber de dónde salió cada movimiento. |
| Consecuencias | El alta manual siempre crea `confirmada`/`manual`; solo el bot (Fase 2) crea `pendiente`; los reportes y saldos solo cuentan las confirmadas; agregar un valor nuevo exige cambiar el `CHECK` y la migración. |
| Alternativas descartadas | Agregar las columnas en la Fase 2 (migración con datos reales); inferir el origen por la cuenta o por el texto de la nota (frágil y ambiguo). |

## ADR-026 — Tasas de cambio manuales en la Fase 1

| Campo | Contenido |
|---|---|
| ID | ADR-026 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | La tabla **`tasa_cambio`** se crea en la Fase 1 con **`fuente = 'manual'`**; la conversión automática diaria y las fuentes `trm`/`api_abierta` se posponen a la Fase 4. |
| Contexto | El dashboard necesita consolidar los saldos en la moneda base desde el MVP, y en la Fase 1 todavía no hay cliente de red ni tarea diaria de descarga. |
| Consecuencias | El usuario ingresa las tasas a mano y las puede corregir; si falta una tasa, el monto se marca como "sin convertir" en vez de inventarlo; la descarga automática llega después sin cambiar el esquema. |
| Alternativas descartadas | Esperar a la Fase 4 para las tasas (el dashboard quedaría incompleto); descargar tasas en la Fase 1 (sale del alcance y mete red y errores de conexión antes de tiempo). |

## ADR-027 — Semilla de categorías y predefinidas editables/borrables

| Campo | Contenido |
|---|---|
| ID | ADR-027 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | La semilla inicial de categorías y subcategorías corre **una sola vez** (clave `seed_categorias_v1` y verificación de tabla vacía); **`predefinida = 1` es informativo** y esas categorías se pueden editar, archivar o borrar si no tienen movimientos. |
| Contexto | El dueño quiere control total sobre sus categorías y no que reaparezcan las que borró. |
| Consecuencias | Si borra todas las categorías, no se reinsertan; con movimientos no se permite borrar y se ofrece archivar; la semilla debe ser exacta y estar documentada. |
| Alternativas descartadas | Reinsertar las predefinidas al abrir la app (impide borrarlas); bloquear las predefinidas (quita el control que pidió el dueño). |

## ADR-028 — Catálogo de monedas en código

| Campo | Contenido |
|---|---|
| ID | ADR-028 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | El catálogo de monedas es una **lista fija de monedas principales en código** (COP como base), en lugar de una tabla en la base con su pantalla de administración. |
| Contexto | Se necesita validar y mostrar monedas, pero administrar monedas no es una función del producto y una tabla extra agrega migraciones y pantallas. |
| Consecuencias | Agregar una moneda nueva exige tocar código en una fase futura; la validación es inmediata y no hay datos maestros que mantener; el listado debe ir en un solo lugar del código. |
| Alternativas descartadas | Tabla `moneda` administrable (más piezas para algo que casi no cambia); texto libre de 3 letras (errores de tipeo y códigos inválidos). |

## ADR-029 — Borrado lógico con índices únicos parciales

| Campo | Contenido |
|---|---|
| ID | ADR-029 |
| Fecha | 2026-11-23 |
| Estado | Aceptada |
| Decisión | Los nombres siguen siendo únicos, pero solo **entre registros vigentes**: los índices únicos son **parciales** con `WHERE eliminado_en IS NULL`. |
| Contexto | Con borrado lógico, un nombre "borrado" seguiría ocupando el índice y no se podría volver a usar, aunque el usuario ya no lo vea. |
| Consecuencias | Se puede reutilizar un nombre después de borrar; los índices se crean a mano en la migración porque Drift no los genera solo; dos registros con el mismo nombre pueden convivir si uno está eliminado. |
| Alternativas descartadas | Índice único global (impide reutilizar nombres); quitar el único y validar solo en la app (carreras y datos sucios). |

## ADR-030 — API v2 de capturas con rutas sin prefijo de versión

| Campo | Contenido |
|---|---|
| ID | ADR-030 |
| Fecha | 2026-11-24 |
| Estado | Aceptada |
| Decisión | Las rutas aprobadas son **`/api/salud`, `/api/capturas/texto`, `/api/capturas/foto`, `/api/audio` y `/api/pendientes`**; se retira el diseño `/api/v1/inbox`, que nunca se implementó. Solo `/api/salud` va **sin token**, y un duplicado responde **`409`** con el `captura_id`. |
| Contexto | El bot real todavía no existe y la Fase 2 parte 1 necesitaba un contrato que se pudiera probar en el emulador; el dueño aprobó rutas exactas, sin versión en la URL, para que el simulador y el futuro bot usen la misma dirección. |
| Consecuencias | Un solo juego de rutas para probar y para producción; la versión viaja en el documento (v2), no en la ruta; si un cambio es incompatible se publicarán rutas `/api/v2/...`; el `409` con `captura_id` permite al bot responder sin adivinar. |
| Alternativas descartadas | Mantener `/api/v1` en la ruta (una versión que nunca llegó a usarse); publicar ambas (dos juegos de rutas para un canal local). |
| Nota | Esta decisión **reemplaza el versionado `/api/v1` de ADR-010**; la autenticación, el loopback y la forma de error de ADR-010 siguen vigentes. |

## ADR-031 — La bandeja nunca crea transacciones sin confirmación humana

| Campo | Contenido |
|---|---|
| ID | ADR-031 |
| Fecha | 2026-11-24 |
| Estado | Aceptada |
| Decisión | **Reafirma ADR-023 para la Fase 2:** la bandeja nunca crea una transacción sin confirmación humana. El parser solo propone (`estado = 'listo'` con `propuesta_json`); la transacción nace únicamente al pulsar **Confirmar**; `transaccion_id` en la captura permite trazar la confirmación y bloquear la doble confirmación. |
| Contexto | El texto llega ambiguo y en la parte 1 las fotos y los audios ni siquiera tienen OCR o transcripción; cualquier guardado automático llenaría los reportes de errores. |
| Consecuencias | Los datos entran solo cuando el usuario los aprueba; hay un paso extra por captura; el `transaccion_id` permite auditar de dónde salió cada movimiento e impide confirmar dos veces. |
| Alternativas descartadas | Guardado automático (los errores contaminan los reportes); confirmación solo visual sin `transaccion_id` (no se puede trazar ni impedir el doble guardado). |

## ADR-032 — El simulador de bot usa HTTP real

| Campo | Contenido |
|---|---|
| ID | ADR-032 |
| Fecha | 2026-11-24 |
| Estado | Aceptada |
| Decisión | En la Fase 2, **`MOCK_BOT` es un simulador dentro de la app** que hace peticiones **HTTP reales** a `127.0.0.1:8787` con el token, como lo haría el bot. El mock sin red del contrato anterior queda para el bot del **Prompt 3**. |
| Contexto | El emulador no tiene WhatsApp ni Termux, y el objetivo de la parte 1 era probar el servidor real, no un atajo en memoria. |
| Consecuencias | El servidor, el token, la idempotencia y los límites se prueban de verdad desde el emulador; el simulador se marca siempre en pantalla y debe mantenerse alineado con el contrato. |
| Alternativas descartadas | Mock en memoria (no prueba el servidor); bot falso en otra máquina (más piezas y más red). |
| Nota | Esta decisión **reemplaza para la Fase 2 la definición de mock "sin red" de ADR-011**. En el Prompt 3 se redefine el mock del proceso Node (ese sí sin red). |

## ADR-033 — Adjuntos de captura en carpeta privada `capturas/`, sin cifrado

| Campo | Contenido |
|---|---|
| ID | ADR-033 |
| Fecha | 2026-11-24 |
| Estado | Aceptada |
| Decisión | Los adjuntos de captura se guardan en la **carpeta privada `capturas/`**, sin cifrado; la base guarda solo la **ruta relativa** en `adjunto_path`. Al descartar la captura se ofrece borrar el archivo; la base no guarda binarios. |
| Contexto | La base no debe inflarse con megabytes de fotos y audios, y ADR-007 ya decidió no cifrar los datos. |
| Consecuencias | La base queda liviana y los adjuntos se pueden borrar sin tocar filas; si se pierde la carpeta se pierden los adjuntos; quien tenga root o una copia del sistema puede verlos (riesgo aceptado). |
| Alternativas descartadas | Guardar el binario en la base (se infla y se vuelve lenta); cifrar los adjuntos (contradice ADR-007). |

## ADR-034 — Parser heurístico con confianza y faltantes

| Campo | Contenido |
|---|---|
| ID | ADR-034 |
| Fecha | 2026-11-24 |
| Estado | Aceptada |
| Decisión | El parser de texto es **heurístico**: devuelve tipo, monto, categoría/subcategoría, etiquetas, cuenta, `confianza` (**alta/media/baja**) y campos faltantes. Si no entiende algo, deja la captura en `listo` con confianza baja y la UI la resalta. |
| Contexto | El usuario escribe rápido y en español informal ("gasté 18.500 en mercado"); un parser estricto lo obligaría a escribir de una forma fija. |
| Consecuencias | El formulario se prellena sin bloquear la captura; el usuario siempre revisa; las heurísticas se ajustan con el uso y deben probarse como Dart puro. |
| Alternativas descartadas | Parser estricto que rechaza lo que no entiende (frustra al usuario); IA en la nube (rompe el offline de ADR-004). |

## ADR-035 — Cuenta por defecto para capturas

| Campo | Contenido |
|---|---|
| ID | ADR-035 |
| Fecha | 2026-11-24 |
| Estado | Aceptada |
| Decisión | Las capturas usan una **cuenta por defecto** configurable en Ajustes (clave `captura_cuenta_id`); si no está definida, la propuesta no trae cuenta y el usuario la elige al revisar. |
| Contexto | Casi todas las capturas van a la misma cuenta, y pedirla en cada mensaje es trabajo repetido. |
| Consecuencias | Menos toques al confirmar; la cuenta es solo una propuesta que se puede cambiar; si la cuenta configurada se borra o se inactiva, la app avisa y la captura queda sin cuenta. |
| Alternativas descartadas | Usar siempre la primera cuenta (puede ser la equivocada); obligar a configurar la cuenta antes de capturar (bloquea el primer uso). |

## ADR-036 — Servidor loopback sin servicio en primer plano (parte 1)

| Campo | Contenido |
|---|---|
| ID | ADR-036 |
| Fecha | 2026-11-24 |
| Estado | Aceptada |
| Decisión | En la Fase 2 parte 1 el servidor **loopback** arranca con la app y muere con ella: **no hay servicio en primer plano**. Si Android mata la app, el bot no puede entregar mensajes hasta que se reabra. Se resuelve en la **Fase 2.6**. |
| Contexto | Un *foreground service* exige permisos y una notificación permanente que todavía no se quiso mostrar; primero se valida el canal. |
| Consecuencias | La app no gasta batería escuchando de fondo; el bot debe tratar el corte como `NO_DISPONIBLE` y reintentar; la limitación queda documentada y visible en Ajustes. |
| Alternativas descartadas | Foreground service ya (más permisos y notificación permanente antes de tiempo); no tener servidor (no hay canal). |

---

## Decisiones que no se cambian sin el dueño

| Decisión | Motivo |
|---|---|
| ADR-007 — sin cifrado y sin ocultar montos | Es una preferencia explícita de uso personal |
| ADR-008 — respaldo legible sin cifrar | Depende de ADR-007 |
| ADR-018 — sin Android Studio | Preferencia de entorno del dueño |
| ADR-019 — versiones fijadas | Cambian el entorno que ya funciona |

## Plantilla para una decisión nueva

```
## ADR-0NN — Título corto

| Campo | Contenido |
|---|---|
| ID | ADR-0NN |
| Fecha | AAAA-MM-DD |
| Estado | Propuesta / Aceptada / Reemplazada por ADR-0MM |
| Decisión | Qué se decide, en una o dos frases. |
| Contexto | Por qué hace falta decidir y qué restricciones hay. |
| Consecuencias | Qué se gana, qué se pierde y qué trabajo implica. |
| Alternativas descartadas | Opciones evaluadas y por qué no. |
```

Al agregar una decisión: sumarla a la tabla de resumen, escribir la entrada con fecha real y, si reemplaza otra, marcarla. El plan de fases está en [PHASES.md](PHASES.md); si una decisión cambia el alcance de una fase, se actualiza ese documento en el mismo momento.
