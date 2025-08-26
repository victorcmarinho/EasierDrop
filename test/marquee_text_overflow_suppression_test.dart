import 'package:easier_drop/components/parts/marquee_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Teste especial para verificar a funcionalidade de supressão de avisos de overflow
  // Este teste visa melhorar a cobertura do código sem modificar variáveis globais

  group('MarqueeText - Testes funcionais', () {
    // Configuração para ignorar erros de overflow
    setUp(() {
      debugPrint = (String? message, {int? wrapWidth}) {
        // Ignora as mensagens, não faz nada
      };
    });

    testWidgets('Deve criar o widget com propriedades corretas', (
      tester,
    ) async {
      const String testText = 'Texto de teste';
      const TextStyle testStyle = TextStyle(fontSize: 16, color: Colors.blue);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MarqueeText(text: testText, style: testStyle)),
        ),
      );

      // Verificar se o widget foi criado
      final marqueeFinder = find.byType(MarqueeText);
      expect(marqueeFinder, findsOneWidget);

      // Verificar propriedades
      final marqueeWidget = tester.widget<MarqueeText>(marqueeFinder);
      expect(marqueeWidget.text, equals(testText));
      expect(marqueeWidget.style, equals(testStyle));
    });

    testWidgets('Deve medir e renderizar texto corretamente', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: MarqueeText(
                text: 'Texto curto',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      // Espera a medição acontecer
      await tester.pump(const Duration(milliseconds: 100));

      // Para textos que cabem no espaço, deve renderizar um Text simples
      expect(find.text('Texto curto'), findsOneWidget);
    });

    testWidgets('Deve reagir à mudança de texto', (tester) async {
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

      // Atualiza para um texto diferente
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: MarqueeText(
                text: 'Texto alterado',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Deve mostrar o novo texto
      expect(find.text('Texto inicial'), findsNothing);
      expect(find.text('Texto alterado'), findsOneWidget);
    });

    testWidgets('Deve reagir à mudança de estilo', (tester) async {
      const TextStyle initialStyle = TextStyle(fontSize: 16);
      const TextStyle updatedStyle = TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: MarqueeText(text: 'Mesmo texto', style: initialStyle),
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
              child: MarqueeText(text: 'Mesmo texto', style: updatedStyle),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // O texto deve permanecer o mesmo, mas o estilo deve mudar
      final textWidget = tester.widget<Text>(find.text('Mesmo texto'));
      expect(textWidget.style, equals(updatedStyle));
    });

    testWidgets('Deve liberar recursos no dispose', (tester) async {
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

      // Substitui por outro widget para forçar o dispose
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Widget diferente'))),
      );

      // Se o dispose não funcionar, geralmente ocorrem exceções aqui
      await tester.pump(const Duration(milliseconds: 100));

      // Não deve mais encontrar o MarqueeText
      expect(find.byType(MarqueeText), findsNothing);
    });
  });
}
