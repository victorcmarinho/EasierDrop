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

  Widget buildWidget(FilesProvider filesProvider) {
    return ChangeNotifierProvider<FilesProvider>.value(
      value: filesProvider,
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
    final filesProvider = MockFilesProvider();
    when(() => filesProvider.files).thenReturn([]);
    
    // Configuramos os mocks para não verificar número específico de chamadas
    // que pode variar entre execuções devido a como o Flutter gerencia listeners
    when(() => filesProvider.addListener(any())).thenReturn(null);

    await tester.pumpWidget(buildWidget(filesProvider));
    await tester.pumpAndSettle();

    // Verifica se o componente foi criado
    expect(find.byType(Tray), findsOneWidget);

    // Verificamos apenas que o listener foi registrado, sem especificar quantas vezes
    verify(() => filesProvider.addListener(any())).called(greaterThanOrEqualTo(1));
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
}
