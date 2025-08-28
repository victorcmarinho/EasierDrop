import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/components/mac_close_button.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('MacCloseButton deve lidar com todos os eventos de mouse', (
    tester,
  ) async {
    bool pressed = false;

    await tester.pumpWidget(
      Localizations(
        locale: const Locale('en'),
        delegates: const [
          AppLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        child: Builder(
          builder: (context) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: MacCloseButton(onPressed: () => pressed = true),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    final mouseRegion = find.byType(MouseRegion);
    expect(mouseRegion, findsOneWidget);

    final gestureDetector = find.byType(GestureDetector);
    expect(gestureDetector, findsOneWidget);

    final TestGesture gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(mouseRegion));
    await tester.pumpAndSettle();

    await gesture.down(tester.getCenter(gestureDetector));
    await tester.pumpAndSettle();

    await gesture.up();
    await tester.pumpAndSettle();

    expect(pressed, true);

    pressed = false;
    await gesture.down(tester.getCenter(gestureDetector));
    await tester.pumpAndSettle();

    await gesture.moveTo(const Offset(500, 500));
    await tester.pumpAndSettle();

    expect(pressed, false);

    await gesture.moveTo(tester.getCenter(mouseRegion));
    await tester.pumpAndSettle();

    await gesture.moveTo(const Offset(500, 500));
    await tester.pumpAndSettle();
  });
}
