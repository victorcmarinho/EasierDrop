import 'package:easier_drop/components/hover_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';

Widget _buildTestApp({
  required Widget icon,
  VoidCallback? onPressed,
  bool enabled = true,
  bool addSemantics = true,
  String? semanticsLabel,
  String? semanticsHint,
  Color? baseColor,
  double size = 28,
  Duration duration = const Duration(milliseconds: 110),
}) {
  return MacosApp(
    home: Center(
      child: HoverIconButton(
        icon: icon,
        onPressed: onPressed,
        enabled: enabled,
        addSemantics: addSemantics,
        semanticsLabel: semanticsLabel,
        semanticsHint: semanticsHint,
        baseColor: baseColor,
        size: size,
        duration: duration,
      ),
    ),
  );
}

void main() {
  group('HoverIconButton - Testes Avançados', () {
    testWidgets('Deve mostrar efeito de hover quando o mouse entra na área', (
      tester,
    ) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        _buildTestApp(
          icon: const Icon(Icons.add),
          onPressed: () => buttonPressed = true,
          semanticsLabel: 'Adicionar',
        ),
      );

      final button = find.byType(HoverIconButton);
      expect(button, findsOneWidget);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(button));
      await tester.pump();

      await tester.tap(button);
      await tester.pump();

      expect(buttonPressed, isTrue);

      await gesture.moveTo(const Offset(500, 500));
      await tester.pump();
    });

    testWidgets('Botão desabilitado não deve responder a interações', (
      tester,
    ) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        _buildTestApp(
          icon: const Icon(Icons.close),
          onPressed: () => buttonPressed = true,
          enabled: false,
          semanticsLabel: 'Fechar',
        ),
      );

      final button = find.byType(HoverIconButton);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(button));
      await tester.pump();

      await tester.tap(button);
      await tester.pump();

      expect(buttonPressed, isFalse);
    });

    testWidgets('Deve aplicar a cor base personalizada quando fornecida', (
      tester,
    ) async {
      const customColor = Color(0xFF00FF00);

      await tester.pumpWidget(
        _buildTestApp(
          icon: const Icon(Icons.star),
          onPressed: () {},
          baseColor: customColor,
          semanticsLabel: 'Favorito',
        ),
      );

      final button = find.byType(HoverIconButton);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(button));
      await tester.pump();

      final container = find.descendant(
        of: button,
        matching: find.byType(AnimatedContainer),
      );
      expect(container, findsOneWidget);

      final decoration =
          tester.widget<AnimatedContainer>(container).decoration
              as BoxDecoration;
      final color = decoration.color;

      expect(
        color?.toARGB32(),
        equals(customColor.withValues(alpha: 0.14).toARGB32()),
      );
    });

    testWidgets('Deve ter o tamanho correto conforme especificado', (
      tester,
    ) async {
      const customSize = 40.0;

      await tester.pumpWidget(
        _buildTestApp(
          icon: const Icon(Icons.settings),
          onPressed: () {},
          size: customSize,
          semanticsLabel: 'Configurações',
        ),
      );

      final button = find.byType(HoverIconButton);

      final container = find.descendant(
        of: button,
        matching: find.byType(AnimatedContainer),
      );

      expect(container, findsOneWidget);
    });

    testWidgets('Não deve adicionar semântica quando addSemantics é false', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          icon: const Icon(Icons.delete),
          onPressed: () {},
          addSemantics: false,
          semanticsLabel: 'Excluir',
        ),
      );

      final semantics = find.bySemanticsLabel('Excluir');
      expect(semantics, findsNothing);

      final button = find.byType(HoverIconButton);
      expect(button, findsOneWidget);
    });

    testWidgets('Deve mostrar estado pressionado durante o tap', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          icon: const Icon(Icons.save),
          onPressed: () {},
          semanticsLabel: 'Salvar',
        ),
      );

      final button = find.byType(HoverIconButton);

      final gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump();

      await gesture.up();
      await tester.pump();
    });

    testWidgets(
      'Deve cancelar o estado pressionado ao arrastar para fora do botão',
      (tester) async {
        await tester.pumpWidget(
          _buildTestApp(
            icon: const Icon(Icons.share),
            onPressed: () {},
            semanticsLabel: 'Compartilhar',
          ),
        );

        final button = find.byType(HoverIconButton);

        final gesture = await tester.startGesture(tester.getCenter(button));
        await tester.pump();

        await gesture.moveBy(const Offset(100, 100));
        await tester.pump();

        await tester.pumpAndSettle();
      },
    );
  });
}
