import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:projeto_nap1_dev_web/main.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  testWidgets('navega entre início, planejamentos e agenda', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const AppNap());
    await tester.pump(const Duration(seconds: 4));

    expect(find.text('Seja bem-vindo(a) ao BSCSuite!'), findsOneWidget);
    expect(find.text('Planejamentos'), findsWidgets);
    expect(find.text('Agenda'), findsWidgets);

    await tester.tap(find.text('Planejamentos').first);
    await tester.pump();

    expect(find.text('Novo planejamento'), findsOneWidget);
    expect(find.text('Total de planejamentos'), findsOneWidget);

    await tester.tap(find.text('Agenda').first);
    await tester.pump();

    expect(find.text('Resumo'), findsOneWidget);
    expect(find.text('Calendário'), findsOneWidget);
    expect(find.text('Todos os planejamentos'), findsOneWidget);
  });

  testWidgets('navega no layout compacto sem overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const AppNap());
    await tester.pump(const Duration(seconds: 4));

    expect(find.text('Seja bem-vindo(a) ao BSCSuite!'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'home compacta');

    await tester.tap(find.byIcon(Icons.event_note_outlined).first);
    await tester.pump();

    expect(find.text('Novo planejamento'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'planejamentos compacta');

    await tester.tap(find.byIcon(Icons.calendar_month_outlined).first);
    await tester.pump();

    expect(find.text('Resumo'), findsOneWidget);
    expect(find.text('Calendário'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'agenda compacta');
  });
}
