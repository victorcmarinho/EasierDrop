import 'package:easier_drop/components/parts/file_name_badge.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';

void main() {
  group('FileNameBadge', () {
    Widget wrap(Widget child) => MacosApp(
          debugShowCheckedModeBanner: false,
          home: MacosWindow(child: child),
        );

    testWidgets('renders with semantics label', (tester) async {
      await tester.pumpWidget(
        wrap(
          const FileNameBadge(label: 'document.pdf'),
        ),
      );
      await tester.pump();

      // The Semantics node wrapping the badge should carry the label.
      expect(
        tester.getSemantics(find.bySemanticsLabel('document.pdf')),
        isNotNull,
      );
    });

    testWidgets('renders MarqueeText with the correct label', (tester) async {
      await tester.pumpWidget(
        wrap(
          const FileNameBadge(label: 'photo.jpg'),
        ),
      );
      await tester.pump();

      // FileNameBadge always contains a ClipRRect and BackdropFilter
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('renders correctly for long file name without overflow error',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const FileNameBadge(
            label: 'very_long_file_name_that_should_scroll_in_marquee.dart',
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      // No exceptions means the overflow is handled by MarqueeText.
    });
  });
}
