
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/components/parts/limit_overlay.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

import 'package:macos_ui/macos_ui.dart';

class MockLoc extends Mock implements AppLocalizations {}

void main() {
  late MockLoc mockLoc;

  setUp(() {
    mockLoc = MockLoc();
    when(() => mockLoc.limitReached(any())).thenReturn('Limite atingido');
  });

  Widget createWidget({required bool visible}) {
    return MacosApp(
      theme: MacosThemeData.light(),
      home: Stack(
        children: [
          LimitOverlay(visible: visible, loc: mockLoc),
        ],
      ),
    );
  }

  group('LimitOverlay', () {
    testWidgets('não renderiza nada quando visible é false', (tester) async {
      await tester.pumpWidget(createWidget(visible: false));
      expect(find.byType(Container), findsNothing);
      expect(find.text('Limite atingido'), findsNothing);
    });

    testWidgets('renderiza texto de limite quando visible é true', (tester) async {
      await tester.pumpWidget(createWidget(visible: true));
      await tester.pumpAndSettle();
      
      expect(find.text('Limite atingido'), findsOneWidget);
      
      // Verificar se o container tem a decoração correta (primary color com alpha)
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(8));
    });
  });
}
