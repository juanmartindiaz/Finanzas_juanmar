// Prueba de humo de la Fase 0.
//
// Comprueba que la app arranca con go_router y que la pantalla de bienvenida
// muestra el texto esperado.

import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_finanzas/main.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('la pantalla de bienvenida muestra la Fase 0', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GestorFinanzasApp());
    await tester.pumpAndSettle();

    expect(find.text('Gestor Finanzas — Fase 0'), findsOneWidget);
    expect(
      find.byIcon(Icons.account_balance_wallet_outlined),
      findsOneWidget,
    );
  });
}
