import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/components/mac_close_button.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('MacCloseButton deve lidar com todos os eventos de mouse', (
    tester,
  ) async {
    bool pressed = false;

    // Build o widget com as localizações necessárias
    await tester.pumpWidget(
      Localizations(
        locale: const Locale('en'),
        delegates: const [
          AppLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        child: Builder(
          builder: (context) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: MacCloseButton(onPressed: () => pressed = true),
            );
          },
        ),
      ),
    );

    // Espere pelas localizações
    await tester.pumpAndSettle();

    // Encontre o MouseRegion
    final mouseRegion = find.byType(MouseRegion);
    expect(mouseRegion, findsOneWidget);

    // Encontre o GestureDetector
    final gestureDetector = find.byType(GestureDetector);
    expect(gestureDetector, findsOneWidget);

    // Simule hover
    final TestGesture gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(mouseRegion));
    await tester.pumpAndSettle();

    // Simule tap down
    await gesture.down(tester.getCenter(gestureDetector));
    await tester.pumpAndSettle();

    // Simule tap up
    await gesture.up();
    await tester.pumpAndSettle();

    // Verifique se o callback foi chamado
    expect(pressed, true);

    // Teste onTapCancel
    pressed = false;
    await gesture.down(tester.getCenter(gestureDetector));
    await tester.pumpAndSettle();

    // Mova o mouse para fora para acionar onTapCancel
    await gesture.moveTo(const Offset(500, 500)); // Longe do widget
    await tester.pumpAndSettle();

    // Verifique se o callback não foi chamado neste caso
    expect(pressed, false);

    // Teste onExit
    await gesture.moveTo(tester.getCenter(mouseRegion));
    await tester.pumpAndSettle();

    // Mova o mouse para fora novamente para acionar onExit
    await gesture.moveTo(const Offset(500, 500));
    await tester.pumpAndSettle();

    // Infelizmente, não temos acesso direto ao estado privado _hover e _pressed,
    // mas podemos observar efeitos visuais resultantes das mudanças de estado
  });
}
