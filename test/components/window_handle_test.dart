import 'package:easier_drop/components/window_handle.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';

class TestWrapper extends StatelessWidget {
  final Widget child;

  const TestWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: child),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('WindowHandle é renderizado corretamente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const TestWrapper(child: Stack(children: [WindowHandle()])),
    );

    await tester.pumpAndSettle();

    expect(find.byType(WindowHandle), findsOneWidget);
    expect(find.byType(GestureDetector), findsAtLeastNWidgets(1));

    expect(
      find.descendant(
        of: find.byType(WindowHandle),
        matching: find.byType(MouseRegion),
      ),
      findsOneWidget,
    );
  });

  testWidgets('WindowHandle reage ao hover do mouse', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const TestWrapper(child: Stack(children: [WindowHandle()])),
    );

    await tester.pumpAndSettle();

    final mouseRegion = find.descendant(
      of: find.byType(WindowHandle),
      matching: find.byType(MouseRegion),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(mouseRegion));
    await tester.pumpAndSettle();

    await gesture.moveTo(const Offset(500, 500));
    await tester.pumpAndSettle();

    await gesture.removePointer();
  });

  testWidgets('WindowHandle inicia o arrasto da janela', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const TestWrapper(child: Stack(children: [WindowHandle()])),
    );

    await tester.pumpAndSettle();

    final gestureDetector = find.descendant(
      of: find.byType(WindowHandle),
      matching: find.byType(GestureDetector),
    );

    await tester.drag(gestureDetector, const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byType(WindowHandle), findsOneWidget);
  });

  testWidgets('WindowHandle tem propriedades semânticas corretas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const TestWrapper(child: Stack(children: [WindowHandle()])),
    );

    await tester.pumpAndSettle();

    final semantics = find.descendant(
      of: find.descendant(
        of: find.byType(WindowHandle),
        matching: find.byType(Center),
      ),
      matching: find.byType(Semantics),
    );

    expect(semantics, findsOneWidget);

    final semanticsWidget = tester.widget(semantics) as Semantics;
    expect(semanticsWidget.properties.label, isNotNull);
    expect(semanticsWidget.properties.hint, isNotNull);
    expect(semanticsWidget.properties.button, isTrue);
  });
}
