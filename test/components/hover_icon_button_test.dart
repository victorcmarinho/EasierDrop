import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/components/hover_icon_button.dart';
import 'package:macos_ui/macos_ui.dart';

void main() {
  Widget createWidget({
    VoidCallback? onPressed,
    bool enabled = true,
    bool addSemantics = true,
  }) {
    return MacosApp(
      theme: MacosThemeData.light(),
      home: MacosScaffold(
        children: [
          ContentArea(
            builder: (context, _) => HoverIconButton(
              icon: const Icon(Icons.add),
              onPressed: onPressed,
              enabled: enabled,
              addSemantics: addSemantics,
              semanticsLabel: 'Test Label',
            ),
          ),
        ],
      ),
    );
  }

  group('HoverIconButton', () {
    testWidgets('renderizado e clique', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(createWidget(onPressed: () => pressed = true));
      await tester.pumpAndSettle();
      
      expect(find.byIcon(Icons.add), findsOneWidget);
      
      await tester.tap(find.byType(HoverIconButton));
      expect(pressed, isTrue);
    });

    testWidgets('hover e press states FULL', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      
      final finder = find.byType(HoverIconButton);
      
      // Simulate mouse enter
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: tester.getCenter(finder));
      await tester.pump();
      
      // Simulate tap down
      await gesture.down(tester.getCenter(finder));
      await tester.pump(); 
      
      // Simulate mouse exit while pressed
      await gesture.moveTo(Offset.zero);
      await tester.pump(); // onExit calls 82, 83
      
      await gesture.up();
      await gesture.removePointer();
      await tester.pumpAndSettle();
    });

    testWidgets('desabilitado', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(createWidget(onPressed: () => pressed = true, enabled: false));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byType(HoverIconButton), warnIfMissed: false);
      expect(pressed, isFalse);
    });

    testWidgets('tap cancel coverage', (tester) async {
       await tester.pumpWidget(createWidget());
       await tester.pumpAndSettle();
       final gesture = await tester.createGesture();
       await gesture.down(tester.getCenter(find.byType(HoverIconButton)));
       await tester.pump();
       await gesture.cancel();
       await tester.pump();
    });
  });
}
