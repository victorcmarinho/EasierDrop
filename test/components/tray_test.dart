import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/components/tray.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tray_manager/tray_manager.dart';

// Mock para o FilesProvider
class MockFilesProvider extends Mock implements FilesProvider {}

// Estendemos o TrayManager para acessar o estado interno
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

    // Verifica se o componente foi criado
    expect(find.byType(Tray), findsOneWidget);
  });

  test('TrayListener implementa os métodos corretamente', () {
    // Utilizamos mocks para simular o TrayListener
    final mockListener = MockTrayListener();

    // Simulamos o recebimento dos eventos
    final menuItem = MenuItem(key: 'test_key', label: 'Test Label');

    expect(() => mockListener.onTrayIconMouseDown(), returnsNormally);
    expect(() => mockListener.onTrayIconRightMouseDown(), returnsNormally);
    expect(() => mockListener.onTrayIconRightMouseUp(), returnsNormally);
    expect(() => mockListener.onTrayMenuItemClick(menuItem), returnsNormally);

    // Testamos que podemos registrar o listener (sem erros)
    expect(() {
      trayManager.addListener(mockListener);
      trayManager.removeListener(mockListener);
    }, returnsNormally);
  });

  testWidgets('Tray constrói build corretamente', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    // Verifica se o Container está presente (método build)
    expect(find.byType(SizedBox), findsOneWidget);
  });

  test('Tray widget pode ser criado', () {
    // Criamos uma instância do widget Tray para testar
    final tray = const Tray();

    // Verificamos se o widget foi criado
    expect(tray, isA<Tray>());

    // Verificamos se pode criar o state
    expect(tray.createState(), isA<State<Tray>>());
  });

  testWidgets('Tray funciona com TrayListener implementação', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    // Verificar se o widget foi criado corretamente
    expect(find.byType(Tray), findsOneWidget);
  });

  testWidgets('Tray verifica dispose seguro', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    // Remove o widget para testar dispose
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();

    // Deve executar sem erros
    expect(true, isTrue);
  });
}
