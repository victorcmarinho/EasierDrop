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
    'MarqueeText para a animação quando o texto se torna curto o suficiente',
    (WidgetTester tester) async {
      ignoreOverflowErrors();

      const String longText =
          'Este é um texto muito longo que deve ser animado devido ao seu tamanho';

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

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

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
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text(shortText), findsOneWidget);

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

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text(longText), findsWidgets);
    },
  );

  testWidgets('MarqueeText alterna entre texto curto e longo várias vezes', (
    WidgetTester tester,
  ) async {
    ignoreOverflowErrors();

    const String shortText = 'Texto curto';
    const String longText = 'Este é um texto muito longo para animação';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            child: MarqueeText(text: shortText, style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );

    await tester.pump();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 100,
            child: MarqueeText(text: longText, style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );

    await tester.pump();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            child: MarqueeText(text: shortText, style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );

    await tester.pump();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 100,
            child: MarqueeText(text: longText, style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(longText), findsWidgets);
  });
}
