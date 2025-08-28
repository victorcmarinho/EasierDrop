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

    await tester.tap(find.byKey(buttonKey), warnIfMissed: false);
    await tester.pump();

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

    final container = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byKey(buttonKey),
        matching: find.byType(AnimatedContainer),
      ),
    );

    expect(container, isNotNull);

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
