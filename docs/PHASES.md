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

## Fase 1 — MVP local *(completada)*

### Objetivo

Tener una app que el dueño pueda usar todos los días para registrar sus movimientos **sin WhatsApp y sin internet**, con datos que sobreviven al cierre.

### Alcance

- Base Drift con `cuenta`, `categoria`, `subcategoria`, `etiqueta`, `transaccion`, `transaccion_etiqueta`, `tasa_cambio`, `configuracion` y la estructura de `recibo` (vacía); `schemaVersion = 1` y copia previa a migrar (esquema en [DATA_MODEL.md](DATA_MODEL.md), §7).
- CRUD de cuentas (los 7 tipos): se borran si no hay movimientos o se desactivan si los hay.
- Categorías, subcategorías y etiquetas con CRUD y semilla inicial exacta (Gastos: Alimentación con Supermercado/Restaurantes/Domicilios, Transporte con Público/Gasolina/Taxi-App, Hogar y Servicios, Salud, Educación, Ocio, Ropa, Compras, Mascotas, Otros; Ingresos: Salario, Freelance/Honorarios, Ventas, Regalos, Rendimientos, Otros); se borran si no hay movimientos y se archivan si los hay.
- Transacciones manuales de ingreso, gasto y transferencia (con monto origen y monto destino cuando las monedas difieren), edición, borrado lógico, filtros por cuenta, categoría, tipo, fechas y etiqueta, y búsqueda en la nota.
- Dashboard: saldos agrupados por tipo (Efectivo; Bancos incluye banco/nequi/daviplata; Tarjetas; Ahorro; Inversión), subtotales por moneda, total consolidado a la moneda base con tasas manuales, últimas 10 transacciones y botón flotante "+".
- Ajustes: moneda base, tasas manuales por par, gestión de categorías, subcategorías y etiquetas y acceso a cuentas.
- Formato COP `$ 1.234.567` con locale `es-CO`; pruebas de saldos, transferencias, semilla, multimoneda y validaciones.

### Entregables

| Entregable | Dónde |
|---|---|
| Tablas Drift, DAOs y migraciones | `app/lib/data/` |
| Repositorios por entidad | `app/lib/data/repositories/` |
| Entidades y cálculos (saldo, totales) | `app/lib/domain/` |
| Pantallas de cuentas y transacciones | `app/lib/features/accounts/` + `app/lib/features/transactions/` |
| Dashboard con saldos | `app/lib/features/dashboard/` |
| Ajustes (moneda base, tasas, categorías, etiquetas) | `app/lib/features/settings/` |
| Formato de moneda y fecha | `app/lib/core/utils/` |
| Pruebas de dinero | `app/test/` |

### Criterio de terminado

1. Se crean, editan y borran cuentas de los 7 tipos y los saldos se ven en pantalla.
2. Se crean, editan y borran categorías, subcategorías y etiquetas; con movimientos se archivan en lugar de borrarse.
3. Se registran ingresos, gastos y transferencias con todos los campos (incluidos monto destino y moneda destino).
4. El dashboard muestra los saldos por tipo, los subtotales por moneda y el consolidado con tasa manual.
5. Los filtros de transacciones (cuenta, categoría, tipo, fechas y etiqueta) y la búsqueda en la nota funcionan.
6. Al borrar una cuenta sin movimientos se borra; si tiene movimientos, la app ofrece desactivarla.
7. `flutter analyze` termina limpio y `flutter test` en verde.
8. La app corre en el emulador API 36 sin crashes.
9. La documentación queda actualizada con lo que cambió.

### Fuera de alcance

OCR, audio, bot/WhatsApp, modo mock, presupuestos, deudas, créditos, metas, recurrentes, reportes/PDF, **conversión automática** de monedas, Drive, biometría/PIN.

### Riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Migraciones mal hechas | Pérdida de datos al actualizar | Copia previa obligatoria y probar migración con base de la fase anterior |
| Fechas y zona horaria | Movimientos en el día equivocado | Fecha de calendario en texto (ADR-005/DATA_MODEL §1.1) |
| Redondeo al convertir | Centavos perdidos | Conversión solo al mostrar; montos siempre enteros |
| Tasas manuales mal ingresadas | Totales consolidados equivocados | Se muestran y se pueden corregir; si falta tasa, la cuenta se marca como sin convertir |
| Pantallas que crecen sin control | App lenta y difícil de mantener | Una carpeta por función en `features/` y reglas de capas |

---

## Fase 2 — Captura (parte 2 completada; OCR en curso)

### Objetivo

Registrar un gasto **sin teclear casi nada**: por foto del recibo, por nota de voz, por texto y por WhatsApp. El texto de WhatsApp se registra automáticamente; fotos y audios se revisan en la bandeja (aún sin OCR ni transcripción).

### Alcance de la parte 1 (hecha)

- Tabla `captura_entrante` (migración v1→v2 con copia previa y sin tocar datos existentes).
- Servidor HTTP local de la app en `127.0.0.1:8787` (puerto configurable) con `X-Bot-Token`, límite 8 MB, idempotencia por `message_id` y errores JSON: `GET /api/salud`, `POST /api/capturas/texto`, `POST /api/capturas/foto`, `POST /api/audio`, `GET /api/pendientes`.
- Parser de texto en español (gastos e ingresos, montos en varios formatos, categoría/subcategoría, etiquetas, cuenta por defecto, confianza y faltantes).
- Bandeja `/bandeja` con pendientes/listos arriba e historial abajo, badge en el dashboard y captura manual de texto.
- Revisión `/bandeja/:id` reutilizando el formulario de transacción de la Fase 1: confirmar crea la transacción real (con `origen` bot o manual) o descartar sin crear nada.
- Simulador de bot (`MOCK_BOT`) que hace peticiones HTTP reales al servidor local con imagen y audio elegibles desde el archivo.
- Ajustes: Canal bot (token ver/copiar/regenerar, puerto, MOCK_BOT, estado del servidor) y Capturas (cuenta por defecto).

### Pendiente para cerrar la Fase 2 (prompts siguientes)

- **2.3:** bot real con Baileys en Termux (QR, autorización por número, cola persistente, logs) y **registro directo**: si el parser obtiene monto+tipo+cuenta, la transacción se crea sin revisión; si falta cuenta/monto/tipo, el bot lo pregunta por chat. La bandeja queda como historial editable. Ver ADR-041.
- **2.4:** OCR de recibos con ML Kit (implementado): la foto se procesa offline, el parser de recibos extrae monto/comercio/categoría y se auto-registra; si no hay monto, el bot pregunta (ADR-043).
- **2.5:** transcripción offline de audio con `whisper_edge`.

### Pendiente para cerrar la Fase 2 (prompts siguientes)

- **2.5:** transcripción offline de audio con `whisper_edge`.

### Entregables de la parte 1

| Entregable | Dónde |
|---|---|
| Tabla y migración v1→v2, ruta única de la base y copia `.backup` | `app/lib/data/database/` |
| Servidor HTTP, token, límites, multipart y adjuntos | `app/lib/services/whatsapp_bridge/` |
| Repositorio de capturas y proveedores | `app/lib/data/repositories/capturas_repository.dart` |
| Parser de texto en español | `app/lib/domain/parsers/` |
| Bandeja, revisión y captura manual | `app/lib/features/bandeja/` + formulario de transacción reutilizado |
| Simulador de bot y ajustes del canal | `app/lib/features/settings/` |
| Pruebas: parser, migración, HTTP y bandeja | `app/test/` |

### Criterio de terminado de la parte 1

1. Migración v1→v2 sin pérdida de datos, con copia `.backup` en la misma ruta de la base.
2. Bandeja con capturas por estado y badge de pendientes en el dashboard.
3. Texto capturado dentro de la app → parser → propuesta → confirmar → transacción creada.
4. Los endpoints responden `201`, `401` sin token, `409` duplicado, `413` en archivo > 8 MB y `GET /api/salud` sin token.
5. Simulador de bot con texto, imagen y audio usando el servidor real; la captura aparece en la bandeja.
6. Confirmar una captura del simulador crea la transacción con `origen = bot`; descartar no crea transacción.
7. La app funciona **100 % offline**: con modo avión, el simulador sigue entregando al servidor de loopback.
8. `flutter analyze` limpio y `flutter test` en verde (91 pruebas).
9. **Parte 2:** el bot real registra por chat sin abrir la app; si falta la cuenta o el monto, pregunta y completa; la bandeja permite editar el movimiento registrado.

### Fuera de alcance de la parte 1

Bot real, OCR, transcripción de audio, servicio en primer plano, reportes gráficos, PDF, Drive, presupuestos, deudas, créditos, metas, recurrentes y conversión automática de divisas.

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
- Bloqueo con PIN y biometría opcional (`local_auth`), pospuesto desde la Fase 1.

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
| 1 | 2026-11-23 | Ninguna: MVP local con Drift, CRUD de cuentas/categorías/etiquetas, transacciones manuales, dashboard multimoneda y 37 pruebas en verde |
| 2 | 2026-11-24 | Parte 1 cerrada (bandeja + canal HTTP + parser + simulador). Desviación planificada: bot Baileys, OCR, transcripción y foreground service pasan a prompts posteriores |
| 3 | — | — |
| 4 | — | — |
| 5 | — | — |

Las decisiones nuevas que aparezcan durante las fases se registran en [DECISIONS.md](DECISIONS.md), no en este documento. La arquitectura vigente está en [ARCHITECTURE.md](ARCHITECTURE.md) y el contrato en [API_CONTRACT.md](API_CONTRACT.md).
