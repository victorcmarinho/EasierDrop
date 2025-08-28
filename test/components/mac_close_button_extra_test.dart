import 'package:easier_drop/components/mac_close_button.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';

void main() {
  testWidgets('MacCloseButton respeita propriedade de tamanho', (tester) async {
    const customSize = 20.0;
    bool buttonPressed = false;

    await tester.pumpWidget(
      MacosApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(
          child: MacCloseButton(
            onPressed: () => buttonPressed = true,
            diameter: customSize,
          ),
        ),
      ),
    );
    await tester.pump();

    final container = find.descendant(
      of: find.byType(MacCloseButton),
      matching: find.byType(AnimatedContainer),
    );
    expect(container, findsOneWidget);

    await tester.tap(find.byType(MacCloseButton));
    await tester.pump();
    expect(buttonPressed, isTrue);
  });

  testWidgets('MacCloseButton interage com gestos', (tester) async {
    await tester.pumpWidget(
      MacosApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(child: MacCloseButton(onPressed: () {})),
      ),
    );
    await tester.pump();

    final gestureDetector = find.descendant(
      of: find.byType(MacCloseButton),
      matching: find.byType(GestureDetector),
    );
    expect(gestureDetector, findsOneWidget);
  });

  testWidgets('MacCloseButton usa semântica correta', (tester) async {
    await tester.pumpWidget(
      MacosApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(child: MacCloseButton(onPressed: () {})),
      ),
    );
    await tester.pump();

    final loc = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.bySemanticsLabel(loc.close), findsOneWidget);

    final mouseRegion = find.descendant(
      of: find.byType(MacCloseButton),
      matching: find.byType(MouseRegion),
    );
    expect(mouseRegion, findsOneWidget);
  });
}
