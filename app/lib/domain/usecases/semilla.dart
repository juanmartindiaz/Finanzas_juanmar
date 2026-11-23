/// Regla de la semilla inicial de categorías (lógica pura).
library;

/// La semilla corre una sola vez: si ya se marcó o si ya hay categorías, no se
/// vuelve a insertar. Si el usuario borra todas, no se reinsertan.
bool debeSembrarCategorias({
  required bool yaSeSembro,
  required int categoriasExistentes,
}) {
  return !yaSeSembro && categoriasExistentes == 0;
}
