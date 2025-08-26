import 'package:easier_drop/components/hover_icon_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

void main() {
  testWidgets('HoverIconButton with custom properties', (tester) async {
    const customColor = Color(0xFF6200EE);

    await tester.pumpWidget(
      MacosApp(
        home: Center(
          child: HoverIconButton(
            icon: const Icon(CupertinoIcons.globe),
            onPressed: null, // Disabled for this test
            semanticsLabel: 'Custom Button',
            semanticsHint: 'Tooltip text',
            baseColor: customColor,
            size: 32.0,
          ),
        ),
      ),
    );
    await tester.pump();

    // Verificar semântica
    final semantics = find.bySemanticsLabel('Custom Button');
    expect(semantics, findsOneWidget);

    // Verificar tamanho
    final buttonFinder = find.byType(HoverIconButton);
    final Size size = tester.getSize(buttonFinder);
    expect(size.width, 32.0);
    expect(size.height, 32.0);
  });

  testWidgets('HoverIconButton tap animation', (tester) async {
    int taps = 0;
    await tester.pumpWidget(
      MacosApp(
        home: Center(
          child: HoverIconButton(
            icon: const Icon(CupertinoIcons.doc_text),
            onPressed: () => taps++,
            semanticsLabel: 'Edit Button',
          ),
        ),
      ),
    );
    await tester.pump();

    // Verificar estado inicial
    final buttonFinder = find.byType(HoverIconButton);
    expect(buttonFinder, findsOneWidget);

    // Testar tap
    await tester.tap(buttonFinder);
    await tester.pump();
    expect(taps, 1);

    // Verificar que o botão ainda existe após o tap
    expect(find.byType(HoverIconButton), findsOneWidget);
  });

  testWidgets('HoverIconButton without explicit semantics', (tester) async {
    await tester.pumpWidget(
      MacosApp(
        home: Center(
          child: HoverIconButton(
            icon: const Icon(CupertinoIcons.delete),
            onPressed: null,
            addSemantics: false,
          ),
        ),
      ),
    );
    await tester.pump();

    // Verificar que não há semântica com o label especificado
    expect(find.bySemanticsLabel('Delete'), findsNothing);

    // Verificar que o botão está presente
    expect(find.byType(HoverIconButton), findsOneWidget);
  });
}
