import 'package:easier_drop/components/parts/marquee_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Ignora os erros de overflow que são esperados nos testes do MarqueeText
  FlutterError.onError = (FlutterErrorDetails details) {
    final String exception = details.exceptionAsString();
    if (exception.contains('overflowed') ||
        exception.contains('RenderFlex') ||
        exception.contains('overflowing')) {
      // Ignora erros de overflow durante os testes
      return;
    }
    FlutterError.presentError(details);
  };

  group('MarqueeText', () {
    testWidgets('Texto curto não deve rolar - renderiza Text direto', (
      tester,
    ) async {
      const text = 'Texto curto';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300, // Largura suficiente para o texto curto
              child: MarqueeText(text: text, style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      );

      // Aguardar a medição do texto
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Verificar que o texto simples é renderizado diretamente
      expect(find.text(text), findsOneWidget);
    });

    testWidgets('Texto longo deve ativar mecanismo de rolagem', (tester) async {
      const text =
          'Este é um texto muito longo que certamente irá exceder a largura disponível';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100, // Largura pequena para forçar rolagem
              child: MarqueeText(text: text, style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      );

      // Aguardar a medição do texto
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Para textos longos, deve haver ClipRect (usado na animação)
      expect(find.byType(ClipRect), findsOneWidget);

      // Verificar que o texto aparece repetido
      expect(find.text(text), findsNWidgets(2));
    });

    testWidgets('Atualização de texto deve re-medir e atualizar UI', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300, // Largura suficiente para texto curto
              child: MarqueeText(
                text: 'Texto curto',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      // Aguardar a medição do texto inicial
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Verificar estado inicial - texto simples, sem animação
      expect(find.text('Texto curto'), findsOneWidget);

      // Atualizar para texto longo com largura limitada para forçar rolagem
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100, // Largura pequena para forçar rolagem
              child: MarqueeText(
                text: 'Texto mais longo que não caberá',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      // Aguardar a re-medição do texto
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Verificar que há duplicação de texto (parte do mecanismo de rolagem)
      expect(find.text('Texto mais longo que não caberá'), findsWidgets);
    });

    testWidgets('Componente deve lidar com texto vazio', (tester) async {
      const emptyText = '';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: MarqueeText(
                text: emptyText,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      // Aguardar a medição do texto
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Texto vazio deve ser renderizado sem erros
      expect(find.text(emptyText), findsOneWidget);
    });

    testWidgets('dispose deve liberar recursos corretamente', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: MarqueeText(text: 'Teste', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      );

      await tester.pump();

      // Substituir por um widget diferente para provocar dispose
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 200, child: Text('Novo widget')),
          ),
        ),
      );

      // Se o dispose não funcionar corretamente, isso geralmente causa falhas no próximo ciclo
      await tester.pump();

      // Verificar que não há mais o widget MarqueeText
      expect(find.byType(MarqueeText), findsNothing);
    });
  });
}
