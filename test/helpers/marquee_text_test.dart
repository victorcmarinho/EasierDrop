import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/helpers/marquee_text.dart';

void main() {
  Widget createWidget({required String text, double maxWidth = 100}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: maxWidth,
            child: MarqueeText(
              text: TextSpan(text: text),
              pauseDuration: Duration.zero,
            ),
          ),
        ),
      ),
    );
  }

  group('MarqueeText', () {
    testWidgets('renderiza texto estático quando cabe no espaço', (tester) async {
       await tester.pumpWidget(createWidget(text: 'Small', maxWidth: 500));
       await tester.pump(const Duration(milliseconds: 100));
       
       expect(find.descendant(of: find.byType(MarqueeText), matching: find.byType(CustomPaint)), findsOneWidget);
    });

    testWidgets('inicia animação quando texto é maior que o espaço', (tester) async {
       await tester.pumpWidget(createWidget(text: 'This is a very long text that should scroll across the screen', maxWidth: 50));
       await tester.pump(const Duration(milliseconds: 100)); // Inicia o Timer
       
       // Timer(pauseDuration, ...)
       await tester.pump(const Duration(milliseconds: 100));
       
       // Agora a animação deve ter começado (ctrl.forward() em modo de teste)
       await tester.pump(const Duration(milliseconds: 100));
       
       expect(find.descendant(of: find.byType(MarqueeText), matching: find.byType(AnimatedBuilder)), findsOneWidget);
    });

    testWidgets('atualiza medições ao mudar o texto', (tester) async {
       await tester.pumpWidget(createWidget(text: 'Small', maxWidth: 500));
       await tester.pump(const Duration(milliseconds: 100));
       
       // Mudar para um texto longo (trigger didUpdateWidget)
       await tester.pumpWidget(createWidget(text: 'This is now a very long text', maxWidth: 20));
       await tester.pump(const Duration(milliseconds: 100));
       await tester.pump(const Duration(milliseconds: 100));
       
       expect(find.descendant(of: find.byType(MarqueeText), matching: find.byType(AnimatedBuilder)), findsOneWidget);
    });

    testWidgets('shouldRepaint coverage', (tester) async {
       // Exercitar shouldRepaint de forma indireta ou direta se possível
       // Como são classes internas privadas, vamos apenas garantir que a árvore mude
       await tester.pumpWidget(createWidget(text: 'Small', maxWidth: 500));
       await tester.pumpWidget(createWidget(text: 'Small', maxWidth: 501));
       await tester.pump();
    });
  });
}
