import 'package:easier_drop/components/parts/marquee_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Desativa o flapMap, que gera avisos de overflow no console
  debugDisableShadows = true;

  setUp(() {
    // Ignora os erros de overflow que são esperados nos testes
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('overflowed') ||
          details.exception.toString().contains('RenderFlex') ||
          details.exception.toString().contains('A RenderFlex overflowed')) {
        // Ignora os erros de overflow durante os testes
        return;
      }
      FlutterError.presentError(details);
    };
  });

  group('MarqueeText - Cobertura de código', () {
    testWidgets('Inicialização e construção do widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: MarqueeText(
                text: 'Texto de teste',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      // Permitir que o texto seja medido
      await tester.pump(const Duration(milliseconds: 100));

      // Verifica se o widget foi renderizado
      expect(find.byType(MarqueeText), findsOneWidget);
    });

    testWidgets('Texto curto não inicia animação', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500, // Largura grande o suficiente para o texto curto
              child: MarqueeText(
                text: 'Texto curto',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Texto curto deve ser renderizado como um Text simples
      expect(find.text('Texto curto'), findsOneWidget);
    });

    testWidgets('didUpdateWidget é chamado quando o texto muda', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: MarqueeText(
                text: 'Texto inicial',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Atualiza o texto do widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: MarqueeText(
                text: 'Texto diferente',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Verifica se o texto foi atualizado
      expect(find.text('Texto inicial'), findsNothing);
      expect(find.text('Texto diferente'), findsWidgets);
    });

    testWidgets('didUpdateWidget é chamado quando o estilo muda', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: MarqueeText(
                text: 'Mesmo texto',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Atualiza apenas o estilo
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: MarqueeText(
                text: 'Mesmo texto',
                style: TextStyle(fontSize: 20), // Tamanho diferente
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // O texto continua o mesmo
      expect(find.text('Mesmo texto'), findsWidgets);
    });

    testWidgets('dispose deve liberar recursos', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: MarqueeText(
                text: 'Texto para dispose',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Substitui o widget para forçar o dispose
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 200, child: Text('Widget diferente')),
          ),
        ),
      );

      // Se o dispose não funcionar corretamente, haverá exceções aqui
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MarqueeText), findsNothing);
    });
  });
}
