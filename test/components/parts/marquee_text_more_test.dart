import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/components/parts/marquee_text.dart';
import 'test_marquee_text.dart';

void main() {
  const TextStyle testStyle = TextStyle(fontSize: 16.0);

  setUp(() {
    debugDisableShadows = true;
    TestWidgetsFlutterBinding.ensureInitialized();
    configureFlutterErrorsForMarqueeTests();
  });

  testWidgets('MarqueeText exibe texto corretamente quando curto', (
    WidgetTester tester,
  ) async {
    const String shortText = 'Texto curto';

    await tester.pumpWidget(
      const TestMarqueeWrapper(width: 200, text: shortText, style: testStyle),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(shortText), findsOneWidget);
  });

  testWidgets('MarqueeText exibe texto longo corretamente', (
    WidgetTester tester,
  ) async {
    const String longText =
        'Este é um texto muito longo que não cabe no espaço disponível e deve acionar o comportamento de marquee';

    await tester.pumpWidget(
      const TestMarqueeWrapper(width: 150, text: longText, style: testStyle),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(longText), findsWidgets);

    expect(find.byType(MarqueeText), findsOneWidget);

    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  });

  testWidgets('MarqueeText atualiza quando o texto muda', (
    WidgetTester tester,
  ) async {
    const String initialText = 'Texto inicial';
    const String updatedText = 'Texto atualizado diferente';

    await tester.pumpWidget(
      const TestMarqueeWrapper(width: 150, text: initialText, style: testStyle),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(initialText), findsOneWidget);

    await tester.pumpWidget(
      const TestMarqueeWrapper(width: 150, text: updatedText, style: testStyle),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(initialText), findsNothing);
    expect(find.text(updatedText), findsOneWidget);
  });

  testWidgets('MarqueeText atualiza quando o estilo muda', (
    WidgetTester tester,
  ) async {
    const String testText = 'Texto para testar estilo';
    const TextStyle initialStyle = TextStyle(fontSize: 16.0);
    const TextStyle updatedStyle = TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );

    await tester.pumpWidget(
      const TestMarqueeWrapper(width: 150, text: testText, style: initialStyle),
    );

    await tester.pump(const Duration(milliseconds: 100));

    await tester.pumpWidget(
      const TestMarqueeWrapper(width: 150, text: testText, style: updatedStyle),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MarqueeText), findsOneWidget);
  });

  testWidgets('MarqueeText é removido corretamente', (
    WidgetTester tester,
  ) async {
    const String testText = 'Texto para testar disposição';

    await tester.pumpWidget(
      const TestMarqueeWrapper(width: 150, text: testText, style: testStyle),
    );

    await tester.pump(const Duration(milliseconds: 100));

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Widget diferente'))),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MarqueeText), findsNothing);
    expect(find.text('Widget diferente'), findsOneWidget);
  });
}
