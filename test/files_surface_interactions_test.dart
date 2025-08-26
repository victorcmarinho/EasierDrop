import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:easier_drop/components/parts/files_surface.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockFilesProvider extends Mock implements FilesProvider {}

void main() {
  late MockFilesProvider mockFilesProvider;

  setUp(() {
    mockFilesProvider = MockFilesProvider();
    when(() => mockFilesProvider.files).thenReturn([]);
  });

  testWidgets('FilesSurface deve responder a eventos de mouse e gestos', (
    tester,
  ) async {
    bool hoverChanged = false;
    bool dragCheckCalled = false;
    bool dragRequestCalled = false;

    // Build o widget com as localizações necessárias
    await tester.pumpWidget(
      MacosApp(
        theme: MacosThemeData.light(),
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Provider<FilesProvider>.value(
          value: mockFilesProvider,
          child: Builder(
            builder: (context) {
              return FilesSurface(
                hovering: false,
                draggingOut: false,
                showLimit: false,
                hasFiles: false,
                buttonKey: GlobalKey(),
                loc: AppLocalizations.of(context)!,
                onHoverChanged: (value) => hoverChanged = value,
                onDragCheck: (dy) {
                  dragCheckCalled = true;
                  return true; // permitir drag
                },
                onDragRequest: () => dragRequestCalled = true,
                onClear: () {},
                getButtonPosition: () => null,
                filesProvider: mockFilesProvider,
              );
            },
          ),
        ),
      ),
    );

    // Espere pelas localizações e renderização
    await tester.pumpAndSettle();

    // Encontre o MouseRegion
    final mouseRegion = find.byType(MouseRegion);
    expect(mouseRegion, findsOneWidget);

    // Simule hover (mouse enter)
    final TestGesture gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(mouseRegion));
    await tester.pumpAndSettle();

    // Verifique se onHoverChanged foi chamado com true
    expect(hoverChanged, true);

    // Simule mouse exit
    await gesture.moveTo(const Offset(1000, 1000)); // Longe do widget
    await tester.pumpAndSettle();

    // Verifique se onHoverChanged foi chamado com false
    expect(hoverChanged, false);

    // Volte o mouse para o widget
    await gesture.moveTo(tester.getCenter(mouseRegion));
    await tester.pumpAndSettle();

    // Simule pan/drag start
    await gesture.down(tester.getCenter(mouseRegion));
    await gesture.moveBy(const Offset(20, 20));
    await tester.pumpAndSettle();

    // Verifique se os callbacks de drag foram chamados
    expect(dragCheckCalled, true);
    expect(dragRequestCalled, true);

    // Limpe
    await gesture.up();
    await gesture.removePointer();
  });

  testWidgets('FilesSurface deve exibir corretamente quando hovering é true', (
    tester,
  ) async {
    // Build o widget com hovering = true
    await tester.pumpWidget(
      MacosApp(
        theme: MacosThemeData.light(),
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Provider<FilesProvider>.value(
          value: mockFilesProvider,
          child: Builder(
            builder: (context) {
              return FilesSurface(
                hovering: true, // Agora com hover = true
                draggingOut: false,
                showLimit: false,
                hasFiles: false,
                buttonKey: GlobalKey(),
                loc: AppLocalizations.of(context)!,
                onHoverChanged: (_) {},
                onDragCheck: (_) => true,
                onDragRequest: () {},
                onClear: () {},
                getButtonPosition: () => null,
                filesProvider: mockFilesProvider,
              );
            },
          ),
        ),
      ),
    );

    // Espere pelas localizações
    await tester.pumpAndSettle();

    // Verifique se o container animado está presente
    final animatedContainer = find.byType(AnimatedContainer);
    expect(animatedContainer, findsWidgets);

    // Infelizmente, não podemos verificar diretamente as propriedades de estilo,
    // mas o importante é que o widget seja renderizado com o estado correto
  });
}
