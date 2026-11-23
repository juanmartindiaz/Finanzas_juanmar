import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/categoria.dart';
import '../domain/entities/cuenta.dart';
import '../domain/entities/etiqueta.dart';
import '../domain/entities/subcategoria.dart';
import '../domain/entities/tasa_cambio.dart';
import '../domain/entities/transaccion.dart';
import 'database/app_database.dart';
import 'repositories/categorias_repository.dart';
import 'repositories/configuracion_repository.dart';
import 'repositories/cuentas_repository.dart';
import 'repositories/etiquetas_repository.dart';
import 'repositories/tasas_repository.dart';
import 'repositories/transacciones_repository.dart';

/// Base de datos. En `main` se sobrescribe con la instancia ya sembrada.
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

final Provider<TasasRepository> tasasRepoProvider = Provider<TasasRepository>(
  (Ref ref) => TasasRepository(ref.watch(dbProvider)),
);

final Provider<ConfiguracionRepository> configuracionRepoProvider =
    Provider<ConfiguracionRepository>(
  (Ref ref) => ConfiguracionRepository(ref.watch(dbProvider)),
);

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
