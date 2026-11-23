# app — Aplicación Flutter "Gestor Finanzas"

Código de la app Android. Estado: **Fase 0** (esqueleto).

- Paquete Android: `com.juanmartin.gestor_finanzas`
- Flutter 3.50.1 · Dart 3.14 · Material a través del paquete `material_ui`
- Rutas: `go_router` (una sola ruta de bienvenida)
- Sin lógica de finanzas todavía

## Ejecutar en el emulador

```bash
cd app
flutter run -d emulator-5554
```

## Estructura

| Carpeta | Contenido |
|---|---|
| `lib/core` | configuración, rutas (`go_router`), tema |
| `lib/data` | base de datos Drift, repositorios, cliente HTTP (Fase 1+) |
| `lib/domain` | entidades y casos de uso (Fase 1+) |
| `lib/features` | pantallas por funcionalidad (bienvenida, cuentas, transacciones…) |
| `lib/services` | OCR, audio, puente WhatsApp, respaldo, notificaciones, tasas |
| `test` | pruebas |

Instrucciones completas del proyecto en el [README raíz](../README.md).
