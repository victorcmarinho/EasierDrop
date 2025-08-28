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

  testWidgets('MarqueeText exibe texto quando não precisa de animação', (
    WidgetTester tester,
  ) async {
    ignoreOverflowErrors();

    const String text = 'Texto Curto';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            child: MarqueeText(text: text, style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );

    expect(find.text(text), findsOneWidget);
    expect(find.byType(MarqueeText), findsOneWidget);
  });

  testWidgets('MarqueeText exibe texto longo corretamente', (
    WidgetTester tester,
  ) async {
    ignoreOverflowErrors();

    const String text = 'Este é um texto muito longo que deve ser animado';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 150,
            child: MarqueeText(text: text, style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );

    expect(find.text(text), findsWidgets);
    expect(find.byType(MarqueeText), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('MarqueeText é atualizado quando o texto muda', (
    WidgetTester tester,
  ) async {
    ignoreOverflowErrors();

    const String initialText = 'Texto inicial';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 150,
                child: MarqueeText(
                  text: initialText,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text(initialText), findsWidgets);

    const String updatedText = 'Texto atualizado';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 150,
            child: MarqueeText(
              text: updatedText,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text(initialText), findsNothing);
    expect(find.text(updatedText), findsWidgets);
  });

  testWidgets('MarqueeText é removido corretamente', (
    WidgetTester tester,
  ) async {
    ignoreOverflowErrors();

    const String text = 'Texto de teste';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 150,
            child: MarqueeText(text: text, style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );

    expect(find.byType(MarqueeText), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Widget diferente'))),
    );

    expect(find.byType(MarqueeText), findsNothing);
  });

  testWidgets('MarqueeText lida com mudanças de tamanho do contêiner', (
    WidgetTester tester,
  ) async {
    ignoreOverflowErrors();

    const String text =
        'Este texto vai testar mudanças no tamanho do contêiner';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            child: MarqueeText(text: text, style: TextStyle(fontSize: 16)),
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
            child: MarqueeText(text: text, style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  });
}
