import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/captura.dart';
import '../domain/entities/categoria.dart';
import '../domain/entities/cuenta.dart';
import '../domain/entities/etiqueta.dart';
import '../domain/entities/subcategoria.dart';
import '../domain/entities/tasa_cambio.dart';
import '../domain/entities/transaccion.dart';
import 'database/app_database.dart';
import 'repositories/capturas_repository.dart';
import 'repositories/categorias_repository.dart';
import 'repositories/configuracion_repository.dart';
import 'repositories/cuentas_repository.dart';
import 'repositories/etiquetas_repository.dart';
import 'repositories/tasas_repository.dart';
import 'repositories/transacciones_repository.dart';
import '../services/whatsapp_bridge/almacen_adjuntos.dart';
import '../services/whatsapp_bridge/cliente_simulador.dart';
import '../services/whatsapp_bridge/servidor_capturas.dart';

/// Base de datos. En `main` se sobrescribe con la instancia ya migrada.
final Provider<AppDatabase> dbProvider = Provider<AppDatabase>((Ref ref) {
  final AppDatabase db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final Provider<CuentasRepository> cuentasRepoProvider =
    Provider<CuentasRepository>(
  (Ref ref) => CuentasRepository(ref.watch(dbProvider)),
);

final Provider<CategoriasRepository> categoriasRepoProvider =
    Provider<CategoriasRepository>(
  (Ref ref) => CategoriasRepository(ref.watch(dbProvider)),
);

final Provider<EtiquetasRepository> etiquetasRepoProvider =
    Provider<EtiquetasRepository>(
  (Ref ref) => EtiquetasRepository(ref.watch(dbProvider)),
);

final Provider<TransaccionesRepository> transaccionesRepoProvider =
    Provider<TransaccionesRepository>(
  (Ref ref) => TransaccionesRepository(ref.watch(dbProvider)),
);

final Provider<CapturasRepository> capturasRepoProvider =
    Provider<CapturasRepository>(
  (Ref ref) => CapturasRepository(
    ref.watch(dbProvider),
    ref.watch(transaccionesRepoProvider),
  ),
);

final Provider<TasasRepository> tasasRepoProvider = Provider<TasasRepository>(
  (Ref ref) => TasasRepository(ref.watch(dbProvider)),
);

final Provider<ConfiguracionRepository> configuracionRepoProvider =
    Provider<ConfiguracionRepository>(
  (Ref ref) => ConfiguracionRepository(ref.watch(dbProvider)),
);

final Provider<AlmacenAdjuntos> almacenAdjuntosProvider =
    Provider<AlmacenAdjuntos>((Ref ref) => AlmacenAdjuntos());

final Provider<ClienteSimulador> clienteSimuladorProvider =
    Provider<ClienteSimulador>(
  (Ref ref) => ClienteSimulador(ref.watch(configuracionRepoProvider)),
);

/// Instancia del servidor local; `main` la sobrescribe.
final Provider<ServidorCapturas> servidorCapturasProvider =
    Provider<ServidorCapturas>((Ref ref) {
  throw UnimplementedError('El servidor se crea en main().');
});

/// Cuentas vigentes (incluye inactivas, para poder reactivarlas).
final StreamProvider<List<Cuenta>> cuentasProvider =
    StreamProvider<List<Cuenta>>(
  (Ref ref) => ref.watch(cuentasRepoProvider).watchTodas(),
);

/// Solo las cuentas activas (para el formulario de transacción).
final Provider<List<Cuenta>> cuentasActivasProvider = Provider<List<Cuenta>>(
  (Ref ref) {
    final AsyncValue<List<Cuenta>> cuentas = ref.watch(cuentasProvider);
    return switch (cuentas) {
      AsyncData<List<Cuenta>>(:final List<Cuenta> value) =>
        value.where((Cuenta cuenta) => cuenta.activa).toList(),
      _ => const <Cuenta>[],
    };
  },
);

final StreamProvider<List<Categoria>> categoriasProvider =
    StreamProvider<List<Categoria>>(
  (Ref ref) => ref.watch(categoriasRepoProvider).watchCategorias(),
);

final StreamProvider<List<Subcategoria>> subcategoriasProvider =
    StreamProvider<List<Subcategoria>>(
  (Ref ref) => ref.watch(categoriasRepoProvider).watchSubcategorias(),
);

final StreamProvider<List<Etiqueta>> etiquetasProvider =
    StreamProvider<List<Etiqueta>>(
  (Ref ref) => ref.watch(etiquetasRepoProvider).watchTodas(),
);

final StreamProvider<List<Transaccion>> transaccionesProvider =
    StreamProvider<List<Transaccion>>(
  (Ref ref) => ref.watch(transaccionesRepoProvider).watchTodas(),
);

final StreamProvider<List<TasaCambio>> tasasProvider =
    StreamProvider<List<TasaCambio>>(
  (Ref ref) => ref.watch(tasasRepoProvider).watchTodas(),
);

final StreamProvider<String> monedaBaseProvider = StreamProvider<String>(
  (Ref ref) => ref.watch(configuracionRepoProvider).watchMonedaBase(),
);

// ---------- Fase 2: capturas y canal ----------

final StreamProvider<List<CapturaEntrante>> capturasProvider =
    StreamProvider<List<CapturaEntrante>>(
  (Ref ref) => ref.watch(capturasRepoProvider).watchTodas(),
);

final StreamProvider<int> capturasPendientesProvider =
    StreamProvider<int>(
  (Ref ref) => ref.watch(capturasRepoProvider).watchPendientes(),
);

final StreamProvider<String> tokenBotProvider = StreamProvider<String>(
  (Ref ref) => ref.watch(configuracionRepoProvider).watchToken(),
);

final StreamProvider<int> puertoBotProvider = StreamProvider<int>(
  (Ref ref) => ref.watch(configuracionRepoProvider).watchPuerto(),
);

final StreamProvider<bool> modoMockProvider = StreamProvider<bool>(
  (Ref ref) => ref.watch(configuracionRepoProvider).watchModoMock(),
);

final StreamProvider<int?> capturaCuentaIdProvider = StreamProvider<int?>(
  (Ref ref) => ref.watch(configuracionRepoProvider).watchCapturaCuentaId(),
);
