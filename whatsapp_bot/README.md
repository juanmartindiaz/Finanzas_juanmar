# Bot de WhatsApp — Gestor Finanzas

Componente **separado** de la app. Corre en el mismo teléfono Android, dentro de
**Termux**, con un **número secundario** de WhatsApp. Recibe tus mensajes
(texto, audio, foto), los entrega a la app por `http://127.0.0.1:8787` y te
responde por WhatsApp. **El bot no crea transacciones**: la app las propone y tú
las confirmas en la bandeja.

Repositorio: <https://github.com/juanmartindiaz/Finanzas_juanmar>

> **Estado:** Fase 2 parte 2 (Prompt 3). Sin OCR (2.4), sin transcripción de
> audio (2.5), sin servicio en primer plano en la app (2.6) y sin cola de
> salida/reportes (`mensaje_salida` es Fase 4).

---

## 1. Requisitos (en tu teléfono)

1. **Termux instalado desde F-Droid** (NO desde Play Store; la versión de Play
   está abandonada): <https://f-droid.org/packages/com.termux/>
2. **Número secundario** de WhatsApp con la sesión disponible para escanear QR.
3. La app **Gestor Finanzas** instalada y abierta al menos una vez.
4. Token de la app: **Ajustes → Canal bot** (botón *Copiar*).
5. Node.js dentro de Termux (se instala en el paso 2).

---

## 2. Instalar dependencias en Termux

```bash
pkg update && pkg upgrade -y
pkg install nodejs git -y
node --version    # debe ser 20 o superior
```

## 3. Copiar el bot al teléfono

Método recomendado: clonar el repositorio en Termux.

```bash
cd ~
git clone https://github.com/juanmartindiaz/Finanzas_juanmar.git gestor_finanzas
cd gestor_finanzas/whatsapp_bot
```

Repositorio: <https://github.com/juanmartindiaz/Finanzas_juanmar>

Para actualizar más adelante (cuando haya cambios nuevos):

```bash
cd ~/gestor_finanzas
git pull
cd whatsapp_bot
npm install
```

Alternativa por USB: copia la carpeta `whatsapp_bot/` al almacenamiento del
teléfono y muévela con `termux-setup-storage` + `cp` (menos cómoda para
actualizar).

## 4. Instalar las dependencias del bot

```bash
cd ~/gestor_finanzas/whatsapp_bot
npm install
```

## 5. Configurar `config.json`

```bash
cp config.example.json config.json
nano config.json
```

Contenido:

```json
{
  "numero_autorizado": "573001234567",
  "token": "PEGA_AQUI_EL_TOKEN_DE_AJUSTES_CANAL_BOT",
  "puerto_app": 8787
}
```

- `numero_autorizado`: **solo dígitos** de tu número principal (el que usará el
  bot para hablarte). **No hay autorización automática:** si está vacío, el bot
  no procesa ningún mensaje y muestra una advertencia.
- `token`: el que muestra la app en Ajustes → Canal bot.
- `puerto_app`: 8787 por defecto; cámbialo solo si lo cambiaste en la app.

Opcional: si en el log aparece `Mensaje ignorado ... (LID 690...)` incluso
después de actualizar, agrega el LID que muestra el log como respaldo:

```json
"lid_autorizado": "69072452640988"
```

El bot intenta traducir el LID al número automáticamente con Baileys; este
campo es solo un plan B para versiones de WhatsApp que no entregan el número.

Si falta el número y ejecutas `node index.js` en una terminal interactiva, el
bot te lo pedirá una vez y lo guardará. Si no hay terminal interactiva, edita el
archivo a mano.

## 6. Permisos de Android para que no se duerma

1. **Ajustes de Android → Aplicaciones → Termux → Batería → Sin restricciones**.
2. Desactiva la optimización de batería para Termux (algunos teléfonos lo piden
   aparte).
3. El bot ejecuta `termux-wake-lock` automáticamente al arrancar (si está
   disponible). Eso evita que Android suspenda la CPU mientras el bot corre.

## 7. Primera ejecución (QR)

1. Abre la app Gestor Finanzas y déjala en primer plano.
2. En Termux:

```bash
cd ~/gestor_finanzas/whatsapp_bot
node index.js
```

3. En la terminal aparece un **QR**. Escanéalo desde el **número secundario**
   (WhatsApp → Ajustes → Dispositivos vinculados → Vincular dispositivo).
4. Cuando veas `Conectado a WhatsApp.` el bot está listo.

La sesión queda guardada en `auth/`; en los siguientes arranques no pide QR.

## 8. Qué hace (y qué no)

| Mensaje | Acción |
|---|---|
| Texto con monto (`gasté 18.500 en mercado`) | Envía a la app; responde “✅ Recibido (#xxxx). Revísalo en la app.” |
| Texto sin monto (`hola`) | **No crea captura**; responde con un ejemplo de cómo escribir |
| Foto | La guarda como captura; responde “📷 Foto guardada…”. **Sin OCR:** el monto lo pones tú en la app |
| Audio | Lo guarda como captura; responde “🎤 Audio guardado…”. **Sin transcripción todavía** |
| Video, sticker, documento, ubicación, contacto | Responde “⚠️ Formato no soportado…” y **no** crea captura |
| Grupo o estado | Se ignoran |
| Número no autorizado | Se ignora en silencio (solo queda en el log) |

Reglas:

- **Antes de entregar, guarda el mensaje en la cola** (`cola/pendientes/`).
- Si la app está cerrada (conexión rechazada) o responde 5xx, responde
  “⏳ Guardado, esperando app” y **reintenta cada 30 s**. Al lograrlo responde
  “✅ Procesado (#xxxx)…”.
- `401`: avisa del token y **no** reintenta. `413`: avisa del tamaño y no
  encola. `409`: se trata como entregado (idempotencia).
- Tú confirmas en la bandeja de la app; el bot nunca guarda finanzas.

## 9. Arranque automático con Termux:Boot

1. Instala **Termux:Boot** desde F-Droid y ábrelo una vez.
2. Crea el script:

```bash
mkdir -p ~/.termux/boot
cat > ~/.termux/boot/start-bot.sh <<'EOF'
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
cd ~/gestor_finanzas/whatsapp_bot
node index.js >> logs/bot.log 2>&1 &
EOF
chmod +x ~/.termux/boot/start-bot.sh
```

3. Reinicia el teléfono. El bot debe arrancar solo; revisa `logs/bot.log`.

## 10. Ver los logs

```bash
cd ~/gestor_finanzas/whatsapp_bot
ls logs
tail -n 80 logs/bot-*.log
```

Los logs también salen por stdout. Archivo diario `logs/bot-AAAA-MM-DD.log` con
7 días de retención. El contenido de los mensajes **no** se registra salvo que
ejecutes con `DEBUG=1`.

> Si usas el arranque con Termux:Boot del §9, la salida cruda de arranque también
> se guarda en `logs/bot.log`; para el día a día usa el archivo con fecha.

## 11. Reiniciar la sesión de WhatsApp

Si el teléfono cerró la sesión del número secundario (o quieres cambiar de
número):

```bash
rm -rf auth/
node index.js
```

Vuelve a escanear el QR con el número secundario.

## 12. Comprobar que la app responde (sanity)

Con la app abierta, desde Termux:

```bash
curl http://127.0.0.1:8787/api/salud
# {"ok":true,"version":"0.3.0"}
```

Si falla: revisa que la app esté abierta, que el puerto coincida y que el token
de `config.json` sea el de Ajustes → Canal bot.

## 13. Advertencia importante

**Baileys es una librería no oficial.** WhatsApp puede **banear** un número si
detecta comportamiento automatizado. Usa **siempre un número secundario**, nunca
tu número principal. Este bot está diseñado para hablar solo con tu número
autorizado (no responde a grupos ni a desconocidos), lo que reduce el riesgo,
pero no lo elimina. Es tu decisión y tu riesgo.

## 14. Protocolo de prueba en tu teléfono

Hazlo en este orden y anota el resultado de cada paso:

1. **Salud:** app abierta, `curl http://127.0.0.1:8787/api/salud` en Termux debe
   responder `{"ok":true,...}`.
2. **Texto:** desde tu número principal envía `gasté 18.500 en mercado`.
   Esperado: respuesta “✅ Recibido (#xxxx)…” en ~2 s; en la app, bandeja →
   captura → confirmas → aparece la transacción en el dashboard.
3. **Foto:** envía una foto de recibo. Esperado: “📷 Foto guardada…” y la imagen
   en la bandeja (sin OCR; completas a mano).
4. **Audio:** envía una nota de voz. Esperado: “🎤 Audio guardado…” y el audio
   en la bandeja (sin transcripción todavía).
5. **App cerrada:** fuerza la detención de la app (Ajustes de Android →
   Aplicaciones → Gestor Finanzas → Forzar detención). Envía `gasté 5.000 en
   taxi`. Esperado: “⏳ Guardado, esperando app”; abre la app y en ≤ 30 s debe
   llegar “✅ Procesado…” y la captura en la bandeja.
6. **No autorizado:** con un tercer número escribe al bot. Esperado: el bot no
   responde y no aparece nada en la bandeja.
7. **Charla:** envía `hola`. Esperado: “No identifiqué un monto ni categoría…” y
   **no** aparece captura.
8. **Formato:** envía un sticker o video. Esperado: “⚠️ Formato no soportado…” y
   sin captura.
9. **Token:** cambia el token en `config.json` por uno incorrecto y reinicia.
   Esperado: al enviar un texto, aviso de autenticación y nada en la bandeja.
   Vuelve a poner el token correcto.

Reporta qué pasó en cada paso (texto de respuesta, si apareció la captura y qué
mostró el log) para iterar antes de la Fase 2.4.

## 15. Desarrollo y pruebas (en el PC)

```bash
cd whatsapp_bot
npm install
npm test
```

- 23 pruebas con **transporte falso** (sin WhatsApp) y un servidor HTTP mock:
  texto/foto/audio, códigos 401/409/413/5xx, conexión rechazada, cola
  persistente, reinicio simulado, número autorizado (incluido el caso “sin
  configurar”), formatos no soportados, charla, posición del monto, backoff,
  logout y logger.
- No se prueba Baileys real ni el QR en el PC. Eso se valida en el teléfono con
  el protocolo de §14.

## 16. Estructura

```
whatsapp_bot/
├── index.js              # arranque + cableado real
├── package.json          # baileys, qrcode-terminal, vitest (dev)
├── config.example.json   # plantilla (config.json real está ignorado)
├── auth/                 # sesión de Baileys (ignorado)
├── cola/
│   ├── pendientes/       # mensajes por entregar (ignorado)
│   └── entregados/       # auditoría (ignorado)
├── logs/                 # logs diarios (ignorado)
├── lib/
│   ├── wa.js             # Baileys: sesión, QR, reconexión, descarga
│   ├── app-client.js     # cliente HTTP a la app
│   ├── bot.js            # filtros, cola, reintentos, respuestas
│   ├── cola.js           # persistencia de la cola
│   ├── mensajes.js       # textos de respuesta y heurísticas
│   ├── config.js         # carga/guarda config y prompt inicial
│   ├── reconexion.js     # backoff y decisión ante logout
│   └── logger.js         # stdout + logs/bot-AAAA-MM-DD.log
├── test/                 # Vitest + transporte falso + servidor mock
└── README.md             # esta guía
```
