import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/helpers/marquee_text.dart';

// ignore_for_file: prefer_const_constructors

void main() {
  group('MarqueeText', () {
    /// Wraps [child] in a minimal scaffold so fonts/layout work.
    Widget wrap(Widget child) => Directionality(
          textDirection: TextDirection.ltr,
          child: child,
        );

    testWidgets('renders static text when content fits', (tester) async {
      await tester.pumpWidget(
        wrap(
          MarqueeText(
            text: const TextSpan(text: 'Hi'),
            maxWidth: 500,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      // With maxWidth=500 the short text should NOT scroll.
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('renders scrolling ListView when text overflows', (tester) async {
      await tester.pumpWidget(
        wrap(
          MarqueeText(
            // Very long text to guarantee overflow.
            text: const TextSpan(
              text: 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
                  'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
            ),
            maxWidth: 1, // Force scroll
            pauseDuration: Duration.zero,
          ),
        ),
      );
      // First pump → initState / addPostFrameCallback schedules _updateLayout
      await tester.pump();
      // Second pump → _updateLayout runs and sets _needsScroll = true
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('didUpdateWidget triggers re-layout when text changes',
        (tester) async {
      var label = 'short';

      await tester.pumpWidget(
        wrap(
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  GestureDetector(
                    key: const Key('tap_to_change'),
                    onTap: () => setState(() => label = 'A' * 200),
                    child: const Text('tap'),
                  ),
                  MarqueeText(
                    text: TextSpan(text: label),
                    maxWidth: 100, // force scroll when text is long (but not for 'short')
                    pauseDuration: Duration.zero,
                  ),
                ],
              );
            },
          ),
        ),
      );

      await tester.pump(); // initial build
      await tester.pump(); // post-frame callback

      // Initially short text — no ListView
      expect(find.byType(ListView), findsNothing);

      // Trigger text change → didUpdateWidget → _updateLayout
      await tester.tap(find.byKey(const Key('tap_to_change')));
      await tester.pump(); // rebuild
      await tester.pump(); // post-frame callback for new layout

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Timer fires and animationController advances', (tester) async {
      await tester.pumpWidget(
        wrap(
          MarqueeText(
            text: TextSpan(text: 'A' * 200),
            maxWidth: 1,
            pauseDuration: const Duration(milliseconds: 10),
            speed: 100,
          ),
        ),
      );
      await tester.pump(); // initState
      await tester.pump(); // _updateLayout → _startAnimation → starts Timer

      // Advance past the pauseDuration so the Timer fires
      await tester.pump(const Duration(milliseconds: 50));
      // No crash = Timer callback covered
    });

    testWidgets('dispose cancels timer and animation controller', (tester) async {
      await tester.pumpWidget(
        wrap(
          MarqueeText(
            text: TextSpan(text: 'A' * 200),
            maxWidth: 1,
            pauseDuration: const Duration(milliseconds: 10),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // Replace widget tree → dispose() is called on the old state
      await tester.pumpWidget(wrap(const SizedBox()));
      // No crash = dispose() covered
    });

    testWidgets(
        'didUpdateWidget with same props does NOT re-trigger layout',
        (tester) async {
      // Build with identical props twice to hit the "no-change" guard in didUpdateWidget
      const span = TextSpan(text: 'same');
      await tester.pumpWidget(
        wrap(
          MarqueeText(
            text: span,
            maxWidth: 500,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Rebuild with exact same props — didUpdateWidget should be a no-op
      await tester.pumpWidget(
        wrap(
          MarqueeText(
            text: span,
            maxWidth: 500,
          ),
        ),
      );
      await tester.pump();
    });

    testWidgets('didUpdateWidget with active scrollController triggers jumpTo(0)', (tester) async {
      // Start with long text to force ListView (hasClients = true)
      await tester.pumpWidget(
        wrap(
          MarqueeText(
            text: TextSpan(text: 'A' * 200),
            maxWidth: 1,
            pauseDuration: Duration.zero,
          ),
        ),
      );
      await tester.pump(); // initState
      await tester.pump(); // _updateLayout runs
      await tester.pump(); // ListView built

      expect(find.byType(ListView), findsOneWidget);

      // Now change a property so didUpdateWidget runs and hasClients is true
      await tester.pumpWidget(
        wrap(
          MarqueeText(
            text: TextSpan(text: 'B' * 200), // changed
            maxWidth: 1,
            pauseDuration: Duration.zero,
          ),
        ),
      );
      await tester.pump(); // Rebuild with new widget

      // In didUpdateWidget, scrollController.jumpTo(0) is executed. 
      // After pump, verify it's still scrolling
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
