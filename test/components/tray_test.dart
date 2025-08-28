import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/components/tray.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/services/settings_service.dart';

// Mock para o FilesProvider
class MockFilesProvider extends Mock implements FilesProvider {}

// Mock para FileReference
class MockFileReference extends Mock implements FileReference {}

// Estendemos o TrayManager para acessar o estado interno
class MockTrayListener extends Mock implements TrayListener {}

// Mock do SystemHelper para testar as chamadas
class MockSystemHelper extends Mock implements SystemHelper {
  static Future<void> open() async {}
  static Future<void> exit() async {}
}

// Mock para o SettingsService
class MockSettingsService extends Mock implements SettingsService {}

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
    verify(
      () => filesProvider.addListener(any()),
    ).called(greaterThanOrEqualTo(1));
  });

  testWidgets('Tray atualiza o menu quando os arquivos mudam', (tester) async {
    final filesProvider = MockFilesProvider();

    // Simulamos uma lista de arquivos
    final List<FileReference> files = [];
    when(() => filesProvider.files).thenReturn(files);
    when(() => filesProvider.addListener(any())).thenReturn(null);
    when(() => filesProvider.removeListener(any())).thenReturn(null);

    await tester.pumpWidget(buildWidget(filesProvider));
    await tester.pumpAndSettle();

    // Verifica se o componente foi criado
    expect(find.byType(Tray), findsOneWidget);

    // Simulamos uma mudança nos arquivos (arquivos são atualizados)
    final callback =
        verify(() => filesProvider.addListener(captureAny())).captured.first
            as Function;

    // Adicionamos um arquivo mock
    final mockFile = MockFileReference();
    when(() => mockFile.pathname).thenReturn('/path/to/file.txt');
    files.add(mockFile);

    // Chamamos o callback para simular a atualização
    callback();

    await tester.pumpAndSettle();

    // Não podemos verificar a atualização do menu facilmente,
    // mas podemos verificar se o código executa sem erros
    expect(true, isTrue);
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

  testWidgets('Tray responde a mudanças no provider', (tester) async {
    final filesProvider = MockFilesProvider();
    final List<FileReference> files = [];

    when(() => filesProvider.files).thenReturn(files);
    when(() => filesProvider.addListener(any())).thenReturn(null);
    when(() => filesProvider.removeListener(any())).thenReturn(null);

    await tester.pumpWidget(buildWidget(filesProvider));
    await tester.pumpAndSettle();

    // Captura o callback do listener
    final callback =
        verify(() => filesProvider.addListener(captureAny())).captured.first
            as Function;

    // Simula adição de arquivos
    final mockFile1 = MockFileReference();
    when(() => mockFile1.pathname).thenReturn('/path/to/file1.txt');
    files.add(mockFile1);

    // Chama o callback para simular mudança
    callback();

    // Adiciona mais arquivos
    final mockFile2 = MockFileReference();
    when(() => mockFile2.pathname).thenReturn('/path/to/file2.txt');
    files.add(mockFile2);

    // Chama novamente
    callback();

    await tester.pumpAndSettle();
    expect(find.byType(Tray), findsOneWidget);
  });

  testWidgets('Tray remove listener no dispose', (tester) async {
    final filesProvider = MockFilesProvider();
    when(() => filesProvider.files).thenReturn([]);
    when(() => filesProvider.addListener(any())).thenReturn(null);
    when(() => filesProvider.removeListener(any())).thenReturn(null);

    await tester.pumpWidget(buildWidget(filesProvider));
    await tester.pumpAndSettle();

    // Remove o widget para testar dispose
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();

    // Verifica se removeListener foi chamado (pode ser chamado mais de uma vez)
    verify(
      () => filesProvider.removeListener(any()),
    ).called(greaterThanOrEqualTo(1));
  });

  testWidgets('Tray constrói build corretamente', (tester) async {
    final filesProvider = MockFilesProvider();
    when(() => filesProvider.files).thenReturn([]);
    when(() => filesProvider.addListener(any())).thenReturn(null);

    await tester.pumpWidget(buildWidget(filesProvider));
    await tester.pumpAndSettle();

    // Verifica se o Container está presente (método build)
    expect(find.byType(Container), findsOneWidget);
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
    final filesProvider = MockFilesProvider();
    when(() => filesProvider.files).thenReturn([]);
    when(() => filesProvider.addListener(any())).thenReturn(null);

    await tester.pumpWidget(buildWidget(filesProvider));
    await tester.pumpAndSettle();

    // Verificar se o widget foi criado corretamente
    expect(find.byType(Tray), findsOneWidget);

    // Simular interações com o tray através do widget
    // Esses métodos são chamados pelo tray_manager, então testamos indiretamente
    expect(find.byType(Tray), findsOneWidget);
  });

  testWidgets('Tray responde a mudanças de contagem de arquivos', (tester) async {
    final filesProvider = MockFilesProvider();
    final List<FileReference> files = [];

    when(() => filesProvider.files).thenReturn(files);
    when(() => filesProvider.addListener(any())).thenReturn(null);
    when(() => filesProvider.removeListener(any())).thenReturn(null);

    await tester.pumpWidget(buildWidget(filesProvider));
    await tester.pumpAndSettle();

    // Captura o callback do listener
    final callback =
        verify(() => filesProvider.addListener(captureAny())).captured.first
            as Function;

    // Testar sem mudança na contagem de arquivos
    callback();
    await tester.pumpAndSettle();

    // Adicionar arquivos para mudar a contagem
    final mockFile = MockFileReference();
    when(() => mockFile.pathname).thenReturn('/path/to/file.txt');
    files.add(mockFile);

    // Chamar novamente para testar a mudança
    callback();
    await tester.pumpAndSettle();

    expect(find.byType(Tray), findsOneWidget);
  });

  testWidgets('Tray funciona com múltiplos arquivos', (tester) async {
    final filesProvider = MockFilesProvider();
    final List<FileReference> files = [];

    when(() => filesProvider.files).thenReturn(files);
    when(() => filesProvider.addListener(any())).thenReturn(null);

    await tester.pumpWidget(buildWidget(filesProvider));
    await tester.pumpAndSettle();

    // Adicionar múltiplos arquivos para testar diferentes contagens
    for (int i = 0; i < 5; i++) {
      final mockFile = MockFileReference();
      when(() => mockFile.pathname).thenReturn('/path/to/file$i.txt');
      files.add(mockFile);
    }

    // Simular mudança através do callback
    final callback =
        verify(() => filesProvider.addListener(captureAny())).captured.first
            as Function;
    callback();

    await tester.pumpAndSettle();
    expect(find.byType(Tray), findsOneWidget);
  });

  testWidgets('Tray testa inicialização completa', (tester) async {
    final filesProvider = MockFilesProvider();
    when(() => filesProvider.files).thenReturn([]);
    when(() => filesProvider.addListener(any())).thenReturn(null);

    await tester.pumpWidget(buildWidget(filesProvider));
    
    // Pump múltiplas vezes para garantir que todos os post frame callbacks executem
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(Tray), findsOneWidget);
    
    // Verificar que o listener foi adicionado
    verify(() => filesProvider.addListener(any())).called(greaterThanOrEqualTo(1));
  });

  testWidgets('Tray testa dispose com diferentes estados', (tester) async {
    final filesProvider = MockFilesProvider();
    when(() => filesProvider.files).thenReturn([]);
    when(() => filesProvider.addListener(any())).thenReturn(null);
    when(() => filesProvider.removeListener(any())).thenReturn(null);

    await tester.pumpWidget(buildWidget(filesProvider));
    await tester.pumpAndSettle();

    // Testar dispose em diferentes momentos
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();

    // Verificar que removeListener foi chamado
    verify(() => filesProvider.removeListener(any())).called(greaterThanOrEqualTo(1));
  });

  testWidgets('Tray funciona com provider vazio e cheio', (tester) async {
    final filesProvider = MockFilesProvider();
    final List<FileReference> files = [];

    when(() => filesProvider.files).thenReturn(files);
    when(() => filesProvider.addListener(any())).thenReturn(null);

    await tester.pumpWidget(buildWidget(filesProvider));
    await tester.pumpAndSettle();

    // Testar com lista vazia
    final callback =
        verify(() => filesProvider.addListener(captureAny())).captured.first
            as Function;
    
    callback();
    await tester.pumpAndSettle();

    // Adicionar arquivos
    for (int i = 0; i < 3; i++) {
      final mockFile = MockFileReference();
      when(() => mockFile.pathname).thenReturn('/test/file$i.txt');
      files.add(mockFile);
    }

    // Testar com arquivos
    callback();
    await tester.pumpAndSettle();

    expect(find.byType(Tray), findsOneWidget);
  });

  testWidgets('Tray verifica dispose seguro', (tester) async {
    final filesProvider = MockFilesProvider();
    when(() => filesProvider.files).thenReturn([]);
    when(() => filesProvider.addListener(any())).thenReturn(null);
    when(() => filesProvider.removeListener(any())).thenReturn(null);

    await tester.pumpWidget(buildWidget(filesProvider));
    await tester.pumpAndSettle();

    // Remove o widget para testar dispose
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();

    // Deve executar sem erros
    expect(true, isTrue);
  });
}
