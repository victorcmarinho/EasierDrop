import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:easier_drop/components/hover_icon_button.dart';

void main() {
  testWidgets(
    'HoverIconButton deve lidar corretamente com o estado desabilitado',
    (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MacosApp(
          theme: MacosThemeData.light(),
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: HoverIconButton(
              icon: const SizedBox(width: 16, height: 16),
              onPressed: () => pressed = true,
              semanticsLabel: 'Test Button',
              semanticsHint: 'Test Hint',
              enabled: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final focusableActionDetector = find.byType(FocusableActionDetector);
      expect(focusableActionDetector, findsOneWidget);

      await tester.tap(find.byType(HoverIconButton));
      await tester.pumpAndSettle();

      expect(pressed, false);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(focusableActionDetector));
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MacosApp(
          theme: MacosThemeData.light(),
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: HoverIconButton(
              icon: const SizedBox(width: 16, height: 16),
              onPressed: () => pressed = true,
              semanticsLabel: 'Test Button',
              semanticsHint: 'Test Hint',
              enabled: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final focusableActionDetectorWidget = tester
          .widget<FocusableActionDetector>(focusableActionDetector);
      focusableActionDetectorWidget.onShowHoverHighlight!(true);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(HoverIconButton));
      await tester.pumpAndSettle();

      expect(pressed, true);
    },
  );
}
