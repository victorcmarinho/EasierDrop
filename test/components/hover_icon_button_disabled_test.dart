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
              enabled: false, // Botão desabilitado
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Encontre o FocusableActionDetector
      final focusableActionDetector = find.byType(FocusableActionDetector);
      expect(focusableActionDetector, findsOneWidget);

      // Teste tap no botão desabilitado
      await tester.tap(find.byType(HoverIconButton));
      await tester.pumpAndSettle();

      // Verifique que o callback não foi chamado
      expect(pressed, false);

      // Simule hover
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(focusableActionDetector));
      await tester.pumpAndSettle();

      // Agora mude para um botão habilitado
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
              enabled: true, // Agora está habilitado
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simule showHoverHighlight manualmente para cobrir a linha com onShowHoverHighlight
      final focusableActionDetectorWidget = tester
          .widget<FocusableActionDetector>(focusableActionDetector);
      focusableActionDetectorWidget.onShowHoverHighlight!(true);
      await tester.pumpAndSettle();

      // Agora toque no botão habilitado
      await tester.tap(find.byType(HoverIconButton));
      await tester.pumpAndSettle();

      // Verifique que o callback foi chamado
      expect(pressed, true);
    },
  );
}
