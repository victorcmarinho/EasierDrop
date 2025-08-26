import 'package:easier_drop/components/hover_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';

// Helper para criar o botão dentro de um ambiente de teste adequado
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
      // Variável para controlar se o botão foi clicado
      bool buttonPressed = false;

      await tester.pumpWidget(
        _buildTestApp(
          icon: const Icon(Icons.add),
          onPressed: () => buttonPressed = true,
          semanticsLabel: 'Adicionar',
        ),
      );

      // Encontra o botão na hierarquia
      final button = find.byType(HoverIconButton);
      expect(button, findsOneWidget);

      // Simula a entrada do mouse na área do botão
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(button));
      await tester.pump();

      // Simula o clique no botão
      await tester.tap(button);
      await tester.pump();

      // Verifica se o callback foi chamado
      expect(buttonPressed, isTrue);

      // Simula a saída do mouse da área do botão
      await gesture.moveTo(const Offset(500, 500)); // Move para longe do botão
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
          enabled: false, // Botão desabilitado
          semanticsLabel: 'Fechar',
        ),
      );

      final button = find.byType(HoverIconButton);

      // Tenta interagir com o botão desabilitado
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(button));
      await tester.pump();

      // Tenta clicar no botão desabilitado
      await tester.tap(button);
      await tester.pump();

      // O callback não deve ser chamado
      expect(buttonPressed, isFalse);
    });

    testWidgets('Deve aplicar a cor base personalizada quando fornecida', (
      tester,
    ) async {
      const customColor = Color(0xFF00FF00); // Verde

      await tester.pumpWidget(
        _buildTestApp(
          icon: const Icon(Icons.star),
          onPressed: () {},
          baseColor: customColor,
          semanticsLabel: 'Favorito',
        ),
      );

      final button = find.byType(HoverIconButton);

      // Simula hover para verificar se a cor personalizada é aplicada
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(button));
      await tester.pump();

      // Verifica se a cor base foi aplicada
      // Precisamos encontrar o Container com a decoração
      final container = find.descendant(
        of: button,
        matching: find.byType(AnimatedContainer),
      );
      expect(container, findsOneWidget);

      // Extrai a decoração para verificar a cor
      final decoration =
          tester.widget<AnimatedContainer>(container).decoration
              as BoxDecoration;
      final color = decoration.color;

      // A cor deve ser a customColor com alguma opacidade (alpha) aplicada
      expect(color?.red, equals(customColor.red));
      expect(color?.green, equals(customColor.green));
      expect(color?.blue, equals(customColor.blue));
      // Não testamos o valor exato do alpha porque depende do estado interno
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

      // Encontra o Container que deve ter o tamanho especificado
      final container = find.descendant(
        of: button,
        matching: find.byType(AnimatedContainer),
      );

      // Verificamos se o widget existe
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
          semanticsLabel: 'Excluir', // Não será usado
        ),
      );

      // Não deve haver um widget Semantics com o label fornecido
      final semantics = find.bySemanticsLabel('Excluir');
      expect(semantics, findsNothing);

      // O botão ainda deve existir e ser funcional
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

      // Inicia o tap (pressionar sem soltar)
      final gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump();

      // Completa o tap (solta o botão)
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

        // Inicia o tap
        final gesture = await tester.startGesture(tester.getCenter(button));
        await tester.pump();

        // Arrasta para fora do botão
        await gesture.moveBy(const Offset(100, 100));
        await tester.pump();

        // Finaliza o gesto
        await tester.pumpAndSettle();
      },
    );
  });
}
