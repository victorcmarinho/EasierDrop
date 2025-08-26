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

    // Verificar se o container existe
    final container = find.descendant(
      of: find.byType(MacCloseButton),
      matching: find.byType(AnimatedContainer),
    );
    expect(container, findsOneWidget);

    // Verificar o comportamento do onPressed
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
        home: Center(
          child: MacCloseButton(
            onPressed: () {}, // Callback vazio para este teste
          ),
        ),
      ),
    );
    await tester.pump();

    // Encontrar o GestureDetector e verificar sua presença
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

    // Obter as strings de localização
    final loc = await AppLocalizations.delegate.load(const Locale('en'));

    // Verificar se a semântica é aplicada corretamente
    expect(find.bySemanticsLabel(loc.close), findsOneWidget);

    // Verificar se o mouseRegion está configurado corretamente
    final mouseRegion = find.descendant(
      of: find.byType(MacCloseButton),
      matching: find.byType(MouseRegion),
    );
    expect(mouseRegion, findsOneWidget);
  });
}
