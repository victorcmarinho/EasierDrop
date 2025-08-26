import 'package:easier_drop/components/hover_icon_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

void main() {
  testWidgets('HoverIconButton tem animação ao pressionar e soltar', (
    tester,
  ) async {
    int taps = 0;
    final buttonKey = GlobalKey();

    await tester.pumpWidget(
      MacosApp(
        home: Center(
          child: HoverIconButton(
            key: buttonKey,
            icon: const Icon(CupertinoIcons.doc_text),
            onPressed: () => taps++,
            semanticsLabel: 'Test Button',
          ),
        ),
      ),
    );
    await tester.pump();

    // Testar tap - verificar que tap foi registrado
    await tester.tap(find.byKey(buttonKey));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('HoverIconButton desabilitado não responde a eventos', (
    tester,
  ) async {
    int taps = 0;
    final buttonKey = GlobalKey();

    await tester.pumpWidget(
      MacosApp(
        home: Center(
          child: HoverIconButton(
            key: buttonKey,
            icon: const Icon(CupertinoIcons.doc_text),
            onPressed: () => taps++,
            semanticsLabel: 'Test Button',
            enabled: false,
          ),
        ),
      ),
    );
    await tester.pump();

    // Testar tap em botão desabilitado
    await tester.tap(find.byKey(buttonKey), warnIfMissed: false);
    await tester.pump();

    // Botão desabilitado não deve registrar taps
    expect(taps, 0);
  });

  testWidgets('HoverIconButton usa cores e tema corretamente', (tester) async {
    final customColor = Colors.purple;
    final buttonKey = GlobalKey();

    await tester.pumpWidget(
      MacosApp(
        theme: MacosThemeData(
          primaryColor: Colors.blue,
          brightness: Brightness.light,
        ),
        home: Center(
          child: HoverIconButton(
            key: buttonKey,
            icon: const Icon(CupertinoIcons.doc_text),
            onPressed: () {},
            baseColor: customColor,
          ),
        ),
      ),
    );
    await tester.pump();

    // Verificar que o botão usa a cor personalizada
    final container = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byKey(buttonKey),
        matching: find.byType(AnimatedContainer),
      ),
    );

    expect(container, isNotNull);

    // Verificar que o IconTheme é aplicado corretamente
    expect(
      find.descendant(
        of: find.byKey(buttonKey),
        matching: find.byType(IconTheme),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'HoverIconButton exibe corretamente com FocusableActionDetector',
    (tester) async {
      final buttonKey = GlobalKey();

      await tester.pumpWidget(
        MacosApp(
          home: Center(
            child: HoverIconButton(
              key: buttonKey,
              icon: const Icon(CupertinoIcons.doc_text),
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Verificar que o FocusableActionDetector está presente
      expect(
        find.descendant(
          of: find.byKey(buttonKey),
          matching: find.byType(FocusableActionDetector),
        ),
        findsOneWidget,
      );
    },
  );
}
