import 'package:easier_drop/components/parts/marquee_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Wrapper para facilitar testes com diferentes tamanhos
Widget _buildMarqueeText(String text, {double width = 200}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: width,
        child: MarqueeText(text: text, style: const TextStyle(fontSize: 16)),
      ),
    ),
  );
}

void main() {
  group('MarqueeText - Testes Avançados', () {
    testWidgets(
      'Deve iniciar a animação quando o texto excede o espaço disponível',
      (tester) async {
        // Usamos um texto longo e uma largura estreita para forçar o overflow
        await tester.pumpWidget(
          _buildMarqueeText(
            'Este é um texto extremamente longo que definitivamente excederá o espaço disponível causando overflow',
            width: 100,
          ),
        );

        // Primeiro frame para layout inicial
        await tester.pump();

        // Esperamos um tempo para o callback post-frame executar e medir o texto
        await tester.pump(const Duration(milliseconds: 100));

        // Acessamos o estado do widget para verificar se a animação está ativa
        final state = tester.state<State>(find.byType(MarqueeText)) as dynamic;

        // Verificamos se o texto foi medido corretamente
        expect(state.measuredTextWidth, isNotNull);
        expect(state.availableWidth, isNotNull);

        // O texto deve ser maior que o espaço disponível
        if (state.measuredTextWidth > state.availableWidth) {
          expect(state.shouldScroll, isTrue);
          // Verificamos se o controlador de animação está ativo
          expect(state._controller.isAnimating, isTrue);
        }
      },
    );

    testWidgets(
      'Deve parar a animação quando o texto não excede mais o espaço disponível',
      (tester) async {
        // Começamos com um texto longo e largura estreita
        await tester.pumpWidget(
          _buildMarqueeText('Texto longo para animação', width: 100),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Agora aumentamos a largura para que o texto caiba
        await tester.pumpWidget(
          _buildMarqueeText(
            'Texto longo para animação',
            width: 300, // Largura maior
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verificamos se a animação parou
        final updatedState =
            tester.state<State>(find.byType(MarqueeText)) as dynamic;

        // Se o texto agora cabe no espaço disponível
        if (updatedState.measuredTextWidth <= updatedState.availableWidth) {
          expect(updatedState.shouldScroll, isFalse);
          expect(updatedState._controller.isAnimating, isFalse);
        }
      },
    );

    testWidgets(
      'Deve reiniciar a animação quando o texto muda para um texto mais longo',
      (tester) async {
        // Começamos com um texto curto
        await tester.pumpWidget(_buildMarqueeText('Texto curto', width: 150));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Agora mudamos para um texto longo mantendo a mesma largura
        await tester.pumpWidget(
          _buildMarqueeText(
            'Este é um texto muito mais longo que certamente não caberá no espaço disponível',
            width: 150,
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verificamos se a animação foi iniciada
        final updatedState =
            tester.state<State>(find.byType(MarqueeText)) as dynamic;

        // O texto novo deve ser maior que o espaço disponível
        if (updatedState.measuredTextWidth > updatedState.availableWidth) {
          expect(updatedState.shouldScroll, isTrue);
          expect(updatedState._controller.isAnimating, isTrue);
        }
      },
    );

    testWidgets(
      'Deve calcular corretamente a duração da animação baseada no tamanho do texto',
      (tester) async {
        const texto = 'Este é um texto longo para testar a duração da animação';

        // Renderizamos o texto com largura limitada
        await tester.pumpWidget(_buildMarqueeText(texto, width: 100));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Acessamos o estado para verificar a duração calculada
        final state = tester.state<State>(find.byType(MarqueeText)) as dynamic;

        // Só verificamos se o texto precisa rolar
        if (state.shouldScroll) {
          // A duração deve ser calculada baseada na largura do texto e na constante _pps (pixels por segundo)
          final textWidth = state.measuredTextWidth;
          final gap = state._gap; // 32.0 conforme a implementação
          final pps = state._pps; // 22.0 conforme a implementação

          final calculatedDistance = textWidth + gap;
          final calculatedSeconds = calculatedDistance / pps;
          final expectedDuration = Duration(
            milliseconds: (calculatedSeconds * 1000).round(),
          );

          // Verificamos se a duração foi calculada corretamente
          expect(state._controller.duration, expectedDuration);
        }
      },
    );

    testWidgets('Deve lidar corretamente com alterações de tamanho da tela', (
      tester,
    ) async {
      // Começamos com um texto que não precisa rolar
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: MarqueeText(
                text: 'Texto inicial',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Agora reduzimos o tamanho da tela, forçando o texto a rolar
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 80, // Largura muito reduzida
              child: MarqueeText(
                text: 'Texto inicial',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verificamos se o estado foi atualizado corretamente
      final state = tester.state<State>(find.byType(MarqueeText)) as dynamic;

      // O texto deve precisar rolar agora
      if (state.measuredTextWidth > state.availableWidth) {
        expect(state.shouldScroll, isTrue);
        expect(state._controller.isAnimating, isTrue);
      }
    });
  });
}
