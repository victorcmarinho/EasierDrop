import 'package:easier_drop/components/parts/dragging_overlay.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';

Widget _wrap(Widget child) {
  return MacosApp(
    home: MacosWindow(
      child: Stack(
        children: [child],
      ),
    ),
  );
}

void main() {
  testWidgets('DraggingOverlay retorna SizedBox.shrink() quando visível é false', (tester) async {
    await tester.pumpWidget(_wrap(const DraggingOverlay(visible: false)));
    // Quando visible é false, o widget retorna SizedBox.shrink()
    expect(find.descendant(
      of: find.byType(DraggingOverlay),
      matching: find.byType(SizedBox),
    ), findsOneWidget);
    expect(find.byType(AnimatedOpacity), findsNothing);
  });

  testWidgets('DraggingOverlay exibe o overlay animado quando visível é true', (tester) async {
    await tester.pumpWidget(_wrap(const DraggingOverlay(visible: true)));
    expect(find.byType(AnimatedOpacity), findsOneWidget);
    expect(find.descendant(
      of: find.byType(DraggingOverlay),
      matching: find.byType(IgnorePointer),
    ), findsOneWidget);
    
    // Verifica se a opacidade está configurada corretamente
    final AnimatedOpacity animatedOpacity = tester.widget(find.byType(AnimatedOpacity));
    expect(animatedOpacity.opacity, 0.9);
    
    // Verifica se o container tem as decorações esperadas (border, radius)
    final Container container = tester.widget(find.descendant(
      of: find.byType(AnimatedOpacity),
      matching: find.byType(Container),
    ));
    
    final BoxDecoration decoration = container.decoration as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(8));
    expect(decoration.border, isNotNull);
    
    // Verifica se o overlay preenche o espaço (Positioned.fill)
    final Positioned positioned = tester.widget(find.descendant(
      of: find.byType(DraggingOverlay),
      matching: find.byType(Positioned),
    ));
    expect(positioned.left, 0);
    expect(positioned.top, 0);
    expect(positioned.right, 0);
    expect(positioned.bottom, 0);
  });
}
