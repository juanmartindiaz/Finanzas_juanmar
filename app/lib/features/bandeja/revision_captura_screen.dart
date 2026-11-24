import 'package:material_ui/material_ui.dart';

import '../transactions/transaccion_form_screen.dart';

/// Pantalla de revisión de una captura.
///
/// Reutiliza el formulario de transacción de la Fase 1 (sin duplicar UI): el
/// formulario recibe el id de la captura, la prellena con la propuesta y al
/// confirmar crea la transacción real.
class RevisionCapturaScreen extends StatelessWidget {
  const RevisionCapturaScreen({super.key, required this.capturaId});

  final int? capturaId;

  @override
  Widget build(BuildContext context) {
    if (capturaId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Revisar captura')),
        body: const Center(child: Text('La captura no existe.')),
      );
    }
    return TransaccionFormScreen(capturaId: capturaId);
  }
}
