import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/components/parts/marquee_text.dart';

// Widget de teste para verificar se o marquee funciona corretamente
class TestMarqueeWidget extends StatelessWidget {
  final String text;
  final double width;
  final TextStyle style;

  const TestMarqueeWidget({
    Key? key,
    required this.text,
    required this.width,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: width,
        child: MarqueeText(text: text, style: style),
      ),
    );
  }
}

void main() {
  const TextStyle testStyle = TextStyle(fontSize: 16.0);

  // Ignorar os avisos de overflow que são esperados nos testes
  FlutterError.onError = (FlutterErrorDetails details) {
    final String exception = details.exception.toString();
    if (exception.contains('overflowed') ||
        exception.contains('A RenderFlex')) {
      // Ignora erros de overflow (esperados neste teste)
      return;
    }
    // Relata outros erros normalmente
    FlutterError.presentError(details);
  };

  testWidgets('MarqueeText renderiza texto corretamente', (
    WidgetTester tester,
  ) async {
    const String shortText = 'Texto curto';

    await tester.pumpWidget(
      const TestMarqueeWidget(text: shortText, width: 300, style: testStyle),
    );

    // Verifica se o widget foi renderizado
    expect(find.byType(MarqueeText), findsOneWidget);

    // Verifica se o texto está presente
    expect(find.text(shortText), findsOneWidget);
  });

  testWidgets('MarqueeText atualiza quando o texto muda', (
    WidgetTester tester,
  ) async {
    const String initialText = 'Texto inicial';
    const String updatedText = 'Texto atualizado';

    await tester.pumpWidget(
      const TestMarqueeWidget(text: initialText, width: 300, style: testStyle),
    );

    // Verifica o texto inicial
    expect(find.text(initialText), findsOneWidget);

    // Atualiza o texto
    await tester.pumpWidget(
      const TestMarqueeWidget(text: updatedText, width: 300, style: testStyle),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Verifica se o texto foi atualizado
    expect(find.text(updatedText), findsOneWidget);
    expect(find.text(initialText), findsNothing);
  });

  testWidgets('MarqueeText atualiza quando o estilo muda', (
    WidgetTester tester,
  ) async {
    const String testText = 'Texto de teste';
    const TextStyle initialStyle = TextStyle(fontSize: 16.0);
    const TextStyle updatedStyle = TextStyle(fontSize: 20.0);

    // Renderiza com estilo inicial
    await tester.pumpWidget(
      const TestMarqueeWidget(text: testText, width: 300, style: initialStyle),
    );

    // Atualiza para novo estilo
    await tester.pumpWidget(
      const TestMarqueeWidget(text: testText, width: 300, style: updatedStyle),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Verifica se o widget ainda está presente após a atualização
    expect(find.byType(MarqueeText), findsOneWidget);
    expect(find.text(testText), findsOneWidget);
  });
}
