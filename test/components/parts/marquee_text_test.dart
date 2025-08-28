import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/components/parts/marquee_text.dart';

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

  FlutterError.onError = (FlutterErrorDetails details) {
    final String exception = details.exception.toString();
    if (exception.contains('overflowed') ||
        exception.contains('A RenderFlex')) {
      return;
    }

    FlutterError.presentError(details);
  };

  testWidgets('MarqueeText renderiza texto corretamente', (
    WidgetTester tester,
  ) async {
    const String shortText = 'Texto curto';

    await tester.pumpWidget(
      const TestMarqueeWidget(text: shortText, width: 300, style: testStyle),
    );

    expect(find.byType(MarqueeText), findsOneWidget);

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

    expect(find.text(initialText), findsOneWidget);

    await tester.pumpWidget(
      const TestMarqueeWidget(text: updatedText, width: 300, style: testStyle),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(updatedText), findsOneWidget);
    expect(find.text(initialText), findsNothing);
  });

  testWidgets('MarqueeText atualiza quando o estilo muda', (
    WidgetTester tester,
  ) async {
    const String testText = 'Texto de teste';
    const TextStyle initialStyle = TextStyle(fontSize: 16.0);
    const TextStyle updatedStyle = TextStyle(fontSize: 20.0);

    await tester.pumpWidget(
      const TestMarqueeWidget(text: testText, width: 300, style: initialStyle),
    );

    await tester.pumpWidget(
      const TestMarqueeWidget(text: testText, width: 300, style: updatedStyle),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(MarqueeText), findsOneWidget);
    expect(find.text(testText), findsOneWidget);
  });
}
