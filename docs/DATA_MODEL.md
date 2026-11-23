# Modelo de datos — Gestor Finanzas

**Estado: solo documentado. En la Fase 0 no hay ninguna tabla creada.** La base SQLite se implementa con Drift en la **Fase 1** (cuentas, categorías, transacciones), se amplía en la **Fase 3** (presupuestos, deudas, metas, recurrentes) y en la **Fase 4** (tasas de cambio y respaldo). Este documento es el acuerdo sobre qué se guarda y con qué reglas.

Complementos: cómo se calculan los saldos está en este mismo documento, §6; las capturas que llegan por WhatsApp, en [API_CONTRACT.md](API_CONTRACT.md), §8.3.

---

## 1. Convenciones generales

| Convención | Regla | Ejemplo |
|---|---|---|
| Identificadores | `INTEGER PRIMARY KEY AUTOINCREMENT` | `id = 41` |
| Dinero | **Entero de centavos**, nunca `double` ni `REAL` | $18.500 → `1850000` |
| Moneda | `TEXT` de 3 letras ISO 4217 en mayúsculas | `'COP'`, `'USD'` |
| Fecha de calendario | `TEXT` con formato `'YYYY-MM-DD'` | `'2026-11-23'` |
| Instante | `INTEGER` epoch en **milisegundos** | `1795451760000` |
| Booleano | `INTEGER` 0/1 | `activa = 1` |
| Enum | `TEXT` con `CHECK (...)` | `estado = 'pendiente'` |
| Auditoría | `creado_en`, `actualizado_en` (epoch ms, no nulos) | — |
| Borrado lógico | `eliminado_en` (`NULL` = vigente) | `eliminado_en IS NULL` |
| Nombres | Tablas y campos en **singular** y en español | `transaccion`, `saldo_centavos` |

### 1.1 Por qué dos tipos de fecha

- **Fecha de calendario** (`fecha`): el día en que el usuario dice que pasó el gasto. No cambia con la zona horaria ni con el viaje. Se usa para presupuestos, reportes y filtros "por mes".
- **Instante** (`fecha_hora`, `creado_en`): el momento técnico exacto. Sirve para ordenar dentro del día, auditar y sincronizar.

Nunca se convierte una fecha de calendario a instante "al mediodía" para comparar: se comparan texto contra texto (`BETWEEN '2026-11-01' AND '2026-11-30'`), que es exacto y rápido.

### 1.2 Por qué enums en texto y no en números

Un respaldo legible debe poder leerse sin el código. `tipo = 'tarjeta_credito'` se entiende; `tipo = 4` no. El costo es un poco de espacio, que en un teléfono personal es irrelevante. Drift convierte el texto al enum de Dart con `TypeConverter`, y la base rechaza valores inválidos con `CHECK`.

### 1.3 La única excepción: la tasa de cambio

`tasa_cambio.valor` es el **único** número decimal del modelo, porque una tasa no es dinero: es un factor (cuántas unidades de la moneda destino por 1 de la origen). Se guarda como `REAL` con hasta 6 decimales y se redondea al centavo **solo al convertir un monto**.

---

## 2. Diagrama de relaciones

```
   +-----------+  1        N   +--------------+
   | categoria |---------------| subcategoria |
   +-----------+               +--------------+
        | 1
        | N
   +--------------+     N        1     +-------+
   | presupuesto  |-------------------| meta  |
   +--------------+   (meta_id        +-------+
        (categoria_id    opcional)         | 1
         opcional = global)                | N
                                 +-----------------+
                                 | meta_movimiento |
                                 +-----------------+

   +--------+  1      N   +-------------+  N      N   +----------+
   | cuenta |-------------| transaccion |-------------| etiqueta |
   +--------+             +-------------+             +----------+
      | 1                    | 1
      |                     +------> categoria (N:1) y subcategoria (N:1)
      | N                   +------> recibo (0..1 por transaccion)
      +----> credito (1..N)
      +----> recurrente (1..N)

   Independiente: deuda_persona
   Auxiliares: tasa_cambio, configuracion, captura_entrante, mensaje_salida
```

Lectura rápida: una **cuenta** tiene muchas transacciones; una **transacción** pertenece a una cuenta, opcionalmente a una categoría y subcategoría, y puede llevar varias **etiquetas**. Un **recibo** se enlaza a lo sumo con una transacción. Los **presupuestos** miran categorías; las **metas** acumulan movimientos; los **créditos** y **deudas** son registros de seguimiento.

---

## 3. Entidades

En todas las tablas con auditoría: `creado_en` y `actualizado_en` son obligatorios; `eliminado_en` es nulo mientras el registro esté vigente. **Toda consulta de la app filtra `eliminado_en IS NULL`** salvo los reportes de papelera.

### 3.1 `cuenta`

| Campo | Tipo | Nulo | Regla |
|---|---|---|---|
| `id` | INTEGER | No | PK autoincremental |
| `nombre` | TEXT | No | Único entre cuentas vigentes; 1–60 caracteres |
| `tipo` | TEXT | No | `efectivo`, `banco`, `nequi`, `daviplata`, `tarjeta_credito`, `ahorro`, `inversion` |
| `saldo_centavos` | INTEGER | No | **Saldo inicial declarado** al crear la cuenta; puede ser 0 o negativo (tarjeta de crédito) |
| `moneda` | TEXT | No | ISO 4217; por defecto `'COP'` |
| `activa` | INTEGER | No | 1 por defecto; una cuenta inactiva no aparece al registrar |
| `nota` | TEXT | Sí | Texto libre hasta 500 caracteres |
| `creado_en`, `actualizado_en` | INTEGER | No | Epoch ms |
| `eliminado_en` | INTEGER | Sí | Borrado lógico |

Nota: `saldo_centavos` **no** es el saldo que se muestra en el dashboard; ese se calcula (ver §6.1). Guardar el saldo inicial permite corregir la historia sin reescribir transacciones.

### 3.2 `categoria`

| Campo | Tipo | Nulo | Regla |
|---|---|---|---|
| `id` | INTEGER | No | PK |
| `nombre` | TEXT | No | Único por `naturaleza` entre vigentes ("Otros" puede existir en ingreso y en gasto) |
| `naturaleza` | TEXT | No | `ingreso`, `gasto`, `ambos` |
| `icono` | TEXT | Sí | Nombre del icono del catálogo de la app (p. ej. `restaurant`) |
| `color` | TEXT | Sí | `'#RRGGBB'` |
| `predefinida` | INTEGER | No | 1 = viene con la app y no se puede borrar, solo archivar |
| `orden` | INTEGER | No | Para ordenar en pantalla; 0 por defecto |
| `archivada` | INTEGER | No | 0 por defecto; archivar es la alternativa a borrar |
| `creado_en`, `actualizado_en`, `eliminado_en` | INTEGER | — | Auditoría |

### 3.3 `subcategoria`

| Campo | Tipo | Nulo | Regla |
|---|---|---|---|
| `id` | INTEGER | No | PK |
| `categoria_id` | INTEGER | No | FK → `categoria.id`; `ON DELETE RESTRICT` |
| `nombre` | TEXT | No | Único dentro de su categoría entre vigentes |
| `predefinida` | INTEGER | No | 1 = de fábrica |
| `creado_en`, `actualizado_en`, `eliminado_en` | INTEGER | — | Auditoría |

### 3.4 `etiqueta`

| Campo | Tipo | Nulo | Regla |
|---|---|---|---|
| `id` | INTEGER | No | PK |
| `nombre` | TEXT | No | **Único global**, comparación sin distinguir mayúsculas (`COLLATE NOCASE`) |
| `color` | TEXT | Sí | `'#RRGGBB'` |
| `creado_en`, `actualizado_en`, `eliminado_en` | INTEGER | — | Auditoría |

### 3.5 `transaccion`

| Campo | Tipo | Nulo | Regla |
|---|---|---|---|
| `id` | INTEGER | No | PK |
| `tipo` | TEXT | No | `ingreso`, `gasto`, `transferencia` |
| `monto_centavos` | INTEGER | No | **> 0**, en la moneda de la cuenta origen |
| `moneda` | TEXT | No | Por defecto la moneda de `cuenta_id` |
| `cuenta_id` | INTEGER | No | FK → `cuenta.id` |
| `cuenta_destino_id` | INTEGER | Sí | Obligatoria **solo** si `tipo = 'transferencia'`; debe ser distinta de `cuenta_id` |
| `categoria_id` | INTEGER | Sí | Obligatoria si `tipo` es ingreso/gasto; debe ser `NULL` en transferencia |
| `subcategoria_id` | INTEGER | Sí | FK → `subcategoria.id`; si existe, debe pertenecer a `categoria_id` |
| `fecha` | TEXT | No | `'YYYY-MM-DD'`, el día que el usuario declara |
| `fecha_hora` | INTEGER | No | Epoch ms del registro (para ordenar y auditar) |
| `nota` | TEXT | Sí | Hasta 1.000 caracteres |
| `recibo_id` | INTEGER | Sí | FK → `recibo.id`, único; enlace espejo del recibo |
| `tasa_cambio` | REAL | Sí | Obligatoria si `moneda` ≠ moneda de la cuenta o si la transferencia cambia de moneda; > 0 |
| `creado_en`, `actualizado_en`, `eliminado_en` | INTEGER | — | Auditoría y borrado lógico |

### 3.6 `transaccion_etiqueta` (tabla puente)

| Campo | Tipo | Nulo | Regla |
|---|---|---|---|
| `transaccion_id` | INTEGER | No | FK → `transaccion.id`, `ON DELETE CASCADE` |
| `etiqueta_id` | INTEGER | No | FK → `etiqueta.id`, `ON DELETE CASCADE` |

PK compuesta: (`transaccion_id`, `etiqueta_id`). Sin auditoría: si se quita una etiqueta, se borra la fila.

### 3.7 `presupuesto`

| Campo | Tipo | Nulo | Regla |
|---|---|---|---|
| `id` | INTEGER | No | PK |
| `nombre` | TEXT | No | 1–80 caracteres |
| `periodo` | TEXT | No | `mensual`, `semanal`, `quincenal`, `unico` |
| `fecha_inicio` | TEXT | No | `'YYYY-MM-DD'` |
| `fecha_fin` | TEXT | No | `'YYYY-MM-DD'`; ≥ `fecha_inicio`; obligatoria con `periodo = 'unico'` |
| `categoria_id` | INTEGER | Sí | `NULL` = presupuesto **global** de todos los gastos |
| `monto_centavos` | INTEGER | No | **> 0**, en `moneda` |
| `moneda` | TEXT | No | ISO 4217; por defecto `'COP'` |
| `regla_sobrante` | TEXT | No | `reiniciar`, `arrastrar`, `mover_a_meta` |
| `meta_id` | INTEGER | Sí | FK → `meta.id`; **obligatoria** si `regla_sobrante = 'mover_a_meta'`, nula en otro caso |
| `activo` | INTEGER | No | 1 por defecto |
| `creado_en`, `actualizado_en`, `eliminado_en` | INTEGER | — | Auditoría |

### 3.8 `deuda_persona`

| Campo | Tipo | Nulo | Regla |
|---|---|---|---|
| `id` | INTEGER | No | PK |
| `persona` | TEXT | No | Nombre de la persona o alias |
| `direccion` | TEXT | No | `a_favor` (me deben) o `en_contra` (debo) |
| `monto_centavos` | INTEGER | No | **> 0**, monto original |
| `moneda` | TEXT | No | Por defecto `'COP'` |
| `descripcion` | TEXT | Sí | Motivo de la deuda |
| `fecha` | TEXT | No | Cuándo se originó |
| `fecha_vencimiento` | TEXT | Sí | Debe ser ≥ `fecha` |
| `estado` | TEXT | No | `pendiente`, `parcial`, `pagada` |
| `creado_en`, `actualizado_en`, `eliminado_en` | INTEGER | — | Auditoría |

### 3.9 `credito`

| Campo | Tipo | Nulo | Regla |
|---|---|---|---|
| `id` | INTEGER | No | PK |
| `entidad` | TEXT | No | Banco o financiera |
| `descripcion` | TEXT | Sí | Nombre comercial del crédito |
| `monto_centavos` | INTEGER | No | **> 0**, capital prestado |
| `moneda` | TEXT | No | Por defecto `'COP'` |
| `tasa_interes_porcentaje` | REAL | No | ≥ 0; se guarda como número de porcentaje (24,5 = 24,5 %) |
| `periodicidad_tasa` | TEXT | No | `mensual`, `anual` |
| `numero_cuotas` | INTEGER | No | ≥ 1 |
| `valor_cuota_centavos` | INTEGER | No | > 0 |
| `fecha_inicio` | TEXT | No | `'YYYY-MM-DD'` |
| `fecha_fin` | TEXT | No | ≥ `fecha_inicio` |
| `dia_pago` | INTEGER | Sí | 1–31; se ajusta al último día en meses cortos |
| `saldo_centavos` | INTEGER | No | ≥ 0; lo que falta por pagar (capital + intereses) |
| `estado` | TEXT | No | `activo`, `pagado`, `mora` |
| `creado_en`, `actualizado_en`, `eliminado_en` | INTEGER | — | Auditoría |

### 3.10 `meta`

| Campo | Tipo | Nulo | Regla |
|---|---|---|---|
| `id` | INTEGER | No | PK |
| `nombre` | TEXT | No | 1–80 caracteres |
| `tipo` | TEXT | No | `ahorro`, `inversion` |
| `monto_objetivo_centavos` | INTEGER | No | **> 0** |
| `moneda` | TEXT | No | Por defecto `'COP'` |
| `fecha_objetivo` | TEXT | Sí | Fecha límite deseada |
| `cuenta_id` | INTEGER | Sí | FK → `cuenta.id`; cuenta donde vive el dinero de la meta |
| `estado` | TEXT | No | `activa`, `completada`, `pausada` |
| `creado_en`, `actualizado_en`, `eliminado_en` | INTEGER | — | Auditoría |

### 3.11 `meta_movimiento` (hija de `meta`)

| Campo | Tipo | Nulo | Regla |
|---|---|---|---|
| `id` | INTEGER | No | PK |
| `meta_id` | INTEGER | No | FK → `meta.id`, `ON DELETE CASCADE` |
| `tipo` | TEXT | No | `aporte` (+), `rendimiento` (+), `retiro` (−) |
| `monto_centavos` | INTEGER | No | **> 0**; el signo lo da el tipo |
| `fecha` | TEXT | No | `'YYYY-MM-DD'` |
| `nota` | TEXT | Sí | Hasta 500 caracteres |
| `creado_en`, `actualizado_en`, `eliminado_en` | INTEGER | — | Auditoría |

### 3.12 `recurrente`

| Campo | Tipo | Nulo | Regla |
|---|---|---|---|
| `id` | INTEGER | No | PK |
| `monto_centavos` | INTEGER | No | **> 0** |
| `moneda` | TEXT | No | Por defecto `'COP'` |
| `cuenta_id` | INTEGER | No | FK → `cuenta.id` |
| `categoria_id` | INTEGER | No | FK → `categoria.id`; naturaleza compatible con el tipo |
| `subcategoria_id` | INTEGER | Sí | Debe pertenecer a `categoria_id` |
| `tipo` | TEXT | No | `ingreso`, `gasto` (no hay recurrentes de transferencia) |
| `frecuencia` | TEXT | No | `diaria`, `semanal`, `quincenal`, `mensual`, `anual` |
| `intervalo` | INTEGER | No | ≥ 1; "cada 2 semanas" = `semanal` + `2` |
| `proxima_fecha` | TEXT | No | Siguiente ocurrencia |
| `recordatorio_activo` | INTEGER | No | 1 por defecto |
| `dias_aviso` | INTEGER | No | ≥ 0; días antes para notificar |
| `activo` | INTEGER | No | 1 por defecto |
| `creado_en`, `actualizado_en`, `eliminado_en` | INTEGER | — | Auditoría |

### 3.13 `recibo`

| Campo | Tipo | Nulo | Regla |
|---|---|---|---|
| `id` | INTEGER | No | PK |
| `archivo_path` | TEXT | No | Ruta relativa a la carpeta privada de la app |
| `archivo_hash` | TEXT | No | SHA-256 en hexadecimal; **único** (evita duplicados) |
| `mime` | TEXT | No | `image/jpeg`, `image/png`, `application/pdf` |
| `ocr_texto` | TEXT | Sí | Texto plano que devolvió ML Kit |
| `ocr_json` | TEXT | Sí | JSON con bloques, líneas y coordenadas |
| `estado` | TEXT | No | `pendiente`, `confirmado`, `descartado` |
| `transaccion_id` | INTEGER | Sí | FK → `transaccion.id`; único; se llena al confirmar |
| `creado_en` | INTEGER | No | Epoch ms |
| `procesado_en` | INTEGER | Sí | Cuándo terminó el OCR o la confirmación |

### 3.14 `tasa_cambio`

| Campo | Tipo | Nulo | Regla |
|---|---|---|---|
| `id` | INTEGER | No | PK |
| `moneda_origen` | TEXT | No | ISO 4217 |
| `moneda_destino` | TEXT | No | ISO 4217, distinta de la origen |
| `valor` | REAL | No | > 0; unidades de destino por 1 de origen |
| `fecha` | TEXT | No | `'YYYY-MM-DD'` del día de la tasa |
| `fuente` | TEXT | No | `manual`, `trm`, `api_abierta` |
| `creado_en` | INTEGER | No | Epoch ms |

Restricción única: (`moneda_origen`, `moneda_destino`, `fecha`). No se borra historia: si la tasa se corrige, se actualiza `valor` y se conserva `creado_en`.

### 3.15 `configuracion` (auxiliar, clave/valor)

| Campo | Tipo | Nulo | Regla |
|---|---|---|---|
| `clave` | TEXT | No | PK; identificador corto y estable |
| `valor` | TEXT | No | Siempre texto; la app lo interpreta |
| `actualizado_en` | INTEGER | No | Epoch ms |

Claves previstas:

| Clave | Valores posibles | Para qué |
|---|---|---|
| `moneda_base` | `COP` | Moneda de los reportes |
| `zona_horaria` | `America/Bogota` | Horarios de reportes y recordatorios |
| `tema` | `claro`, `oscuro`, `sistema` | Apariencia |
| `bloqueo_biometria` | `0`, `1` | Usar huella si el teléfono la tiene |
| `bot_modo_mock` | `0`, `1` | Modo simulado del bot (ver [API_CONTRACT.md](API_CONTRACT.md)) |
| `bot_puerto_app` | `8787` | Puerto del servidor de la app |
| `bot_puerto` | `8788` | Puerto del servidor del bot |
| `bot_token` | cadena aleatoria | Token de `X-Bot-Token` |
| `bot_ultima_config_version` | entero | Evita reenviar configuración |
| `respaldo_auto_dias` | `0`, `1`, `7` | Frecuencia del respaldo en Drive |
| `ultimo_respaldo_en` | epoch ms | Para avisar si hay respaldo viejo |

### 3.16 `captura_entrante` (auxiliar del canal, Fase 2)

No es una entidad financiera: es la bandeja donde el bot deja lo que llega antes de que el usuario confirme. Existe porque el contrato responde `id_captura` (ver [API_CONTRACT.md](API_CONTRACT.md), §8.3).

| Campo | Tipo | Nulo | Regla |
|---|---|---|---|
| `id` | INTEGER | No | PK; es el `id_captura` del contrato |
| `id_mensaje` | TEXT | No | **Único**; llave de idempotencia del mensaje de WhatsApp |
| `remitente` | TEXT | No | Número en formato internacional |
| `tipo` | TEXT | No | `texto`, `audio`, `imagen` |
| `recibido_en` | INTEGER | No | Epoch ms del mensaje |
| `texto_original` | TEXT | Sí | Texto recibido o transcripción del audio |
| `archivo_path` | TEXT | Sí | Copia local del audio o imagen |
| `recibo_id` | INTEGER | Sí | FK → `recibo.id` si la captura era una imagen |
| `estado` | TEXT | No | `pendiente`, `confirmada`, `descartada`, `ignorada` |
| `transaccion_id` | INTEGER | Sí | FK → `transaccion.id` al confirmar |
| `creado_en`, `actualizado_en` | INTEGER | No | Epoch ms |

### 3.17 `mensaje_salida` (auxiliar, cola hacia el bot, Fase 2)

Tampoco es financiera: es la bandeja de lo que la app quiere enviar por WhatsApp (confirmaciones y, en la Fase 4, reportes). El bot la lee con `GET /api/v1/outbox` y confirma con `ack` (ver [API_CONTRACT.md](API_CONTRACT.md), §8.4 y §8.5).

| Campo | Tipo | Nulo | Regla |
|---|---|---|---|
| `id` | INTEGER | No | PK; es el `id` que el bot devuelve en el `ack` |
| `tipo` | TEXT | No | `texto`, `audio`, `imagen` |
| `destinatario` | TEXT | No | Número internacional sin `+` |
| `texto` | TEXT | Sí | Obligatorio si `tipo = 'texto'`; en los demás, pie de foto opcional |
| `adjunto_path` | TEXT | Sí | Ruta local del archivo; el JSON lo codifica a `adjunto_base64` al responder |
| `mime` | TEXT | Sí | Requerido si hay adjunto |
| `estado` | TEXT | No | `pendiente`, `enviado`, `error` (lo cambia el `ack`, nunca el bot directamente en la base) |
| `error` | TEXT | Sí | Mensaje devuelto por el bot cuando `estado = 'error'` |
| `intentos` | INTEGER | No | ≥ 0; contador de entregas fallidas, para no reintentar sin fin |
| `creado_en` | INTEGER | No | Epoch ms |
| `enviado_en` | INTEGER | Sí | Cuándo el bot confirmó `enviado` |

La app guarda el **archivo**, no base64: la base no debe inflarse con megabytes de audio o imagen. La codificación ocurre solo al responder `/outbox`.

---

## 4. Reglas de integridad

1. **Montos positivos:** `monto_centavos > 0` en `transaccion`, `presupuesto`, `meta_movimiento`, `deuda_persona`, `credito`, `recurrente`. Un gasto no se guarda en negativo: el signo lo da `tipo`.
2. **Transferencia:** `cuenta_destino_id` obligatoria, distinta de `cuenta_id`, y `categoria_id = NULL`. Si las monedas difieren, `tasa_cambio` es obligatoria y > 0.
3. **Ingreso/gasto:** `cuenta_destino_id = NULL`, `categoria_id` obligatoria y compatible con `tipo` (categoría de naturaleza `gasto` o `ambos` para gastos; `ingreso` o `ambos` para ingresos).
4. **Subcategoría coherente:** `subcategoria_id` debe pertenecer a `categoria_id`. Se valida en la app **y** con disparador si Drift lo permite.
5. **No borrar con historia:** una categoría, subcategoría, etiqueta o cuenta con transacciones **no se elimina**: la categoría se `archivada = 1`, la cuenta `activa = 0`. Borrar siempre es lógico (`eliminado_en`).
6. **Un recibo, una transacción:** `recibo.transaccion_id` y `transaccion.recibo_id` son espejo. Se escriben en la misma transacción de base de datos; la fuente de verdad es `recibo.transaccion_id`, con índice único que impide dos recibos para el mismo movimiento.
7. **Etiquetas únicas:** no se repite nombre (sin distinguir mayúsculas) ni el par (`transaccion_id`, `etiqueta_id`).
8. **Presupuesto coherente:** `fecha_fin ≥ fecha_inicio`; `meta_id` solo con `regla_sobrante = 'mover_a_meta'`; no se solapan dos presupuestos activos de la misma categoría y periodo.
9. **Meta:** un `retiro` no puede superar el saldo disponible de la meta (validado en la capa de negocio, porque depende de la suma de movimientos).
10. **Crédito:** `numero_cuotas ≥ 1`, `dia_pago` entre 1 y 31, `saldo_centavos ≥ 0`; cuando llega a 0 el estado pasa a `pagado`.
11. **Recurrente:** `proxima_fecha` es la próxima ocurrencia y avanza al registrarse o al omitirse; nunca queda en el pasado sin aviso.
12. **Tasa de cambio:** `valor > 0`, monedas distintas y una sola fila por (`origen`, `destino`, `fecha`).
13. **Fechas válidas:** el texto cumple `'YYYY-MM-DD'` (validación por longitud y formato) y `fecha_vencimiento ≥ fecha` en deudas.
14. **Llaves foráneas activas:** `PRAGMA foreign_keys = ON` en cada apertura de la base. Sin eso, SQLite ignora las FK y la integridad se pierde en silencio.

---

## 5. Índices recomendados

| Tabla | Índice | Motivo |
|---|---|---|
| `transaccion` | (`eliminado_en`, `fecha`) | Listado y reportes por rango de fechas |
| `transaccion` | (`cuenta_id`, `fecha`) | Saldo y extracto de una cuenta |
| `transaccion` | (`categoria_id`, `fecha`) | Presupuestos y gráficas por categoría |
| `transaccion` | (`fecha_hora`) | Orden cronológico fino |
| `transaccion` | (`recibo_id`) único parcial | Un recibo no se repite |
| `transaccion_etiqueta` | (`etiqueta_id`) | Filtrar por etiqueta |
| `subcategoria` | (`categoria_id`) | Desplegables |
| `presupuesto` | (`activo`, `periodo`, `fecha_inicio`) | Presupuestos vigentes del tablero |
| `recurrente` | (`activo`, `proxima_fecha`) | Qué toca notificar hoy |
| `meta_movimiento` | (`meta_id`, `fecha`) | Saldo y avance de la meta |
| `meta_movimiento` | (`eliminado_en`) | Movimientos vigentes |
| `recibo` | (`archivo_hash`) único | Evitar reimportar la misma foto |
| `recibo` | (`estado`) | Bandeja de recibos pendientes |
| `tasa_cambio` | (`moneda_origen`, `moneda_destino`, `fecha`) único | Consulta de la tasa del día |
| `cuenta` | (`activa`) | Cuentas disponibles al registrar |
| `captura_entrante` | (`id_mensaje`) único | Idempotencia del bot |
| `captura_entrante` | (`estado`, `recibido_en`) | Bandeja de pendientes |
| `mensaje_salida` | (`estado`, `creado_en`) | Qué falta entregar y en qué orden |

Criterio: cualquier consulta que corra en la pantalla principal o en un reporte debe tener índice; las consultas de configuración no lo necesitan.

---

## 6. Cálculos derivados

Ninguno se guarda como columna (salvo donde se indica): todos se calculan al vuelo hasta que un reporte demuestre que hace falta cachear.

### 6.1 Saldo de una cuenta

```
saldo = cuenta.saldo_centavos
      + suma(ingresos de la cuenta)
      - suma(gastos de la cuenta)
      + suma(transferencias recibidas en la cuenta)   -> monto * tasa (si cambia de moneda)
      - suma(transferencias enviadas desde la cuenta)
```

Ejemplo: cuenta Efectivo con saldo inicial $200.000; ingreso $50.000, gasto $18.500, transferencia enviada $30.000 a Nequi:

```
20000000 + 5000000 - 1850000 - 3000000 = 20150000 centavos = $201.500
```

Las transferencias **no** cambian el patrimonio total: solo mueven dinero entre cuentas. Por eso el "total" del dashboard suma saldos de cuentas, donde una transferencia ya se descontó de una y se sumó a la otra.

### 6.2 Restante de un presupuesto

```
gastado = suma(gastos del periodo)
          filtrando por presupuesto.categoria_id (y sus subcategorias)
          o todos los gastos si categoria_id es NULL
          convirtiendo cada gasto a presupuesto.moneda
restante = presupuesto.monto_centavos - gastado
```

`restante` puede ser negativo (sobregiro). Al cerrar el periodo, `regla_sobrante` decide: `reiniciar` deja el sobrante atrás; `arrastrar` lo suma al siguiente presupuesto; `mover_a_meta` crea un `meta_movimiento` de tipo `aporte` con el sobrante positivo.

### 6.3 Saldo y avance de una meta

```
saldo_meta = suma(aportes) + suma(rendimientos) - suma(retiros)   (vigentes)
avance_porcentaje = saldo_meta / monto_objetivo_centavos * 100
falta_centavos = max(0, monto_objetivo_centavos - saldo_meta)
```

Ejemplo: objetivo $2.000.000; aportes $600.000, rendimiento $12.400, retiro $100.000 → saldo $512.400 (25,62 %); faltan $1.487.600.

### 6.4 Avance de un crédito

No existe tabla de pagos de crédito en esta versión: el pago se registra como transacción de **gasto** (categoría "Deudas") y el usuario actualiza `saldo_centavos`. Con eso:

```
pagado = monto_centavos - saldo_centavos
cuotas_pagadas_aprox = redondear(pagado / valor_cuota_centavos)
avance_porcentaje = pagado / monto_centavos * 100
interes_estimado_total = monto * (tasa/100) * (periodicidad == 'mensual' ? meses : anios)
```

La app muestra "cuotas pagadas (aproximado)" y **no** promete exactitud contable: los intereses reales dependen del banco. Esta limitación está anotada en [PHASES.md](PHASES.md), Fase 3.

### 6.5 Conversión de monedas

```
monto_en_destino = redondear(monto_centavos * tasa_cambio.valor)
```

La tasa se toma de `tasa_cambio` por (`origen`, `destino`, `fecha`) y, si no existe la del día, se usa la más reciente anterior (nunca una futura). Los reportes siempre convierten a `COP`. Si no hay ninguna tasa disponible, el reporte marca el monto como "sin convertir" en lugar de inventar un valor.

---

## 7. Relación del modelo con las fases

| Fase | Entidades que se crean | Qué se puede hacer al terminar |
|---|---|---|
| 0 | Ninguna (solo este documento) | Nada financiero |
| 1 | `cuenta`, `categoria`, `subcategoria`, `etiqueta`, `transaccion`, `transaccion_etiqueta`, `configuracion` (parcial) | Registrar gastos/ingresos/transferencias a mano y ver saldos |
| 2 | `recibo`, `captura_entrante`, `mensaje_salida` | Capturar por OCR, voz, texto y WhatsApp con revisión |
| 3 | `presupuesto`, `deuda_persona`, `credito`, `meta`, `meta_movimiento`, `recurrente` | Planear y hacer seguimiento |
| 4 | `tasa_cambio`, `configuracion` (respaldo completo) | Reportes, PDF, multimoneda real y respaldo en Drive |

Detalle de entregables y criterios en [PHASES.md](PHASES.md).

---

## 8. Ejemplo ilustrativo de tabla (SQL)

Este bloque **no se ejecuta todavía**; muestra cómo se traducen las convenciones anteriores a Drift/SQLite. La implementación real vivirá en `app/lib/data/`.

```sql
CREATE TABLE transaccion (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  tipo              TEXT    NOT NULL CHECK (tipo IN ('ingreso','gasto','transferencia')),
  monto_centavos    INTEGER NOT NULL CHECK (monto_centavos > 0),
  moneda            TEXT    NOT NULL CHECK (length(moneda) = 3),
  cuenta_id         INTEGER NOT NULL REFERENCES cuenta(id),
  cuenta_destino_id INTEGER REFERENCES cuenta(id),
  categoria_id      INTEGER REFERENCES categoria(id),
  subcategoria_id   INTEGER REFERENCES subcategoria(id),
  fecha             TEXT    NOT NULL,
  fecha_hora        INTEGER NOT NULL,
  nota              TEXT,
  recibo_id         INTEGER UNIQUE REFERENCES recibo(id),
  tasa_cambio       REAL    CHECK (tasa_cambio IS NULL OR tasa_cambio > 0),
  creado_en         INTEGER NOT NULL,
  actualizado_en    INTEGER NOT NULL,
  eliminado_en      INTEGER,
  CHECK (
    (tipo = 'transferencia' AND cuenta_destino_id IS NOT NULL
      AND cuenta_destino_id <> cuenta_id AND categoria_id IS NULL)
    OR
    (tipo IN ('ingreso','gasto') AND cuenta_destino_id IS NULL
      AND categoria_id IS NOT NULL)
  )
);
```

### 8.1 Migraciones

- Drift lleva `schemaVersion` entero; cada fase que cambia el esquema sube la versión y agrega su paso de migración.
- Regla: **nunca** se borra una columna en una migración que pueda tener datos; se deja de usar y se documenta.
- Antes de migrar, la app copia el archivo SQLite a `gestor_finanzas.backup.sqlite`; si la migración falla, restaura esa copia y avisa.
- Los respaldos de Drive guardan la `schemaVersion` para que la restauración sepa si hace falta migrar.

---

## 9. Limitaciones conocidas del modelo

| Limitación | Efecto | Se resuelve en |
|---|---|---|
| Sin tabla de abonos de deudas | `estado` y montos se actualizan a mano | Fase 5 si el dueño lo pide |
| Sin tabla de pagos de crédito | Cuotas pagadas son aproximadas | Fase 5 si el dueño lo pide |
| Tasa de cambio decimal (`REAL`) | Pequeño redondeo al convertir | Aceptado |
| Sin cifrado de la base | Legible para quien tenga el teléfono | Aceptado (ver [DECISIONS.md](DECISIONS.md)) |
| Sin historial de saldos | El dashboard calcula, no guarda fotos diarias | Fase 4, si los reportes lo necesitan |
