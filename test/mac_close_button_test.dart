import 'package:easier_drop/components/mac_close_button.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:macos_ui/macos_ui.dart';

void main() {
  testWidgets('MacCloseButton hover/press and callback', (tester) async {
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
    final semFinder = find.bySemanticsLabel(loc.close);
    expect(semFinder, findsOneWidget);

    // Hover
    final element = tester.getCenter(semFinder);
    final binding = tester.binding;
    binding.handlePointerEvent(PointerHoverEvent(position: element));
    await tester.pump(const Duration(milliseconds: 150));

    // Press
    await tester.tap(semFinder);
    await tester.pump();
    expect(taps, 1);
  });
}
