# Actualizar la app sin USB (GitHub Releases + Obtainium)

La app no puede instalarse sola (Android exige confirmar el instalador), pero con
**GitHub Actions** publicamos un APK nuevo en cada push y **Obtainium** lo descarga y
ofrece instalarlo con un toque. La firma se mantiene, así que **se actualiza encima y no
borra la base de datos**.

## Requisito único: guardar la llave de firma como secreto

El APK debe estar firmado siempre con la misma llave que la app ya instalada. Este proyecto
usa la llave de **depuración** (`~/.android/debug.keystore` del PC donde se compiló).

1. Abre en el PC el archivo `debug-keystore.base64.txt` (está en `Downloads\gestor_setup\`),
   selecciona todo y copia.
2. En GitHub, entra al repositorio → **Settings → Secrets and variables → Actions →
   New repository secret**.
3. Nombre: **`DEBUG_KEYSTORE_BASE64`**
4. Valor: pega el contenido del archivo y guarda.
5. Ve a **Actions → APK Release → Run workflow** (o vuelve a ejecutar el run que falló).

> Es una llave de **desarrollo**, no una llave de producción. En la Fase 5 se reemplaza por
> una llave de release real. No la compartas en público más allá de este secreto.

## Cómo funciona

- Cada push a `main` (o ejecución manual) compila el APK en GitHub Actions.
- Se crea una **release** con el APK (`gestor-finanzas-N.apk`), `versionCode = 1000 + N`.
- Obtainium revisa la última release y ofrece actualizar; al instalar, Android conserva los
  datos porque la firma es la misma.

## Instalar Obtainium (una vez)

1. Instala **Obtainium** desde F-Droid: <https://f-droid.org/packages/dev.imranr.obtainium/>
2. Abre Obtainium → **Add App**.
3. En *App Source URL* pega:
   `https://github.com/juanmartindiaz/Finanzas_juanmar`
4. Deja la configuración por defecto (GitHub Releases, APK). Guarda.
5. Permite a Obtainium instalar apps desconocidas.
6. Cuando salga una versión nueva, pulsa **Update** y confirma el instalador.

## Instalación manual (sin Obtainium)

En el teléfono abre:
<https://github.com/juanmartindiaz/Finanzas_juanmar/releases/latest>

Descarga el `.apk` y tócalo para instalar encima de la versión actual.

## Notas

- El primer APK de CI tendrá un `versionCode` mayor (1000+N) que el actual, así que se
  acepta como actualización.
- No desinstales la app: la firma es la misma y los datos se conservan.
- El workflow está en `.github/workflows/apk-release.yml`.
- Si el workflow falla por el secreto, revisa que el nombre sea exacto
  `DEBUG_KEYSTORE_BASE64`.
