import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'data/database/arranque_bd.dart';
import 'data/database/sembrador.dart';
import 'data/providers.dart';
import 'data/repositories/capturas_repository.dart';
import 'data/repositories/categorias_repository.dart';
import 'data/repositories/configuracion_repository.dart';
import 'data/repositories/cuentas_repository.dart';
import 'data/repositories/etiquetas_repository.dart';
import 'data/repositories/transacciones_repository.dart';
import 'services/whatsapp_bridge/almacen_adjuntos.dart';
import 'services/whatsapp_bridge/servidor_capturas.dart';

/// Punto de entrada (Fase 2 parte 1: bandeja de capturas + canal HTTP).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final AppDatabase db = await abrirBaseDeDatosConRespaldo();
    await SembradorCategorias(db).ejecutarSiHaceFalta();

    final ConfiguracionRepository configuracion = ConfiguracionRepository(db);
    await configuracion.asegurarValoresIniciales();

    final AlmacenAdjuntos almacen = AlmacenAdjuntos();
    final ServidorCapturas servidor = ServidorCapturas(
      configuracion: configuracion,
      capturas: CapturasRepository(
        db,
        TransaccionesRepository(db),
      ),
      categorias: CategoriasRepository(db),
      etiquetas: EtiquetasRepository(db),
      cuentas: CuentasRepository(db),
      almacen: almacen,
    );
    // Si el puerto está ocupado, la app sigue funcionando sin servidor
    // (Ajustes muestra el error).
    try {
      await servidor.iniciar();
    } on Object {
      // El error queda en servidor.ultimoError.
    }

    runApp(
      ProviderScope(
        overrides: [
          dbProvider.overrideWith((Ref ref) => db),
          servidorCapturasProvider.overrideWith((Ref ref) => servidor),
        ],
        child: const GestorFinanzasApp(),
      ),
    );
  } on ErrorArranqueBase catch (error) {
    runApp(_ArranqueFallido(error: error));
  }
}

/// Aplicación "Gestor Finanzas".
class GestorFinanzasApp extends StatelessWidget {
  const GestorFinanzasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: const Locale('es', 'CO'),
      supportedLocales: const <Locale>[Locale('es', 'CO'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: appRouter,
    );
  }
}

class _ArranqueFallido extends StatelessWidget {
  const _ArranqueFallido({required this.error});

  final ErrorArranqueBase error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'No se pudo abrir la base de datos',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(error.mensaje, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  error.detalle?.toString() ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
