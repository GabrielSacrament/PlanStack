import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_nap1_dev_web/Navegacao/BarraLateral.dart';

void main() {
  testWidgets('expande e recolhe sem overflow transitório', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              BarraLateral(indiceAtual: 0, aoSelecionar: (_) {}),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'estado inicial');

    await tester.tap(find.byIcon(Icons.arrow_left));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'recolhido');
    expect(find.text('MENU'), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_right));
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 10));
      expect(
        tester.takeException(),
        isNull,
        reason: 'overflow durante expansão no frame $i',
      );
    }

    expect(find.text('MENU'), findsOneWidget);
  });
}
