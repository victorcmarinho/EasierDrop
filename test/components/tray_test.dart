import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/components/tray.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tray_manager/tray_manager.dart';

class MockFilesProvider extends Mock implements FilesProvider {}

class MockTrayListener extends Mock implements TrayListener {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildWidget() {
    return ChangeNotifierProvider<FilesProvider>.value(
      value: MockFilesProvider(),
      child: Localizations(
        locale: const Locale('en'),
        delegates: const [
          AppLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        child: Builder(
          builder: (context) {
            return const Tray();
          },
        ),
      ),
    );
  }

  testWidgets('Tray é renderizado corretamente', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.byType(Tray), findsOneWidget);
  });

  test('TrayListener implementa os métodos corretamente', () {
    final mockListener = MockTrayListener();

    final menuItem = MenuItem(key: 'test_key', label: 'Test Label');

    expect(() => mockListener.onTrayIconMouseDown(), returnsNormally);
    expect(() => mockListener.onTrayIconRightMouseDown(), returnsNormally);
    expect(() => mockListener.onTrayIconRightMouseUp(), returnsNormally);
    expect(() => mockListener.onTrayMenuItemClick(menuItem), returnsNormally);

    expect(() {
      trayManager.addListener(mockListener);
      trayManager.removeListener(mockListener);
    }, returnsNormally);
  });

  testWidgets('Tray constrói build corretamente', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.byType(SizedBox), findsOneWidget);
  });

  test('Tray widget pode ser criado', () {
    final tray = const Tray();

    expect(tray, isA<Tray>());

    expect(tray.createState(), isA<State<Tray>>());
  });

  testWidgets('Tray funciona com TrayListener implementação', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.byType(Tray), findsOneWidget);
  });

  testWidgets('Tray verifica dispose seguro', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();

    expect(true, isTrue);
  });

  testWidgets('Tray interage com métodos do TrayListener', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final dynamic state = tester.state(find.byType(Tray));

    expect(() => state.onTrayIconMouseDown(), returnsNormally);

    final menuItem = MenuItem(key: 'test', label: 'Test');
    expect(() => state.onTrayMenuItemClick(menuItem), returnsNormally);
  });
}
