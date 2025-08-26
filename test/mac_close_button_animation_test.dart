import 'package:easier_drop/components/mac_close_button.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

void main() {
  testWidgets(
    'MacCloseButton registra o hover e o pressionamento corretamente',
    (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        MacosApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Center(child: MacCloseButton(onPressed: () => taps++)),
        ),
      );
      await tester.pump();
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      final btn = find.bySemanticsLabel(loc.close);
      final center = tester.getCenter(btn);

      // Verificar a presença do AnimatedOpacity e AnimatedContainer
      expect(find.byType(AnimatedOpacity), findsOneWidget);
      expect(find.byType(AnimatedContainer), findsOneWidget);

      // Testar hover
      tester.binding.handlePointerEvent(PointerHoverEvent(position: center));
      await tester.pump();

      // Testar press
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        pointer: 1,
      );
      await gesture.addPointer(location: center);
      await gesture.down(center);
      await tester.pump();

      // Verificar Transform após o press
      expect(find.byType(Transform), findsOneWidget);

      // Testar release e verificar contagem de taps
      await gesture.up();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(taps, 1);
    },
  );

  testWidgets('MacCloseButton registers tap correctly when hovered first', (
    tester,
  ) async {
    int taps = 0;
    await tester.pumpWidget(
      MacosApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(child: MacCloseButton(onPressed: () => taps++)),
      ),
    );
    await tester.pump();
    final loc = await AppLocalizations.delegate.load(const Locale('en'));
    final btn = find.bySemanticsLabel(loc.close);
    final center = tester.getCenter(btn);

    // Hover, depois tap
    tester.binding.handlePointerEvent(PointerHoverEvent(position: center));
    await tester.pump();
    await tester.tap(btn);
    await tester.pump();
    expect(taps, 1);
  });
}
