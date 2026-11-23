import 'package:material_ui/material_ui.dart';

import '../../core/utils/dinero.dart';
import '../../core/utils/fechas.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/cuenta.dart';
import '../../domain/entities/transaccion.dart';

/// Fila reutilizable para mostrar una transacción.
class TransaccionItem extends StatelessWidget {
  const TransaccionItem({
    super.key,
    required this.transaccion,
    required this.cuentasPorId,
    required this.categoriasPorId,
    this.onTap,
    this.onEliminar,
  });

  final Transaccion transaccion;
  final Map<int, Cuenta> cuentasPorId;
  final Map<int, Categoria> categoriasPorId;
  final VoidCallback? onTap;
  final VoidCallback? onEliminar;

  Color get _color {
    switch (transaccion.tipo) {
      case TipoTransaccion.ingreso:
        return const Color(0xFF2E7D32);
      case TipoTransaccion.gasto:
        return const Color(0xFFC62828);
      case TipoTransaccion.transferencia:
        return const Color(0xFF1565C0);
    }
  }

  IconData get _icono {
    switch (transaccion.tipo) {
      case TipoTransaccion.ingreso:
        return Icons.south_west;
      case TipoTransaccion.gasto:
        return Icons.north_east;
      case TipoTransaccion.transferencia:
        return Icons.swap_horiz;
    }
  }

  String get _titulo {
    if (transaccion.esTransferencia) {
      final String origen =
          cuentasPorId[transaccion.cuentaId]?.nombre ?? 'Cuenta';
      final String destino =
          cuentasPorId[transaccion.cuentaDestinoId]?.nombre ?? 'Cuenta';
      return 'Transferencia: $origen → $destino';
    }
    final Categoria? categoria =
        categoriasPorId[transaccion.categoriaId];
    return categoria?.nombre ?? transaccion.tipo.etiqueta;
  }

  String get _subtitulo {
    final String cuenta =
        cuentasPorId[transaccion.cuentaId]?.nombre ?? 'Cuenta';
    final String fecha = fechaHoraTexto(
      DateTime.fromMillisecondsSinceEpoch(transaccion.fechaHora),
    );
    final String etiquetas = transaccion.etiquetas.isEmpty
        ? ''
        : ' · ${transaccion.etiquetas.map((elemento) => elemento.nombre).join(', ')}';
    return '$cuenta · $fecha$etiquetas';
  }

  String get _monto {
    switch (transaccion.tipo) {
      case TipoTransaccion.ingreso:
        return '+ ${formatearMonto(transaccion.montoCentavos, transaccion.moneda)}';
      case TipoTransaccion.gasto:
        return '− ${formatearMonto(transaccion.montoCentavos, transaccion.moneda)}';
      case TipoTransaccion.transferencia:
        final String origen =
            formatearMonto(transaccion.montoCentavos, transaccion.moneda);
        if (transaccion.monedaDestino == null ||
            transaccion.monedaDestino == transaccion.moneda) {
          return origen;
        }
        return '$origen → ${formatearMonto(transaccion.montoDestinoEfectivo, transaccion.monedaDestino!)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: _color.withValues(alpha: 0.12),
        child: Icon(_icono, color: _color),
      ),
      title: Text(_titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(_subtitulo, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            _monto,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: _color,
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (onEliminar != null)
            PopupMenuButton<String>(
              onSelected: (String opcion) {
                if (opcion == 'eliminar') {
                  onEliminar!();
                }
              },
              itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'eliminar',
                  child: Text('Borrar movimiento'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
