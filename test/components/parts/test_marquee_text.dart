import 'package:flutter/material.dart';
import 'package:easier_drop/components/parts/marquee_text.dart';

class TestMarqueeText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final bool testForceScroll;

  const TestMarqueeText({
    Key? key,
    required this.text,
    required this.style,
    this.testForceScroll = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(children: [MarqueeText(text: text, style: style)]),
    );
  }
}

class TestMarqueeWrapper extends StatelessWidget {
  final double width;
  final String text;
  final TextStyle style;
  final bool testForceScroll;

  const TestMarqueeWrapper({
    Key? key,
    required this.width,
    required this.text,
    required this.style,
    this.testForceScroll = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          height: 100,
          child: TestMarqueeText(
            text: text,
            style: style,
            testForceScroll: testForceScroll,
          ),
        ),
      ),
    );
  }
}

void configureFlutterErrorsForMarqueeTests() {
  FlutterError.onError = (FlutterErrorDetails details) {
    final String exception = details.exception.toString();
    if (exception.contains('overflowed') ||
        exception.contains('A RenderFlex') ||
        exception.contains('laid out to an infinite') ||
        exception.contains('was not laid out') ||
        exception.contains('depends on directionality')) {
      return;
    }

    FlutterError.presentError(details);
  };
}
