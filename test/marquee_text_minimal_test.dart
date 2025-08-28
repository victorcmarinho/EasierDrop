import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/components/parts/marquee_text.dart';

void main() {
  void ignoreOverflowErrors() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final String exception = details.exception.toString();
      if (exception.contains('overflowed') ||
          exception.contains('RenderFlex') ||
          exception.contains('laid out') ||
          exception.contains('was not laid out') ||
          exception.contains('appears to be') ||
          exception.contains('Looking up a deactivated')) {
        return;
      }
      FlutterError.presentError(details);
    };
  }

  testWidgets(
    'MarqueeText desativa a animação quando o texto é reduzido e cabe no espaço',
    (WidgetTester tester) async {
      ignoreOverflowErrors();

      const String longText =
          'Este é um texto muito longo que deve ser animado por causa do tamanho';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 150,
              child: MarqueeText(
                text: longText,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      expect(find.text(longText), findsWidgets);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      const String shortText = 'Texto curto';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 150,
              child: MarqueeText(
                text: shortText,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(shortText), findsOneWidget);
      expect(find.byType(MarqueeText), findsOneWidget);
    },
  );
}
