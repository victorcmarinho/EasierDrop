import 'package:easier_drop/components/hover_icon_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

void main() {
  testWidgets('HoverIconButton estados de hover e pressionado', (tester) async {
    int taps = 0;
    await tester.pumpWidget(
      MacosApp(
        home: Center(
          child: HoverIconButton(
            icon: const Icon(Icons.add),
            onPressed: () => taps++,
            semanticsLabel: 'Adicionar',
            semanticsHint: 'Adicionar item',
          ),
        ),
      ),
    );
    await tester.pump();
    final sem = find.bySemanticsLabel('Adicionar');
    expect(sem, findsOneWidget);

    await tester.tap(sem);
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('HoverIconButton desativado não recebe toque', (tester) async {
    int taps = 0;
    await tester.pumpWidget(
      const MacosApp(
        home: Center(
          child: HoverIconButton(
            icon: Icon(Icons.remove),
            enabled: false,
            semanticsLabel: 'Desativado',
          ),
        ),
      ),
    );
    await tester.pump();
    final sem = find.bySemanticsLabel('Desativado');
    await tester.tap(sem);
    await tester.pump();
    expect(taps, 0);
  });

  testWidgets('HoverIconButton destaque de foco sem semântica', (
    tester,
  ) async {
    int taps = 0;
    await tester.pumpWidget(
      MacosApp(
        home: Center(
          child: HoverIconButton(
            icon: const Icon(Icons.star),
            onPressed: () => taps++,
            addSemantics: false,
          ),
        ),
      ),
    );
    await tester.pump();
    final finder = find.byIcon(Icons.star);
    expect(finder, findsOneWidget);
    await tester.tap(finder);
    await tester.pump();
    expect(taps, 1);
  });
}
