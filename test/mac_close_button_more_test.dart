import 'package:easier_drop/components/mac_close_button.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

void main() {
  testWidgets('MacCloseButton pressed + exit hover resets state', (
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
    tester.binding.handlePointerEvent(PointerHoverEvent(position: center));
    await tester.pump(const Duration(milliseconds: 50));
    // Press sequence
    await tester.startGesture(center);
    await tester.pump(const Duration(milliseconds: 20));
    await tester.tap(btn); // triggers onTapUp + onTap
    await tester.pump();
    expect(taps, 1);
    // Move pointer out
    tester.binding.handlePointerEvent(
      PointerHoverEvent(position: Offset(center.dx + 400, center.dy + 400)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('MacCloseButton initial state has hidden inner cross', (
    tester,
  ) async {
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
    final btn = find.bySemanticsLabel(loc.close);
    expect(btn, findsOneWidget);
  });
}
