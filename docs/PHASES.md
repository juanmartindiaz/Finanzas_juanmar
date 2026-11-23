# Plan de fases — Gestor Finanzas

El proyecto se construye en **seis fases**. Cada fase termina con un criterio de terminado que se puede comprobar (no una sensación), deja el proyecto funcionando de punta a punta y actualiza la documentación que cambió.

**Regla del proyecto:** no se empieza una fase hasta que la anterior cumple su criterio de terminado. Las fases no se fusionan y no se reordenan sin una decisión nueva en [DECISIONS.md](DECISIONS.md).

| Fase | Nombre | En una línea | Estado |
|---|---|---|---|
| 0 | Fundación | Entorno, repositorio, documentación y esqueletos que compilan | **Completada** |
| 1 | MVP local | Cuentas, categorías y transacciones manuales con saldos | Pendiente |
| 2 | Captura | OCR, voz offline, texto y bot de WhatsApp con modo mock | Pendiente |
| 3 | Planeación | Presupuestos, deudas, créditos, metas y recurrentes | Pendiente |
| 4 | Análisis y nube | Reportes, PDF, reportes diarios por WhatsApp, multimoneda y respaldo | Pendiente |
| 5 | Entrega | Endurecimiento, pruebas en teléfono real y APK final | Pendiente |

Dependencias: `0 → 1 → 2 → 3 → 4 → 5`. La 3 y la 4 dependen de la 1 (necesitan transacciones reales) y la 4 depende de la 3 (los reportes muestran presupuestos y metas).

```
Fase 0  [entorno + docs + esqueletos]
   |
Fase 1  [SQLite + transacciones + dashboard]
   |
   +--> Fase 3 [presupuestos, deudas, metas, recurrentes] --+
   |                                                        |
Fase 2  [OCR + voz + bot WhatsApp + mock] --+               |
                                            v               v
                                         Fase 4 [reportes, PDF, Drive, divisas]
                                            |
                                         Fase 5 [endurecer + APK + guia Termux]
```

Aunque el dibujo muestre la Fase 3 y la 2 en paralelo, se ejecutan una tras otra: una sola persona desarrolla.

---

## Reglas que aplican a todas las fases

| Regla | Consecuencia práctica |
|---|---|
| Dinero en centavos enteros | Prohibido `double` para montos; se revisa en cada revisión de código |
| Local-first | La app debe funcionar sin internet; lo único que lo necesita es Drive y WhatsApp |
| Sin cifrado y sin ocultar montos | No se agregan capas de cifrado ni "modo discreto" por iniciativa propia |
| Documentación en español | Cada cambio de contrato o esquema se refleja en `docs/` en la misma fase |
| Nada a medias en la rama principal | Al terminar cada fase, `app/` compila y el bot arranca |
| Compatibilidad hacia atrás | Un APK nuevo debe abrir una base de la fase anterior (migración) |

---

## Fase 0 — Fundación *(completada)*

### Objetivo

Dejar listo el terreno: la máquina de desarrollo, el repositorio, la documentación y dos esqueletos que compilan. **Ninguna función financiera.**

### Alcance

- Documentación completa del sistema: arquitectura, contrato app-bot, modelo de datos, fases y decisiones.
- Entorno Windows instalado **en modo usuario** (sin administrador): Flutter 3.50.1 con Dart 3.14.0, JDK Temurin 21, Android SDK 36, emulador API 36 con Google APIs, Node 24.21, Git 2.56.1.
- Proyecto Flutter en `app/` con go_router, paquete `com.juanmartin.gestor_finanzas`, `compileSdk 36`, `targetSdk 36`, `minSdk 24`, y una sola pantalla: "Gestor Finanzas — Fase 0".
- Esqueleto del bot en `whatsapp_bot/`: `index.js`, `package.json` y `README.md`, **sin** instalar Baileys.
- Repositorio Git con primer commit.

### Entregables

| Entregable | Dónde | Cómo se comprueba |
|---|---|---|
| Documentación de arquitectura | `docs/ARCHITECTURE.md` | Existe, enlaza al resto y describe los dos componentes |
| Contrato app-bot | `docs/API_CONTRACT.md` | Rutas, JSON, errores, token y modo mock definidos |
| Modelo de datos | `docs/DATA_MODEL.md` | Entidades, campos, reglas e índices definidos |
| Plan de fases | `docs/PHASES.md` | Este documento |
| Registro de decisiones | `docs/DECISIONS.md` | Cada decisión con motivo y alternativas |
| Pantalla inicial | `app/lib/features/welcome/welcome_screen.dart` | Corre en el emulador API 36 |
| Esqueleto del bot | `whatsapp_bot/index.js` + `whatsapp_bot/README.md` | Explica qué hará y qué no está instalado |
| Repositorio | raíz | `git log` muestra el primer commit |

### Ya completado (verificado)

- [x] Flutter 3.50.1 / Dart 3.14.0 instalados en modo usuario.
- [x] JDK Temurin 21 como JDK de Gradle.
- [x] Android SDK 36 y emulador API 36 (Google APIs) creados y arrancando.
- [x] `flutter doctor` sin problemas.
- [x] Proyecto Flutter en `app/` con go_router y la pantalla "Gestor Finanzas — Fase 0".
- [x] Esqueleto de `whatsapp_bot/`.
- [x] Repositorio Git con el primer commit.

### Criterio de terminado

1. `flutter doctor` termina sin problemas ni advertencias que bloqueen.
2. `flutter run` en el emulador API 36 muestra "Gestor Finanzas — Fase 0" y no lanza errores.
3. `node --version` responde 24.21 y `npm install` en `whatsapp_bot/` termina sin errores (no hay dependencias todavía).
4. Arrancar el bot con `node index.js` (o `npm start`) imprime "Bot Gestor Finanzas — pendiente Fase 2" y **no** intenta conectarse a WhatsApp.
5. Los 5 documentos de `docs/` existen, se leen y no se contradicen entre sí.
6. `git status` está limpio y hay al menos un commit.

### Fuera de alcance

Tablas de base de datos, servidores HTTP, token, Baileys, ML Kit, whisper, notificaciones, Google Drive, biometría, gráficas, y cualquier pantalla además de la inicial.

### Riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Versiones inexistentes o actualizadas a mitad del proyecto | El proyecto no compila igual en otra máquina | Versiones fijadas en [DECISIONS.md](DECISIONS.md) y anotadas aquí |
| Ruta con espacio (`App finanzas`) | Comandos de Gradle y scripts fallan | Rutas entre comillas en toda la documentación |
| Sin permisos de administrador | Instaladores fallan | Todo se instala en modo usuario (ADR-017) |
| Emulador lento en el equipo | Pruebas eternas | Imagen API 36 con Google APIs, sin Play Store; snapshot del AVD |
| Dos frentes tocando el repositorio | Archivos pisados | Documentar antes de codificar y confirmar con `git status` antes de cada entrega |

---

## Fase 1 — MVP local

### Objetivo

Tener una app que el dueño pueda usar todos los días para registrar sus movimientos **sin WhatsApp y sin internet**, con datos que sobreviven al cierre.

### Alcance

- Base de datos real con Drift: `cuenta`, `categoria`, `subcategoria`, `etiqueta`, `transaccion`, `transaccion_etiqueta` y `configuracion` (esquema de la Fase 1 en [DATA_MODEL.md](DATA_MODEL.md), §7).
- Migración inicial `schemaVersion = 1` y el hábito de copiar la base antes de migrar.
- Categorías y subcategorías predefinidas en español (Alimentación, Transporte, Vivienda, Salud, Ocio, Educación, Deudas, Ingresos…) con icono y color.
- CRUD de cuentas (los 7 tipos) y de categorías/etiquetas, con archivado en lugar de borrado.
- Registro manual de ingresos, gastos y transferencias, con fecha, hora, nota, etiquetas y moneda.
- Dashboard: saldo total, saldo por cuenta, gasto del mes y últimos movimientos.
- Bloqueo de la app con PIN y biometría opcional (`local_auth`), con PIN como respaldo.
- Formato de moneda en COP ($1.234.567) y formato de fecha local, todo en `core/`.
- Pruebas unitarias de las fórmulas de dinero (suma, conversión, saldo).

### Entregables

| Entregable | Dónde |
|---|---|
| Tablas Drift, DAOs y migraciones | `app/lib/data/database/` |
| Repositorios por entidad | `app/lib/data/repositories/` |
| Entidades y cálculos (saldo, totales) | `app/lib/domain/entities/` + `app/lib/domain/usecases/` |
| Pantallas de cuentas y transacciones | `app/lib/features/accounts/` + `app/lib/features/transactions/` |
| Dashboard con saldos (se crea en esta fase) | `app/lib/features/dashboard/` |
| Bloqueo con PIN/biometría | `app/lib/services/` + nueva carpeta de pantalla inicial |
| Formato de moneda y fecha | `app/lib/core/utils/` |
| Pruebas de dinero | `app/test/` |

### Criterio de terminado

1. Se crea una cuenta Efectivo con saldo inicial, se registran 3 movimientos y el saldo mostrado coincide con el cálculo a mano.
2. Una transferencia entre dos cuentas deja el **total** igual y mueve el saldo de las dos.
3. Cerrar y volver a abrir la app conserva todos los datos.
4. Borrar una categoría con transacciones está bloqueado y ofrece archivarla.
5. No existe ningún `double` en el manejo de montos (revisión de código).
6. Las pruebas de dinero pasan; el APK no pide permisos raros.

### Fuera de alcance

OCR, audio, bot, modo mock, presupuestos, deudas, metas, reportes, PDF, divisas, Drive y sincronización de cualquier tipo.

### Riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Migraciones mal hechas | Pérdida de datos al actualizar | Copia previa obligatoria y probar migración con base de la fase anterior |
| Fechas y zona horaria | Movimientos en el día equivocado | Fecha de calendario en texto (ADR-005/DATA_MODEL §1.1) |
| Redondeo al convertir | Centavos perdidos | Conversión solo al mostrar; montos siempre enteros |
| Pantallas que crecen sin control | App lenta y difícil de mantener | Una carpeta por función en `features/` y reglas de capas |

---

## Fase 2 — Captura

### Objetivo

Registrar un gasto **sin teclear casi nada**: por foto del recibo, por nota de voz, por texto y por WhatsApp. Todo con revisión del usuario antes de guardar.

### Alcance

- Servidor HTTP local de la app en `:8787` con `X-Bot-Token` y las 5 rutas del contrato ([API_CONTRACT.md](API_CONTRACT.md), §8).
- Servidor local del bot en `:8788` con sus 4 rutas (§9).
- Tabla `captura_entrante` y cola de salida con acuses; idempotencia por `id_mensaje`.
- OCR de recibos con Google ML Kit Text Recognition (on-device), guardado de imagen y hash, y pantalla de revisión/confirmación.
- Transcripción offline de audio en español con `whisper_edge`, dentro del APK.
- Entrada por texto con atajos ("Almuerzo 18.500 efectivo").
- Bot con Baileys en Termux, número secundario, que entrega texto/audio/foto y consulta la cola de salida.
- Modo mock (`MOCK_BOT=true`) con bandeja simulada y botones para forzar errores.
- Servicio en primer plano para que el servidor `:8787` siga vivo con la app cerrada.

### Entregables

| Entregable | Dónde |
|---|---|
| Servidor HTTP de la app y validación del token | `app/lib/services/whatsapp_bridge/` |
| Cliente del contrato (envío, outbox, config) | `app/lib/data/api/` |
| OCR y almacenamiento de recibos | `app/lib/services/ocr/` |
| Transcripción de audio | `app/lib/services/audio/` |
| Bandeja de capturas y revisión | `app/lib/features/capture/` |
| Bot: conexión, entrega y cola | `whatsapp_bot/index.js` + `whatsapp_bot/src/` (se crea aquí) |
| Modo mock | `app/lib/services/whatsapp_bridge/` + `app/lib/core/config/` |

### Criterio de terminado

1. En el emulador con modo mock, un mensaje simulado de texto crea una captura pendiente y se confirma en la app; el aviso de "enviado" aparece en la bandeja simulada.
2. En el teléfono real, con el bot en Termux y número secundario, enviar "Taxi 9.800" por WhatsApp produce la captura y la confirmación llega de vuelta.
3. Una foto de recibo produce texto OCR editable y, al confirmar, una transacción enlazada al recibo.
4. Una nota de voz en español se transcribe sin internet y llena el borrador.
5. Reenviar el mismo `id_mensaje` **no** duplica la captura.
6. Una petición sin token responde `401 NO_AUTORIZADO`; un cuerpo de 12 MB responde `413`.
7. Con la app cerrada, el bot puede seguir entregando mensajes (servicio en primer plano activo).

### Fuera de alcance

Presupuestos, deudas, créditos, metas, recurrentes, reportes gráficos, PDF, Drive y conversión automática de divisas.

### Riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Modelo de voz pesado | APK grande y transcripción lenta | Modelo en español reducido; medir y documentar el tamaño |
| OCR impreciso con recibos borrosos | Datos basura | Siempre revisión humana; nunca guardar automático |
| Baileys no es API oficial | Bloqueo del número | Número secundario, solo mensajes del dueño, sin envíos masivos |
| Termux + ahorro de batería | El bot se apaga | `termux-wake-lock` y guía de configuración |
| Android mata el proceso de la app | El bot recibe `503` | Servicio en primer plano + reintentos del bot |
| Base64 grande en memoria | Cierre por falta de memoria | Límites de 8 MB y streaming a archivo |

---

## Fase 3 — Planeación

### Objetivo

Pasar de "anotar lo que pasó" a "decidir antes de gastar": presupuestos, deudas, créditos, metas y gastos recurrentes con recordatorios.

### Alcance

- Presupuestos con los 4 periodos (mensual, semanal, quincenal, único), globales o por categoría, con las 3 reglas de sobrante.
- Deudas con personas (`a_favor` / `en_contra`) y su estado.
- Créditos con cuotas, tasa e intereses, saldo y estado (activo/pagado/mora).
- Metas de ahorro e inversión con aportes, rendimientos y retiros.
- Recurrentes con frecuencia, intervalo, próxima fecha y aviso previo.
- Notificaciones locales (`flutter_local_notifications`) para recurrentes, vencimientos y presupuestos cerca del límite.

### Entregables

| Entregable | Dónde |
|---|---|
| Tablas y repositorios nuevos | `app/lib/data/database/` + `app/lib/data/repositories/` |
| Cálculos de restante, saldo de meta y avance de crédito | `app/lib/domain/usecases/` |
| Pantallas de presupuestos, deudas, créditos, metas y recurrentes | `app/lib/features/budgets/`, `debts/`, `goals/` |
| Programación de avisos | `app/lib/services/notifications/` |
| Pruebas de reglas (sobrante, retiro mayor al saldo, cuotas) | `app/test/` |

### Criterio de terminado

1. Un presupuesto mensual de $500.000 en Alimentación muestra el restante correcto después de 3 gastos y cambia a rojo al pasarse.
2. Al cerrar el mes, la regla de sobrante configurada se aplica como dice el documento (`reiniciar`, `arrastrar`, `mover_a_meta`).
3. Un retiro mayor al saldo de una meta se rechaza con un mensaje claro.
4. Un recurrente mensual genera su aviso, se registra como transacción y avanza `proxima_fecha`.
5. El saldo de un crédito a 12 cuotas con pagos parciales muestra "cuotas pagadas (aproximado)" coherente.

### Fuera de alcance

Reportes gráficos, PDF, envío de reportes, conversión automática de divisas y respaldo en Drive (todo eso es la Fase 4). Amortización exacta con intereses por cuota: no entra en esta versión.

### Riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Fórmulas de presupuesto ambiguas | Números que no cuadran | Reglas escritas en [DATA_MODEL.md](DATA_MODEL.md), §6 y pruebas |
| Notificaciones que Android bloquea | Avisos perdidos | Pedir permiso, probar en teléfono real, no depender del aviso |
| Exceso de alcance | La fase no termina | Solo las 5 funciones listadas |

---

## Fase 4 — Análisis y nube

### Objetivo

Entender en qué se va la plata, exportar pruebas en PDF, recibir un resumen por WhatsApp tres veces al día, manejar varias monedas y no perder los datos.

### Alcance

- Reportes con `fl_chart`: gasto por categoría y comparación mes a mes.
- Exportación a PDF con `pdf` + `printing` (compartir, guardar, imprimir).
- Reportes diarios automáticos a las 3 horas configuradas, enviados por la cola del bot.
- Conversión diaria de monedas: descarga de la tasa del día, almacenamiento en `tasa_cambio` y conversión a COP en reportes.
- Respaldo y restauración en Google Drive (App Data Folder), **sin cifrado**, con manifiesto y verificación.
- Ajustes: horarios, destinatarios, token, modo mock, respaldo automático.

### Entregables

| Entregable | Dónde |
|---|---|
| Consultas agregadas de reportes | `app/lib/data/repositories/` |
| Gráficas y pantallas de reportes | `app/lib/features/reports/` |
| Generación de PDF (se crea en esta fase) | `app/lib/services/pdf/` |
| Programación de reportes y cola de salida | `app/lib/services/notifications/` + `app/lib/data/api/` |
| Descarga y conversión de tasas | `app/lib/services/exchange_rates/` |
| Respaldo y restauración en Drive | `app/lib/services/backup/` |

### Criterio de terminado

1. El reporte por categoría coincide con la suma manual de un mes de prueba.
2. El PDF se genera, se abre desde el visor del teléfono y muestra los mismos números.
3. Llegan tres reportes al WhatsApp del dueño en un día, uno por horario, sin duplicados.
4. Un gasto en USD con tasa del día aparece convertido a COP en el reporte y se conserva la tasa usada en la transacción.
5. Se respalda, se reinstala la app y se restaura sin perder ni un movimiento ni una foto de recibo.
6. Los archivos del respaldo son legibles (JSON/SQLite) sin herramientas especiales.

### Fuera de alcance

Cifrado de respaldos, compartición con otras personas, nube propia y sincronización entre dispositivos.

### Riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Tasa de cambio no disponible | Reportes sin convertir | Guardar la última tasa y marcar "sin convertir" |
| Reportes en la hora equivocada | Avisos a deshoras | Zona IANA + `flutter_local_notifications` + revisión en teléfono real |
| Respaldo que no restaura | Pérdida total | Probar restauración en cada fase desde la Fase 4 |
| Drive en modo Testing | El acceso caduca | Documentar cómo renovar el permiso |

---

## Fase 5 — Endurecimiento y entrega

### Objetivo

Convertir la app en algo que se use a diario sin sustos: sin caídas, sin datos perdidos, con APK firmado y bot instalado en Termux de forma repetible.

### Alcance

- Revisión de errores y mensajes en toda la app (nada de excepciones crudas en pantalla).
- Pruebas en emulador API 36 y en el teléfono real (gama de entrada, poca RAM).
- Rendimiento: apertura, listados largos, reportes con miles de transacciones.
- APK final firmado, versión 1.0.0, `minSdk 24`.
- Guía paso a paso de Termux con número secundario, wake-lock y arranque automático.
- Documentación final actualizada (este plan, contrato y modelo si cambiaron).

### Entregables

| Entregable | Dónde |
|---|---|
| APK firmado | `app/build/app/outputs/flutter-apk/` (artefacto, no se sube al repo) |
| Guía de instalación del bot | `whatsapp_bot/README.md` + esta fase |
| Lista de pruebas manuales y resultados | `docs/PHASES.md` (bitácora al final) |
| Correcciones de la revisión | `app/lib/` y `whatsapp_bot/src/` |

### Criterio de terminado

1. El APK se instala en un teléfono real sin el cable y arranca sin pantalla en blanco.
2. Una semana de uso diario sin caídas ni pérdida de datos.
3. El bot revive solo tras reiniciar el teléfono y sigue entregando mensajes.
4. Se puede restaurar un respaldo completo en una instalación limpia siguiendo la guía al pie de la letra.
5. La guía de Termux se puede repetir en un teléfono nuevo sin ayuda externa.

### Fuera de alcance

Publicación en Play Store, cuentas multiusuario, sincronización entre teléfonos, cifrado y funciones nuevas.

### Riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Pérdida de la llave de firma | No se pueden instalar actualizaciones | Guardar la llave y sus contraseñas fuera del repo |
| Bloqueo del número del bot | Se pierde la captura por WhatsApp | Número secundario; la app sigue funcionando sin bot |
| Batería del teléfono | El bot consume | Reportes en 3 momentos fijos, sin sondeo agresivo |
| Pruebas tardías con datos reales | Sorpresas al final | Probar restauración y respaldo desde la Fase 4 |

---

## Bitácora de cierre por fase

Al terminar cada fase se anota aquí la fecha, el criterio cumplido y cualquier desviación:

| Fase | Fecha de cierre | Desviaciones |
|---|---|---|
| 0 | 2026-11-23 | Ninguna: entorno, documentación y esqueletos entregados |
| 1 | — | — |
| 2 | — | — |
| 3 | — | — |
| 4 | — | — |
| 5 | — | — |

Las decisiones nuevas que aparezcan durante las fases se registran en [DECISIONS.md](DECISIONS.md), no en este documento. La arquitectura vigente está en [ARCHITECTURE.md](ARCHITECTURE.md) y el contrato en [API_CONTRACT.md](API_CONTRACT.md).
