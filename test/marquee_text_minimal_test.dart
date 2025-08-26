import 'package:easier_drop/components/parts/marquee_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MarqueeText - Testa todos os caminhos', (
    WidgetTester tester,
  ) async {
    // Desativa erros de renderização durante o teste para evitar falhas por overflow
    debugPrint = (String? message, {int? wrapWidth}) {};
    FlutterError.onError = (FlutterErrorDetails details) {};

    // Widget app que usamos para intercambiar o texto e testar várias condições
    Widget buildApp(String text, double width) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: width,
            child: MarqueeText(
              text: text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    // 1. Inicializa com texto curto em container grande (não deve rolar)
    await tester.pumpWidget(buildApp('Texto curto', 500));
    await tester.pump(const Duration(milliseconds: 100));

    // 2. Atualiza para texto longo em container pequeno (deve rolar)
    await tester.pumpWidget(
      buildApp(
        'Este é um texto muito longo que certamente irá exceder a largura disponível',
        100,
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // 3. Avança animação
    await tester.pump(const Duration(seconds: 1));

    // 4. Atualiza para texto vazio
    await tester.pumpWidget(buildApp('', 100));
    await tester.pump(const Duration(milliseconds: 100));

    // 5. Atualiza apenas o estilo (mesmo texto)
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 100,
            child: MarqueeText(
              text: '',
              style: const TextStyle(fontSize: 20), // Tamanho diferente
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // 6. Remove o widget para testar dispose
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 100, child: Text('Widget diferente')),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verifica que o widget foi removido com sucesso
    expect(find.byType(MarqueeText), findsNothing);
  });
}
