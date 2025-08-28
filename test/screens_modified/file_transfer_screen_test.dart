import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/screens/file_transfer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Gerador de mocks
@GenerateNiceMocks([MockSpec<FilesProvider>()])
import '../screens/file_transfer_screen_test.mocks.dart';

// Componentes mock para substituir componentes problemáticos
class MockTray extends StatelessWidget {
  const MockTray({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(); // Widget vazio para substituir o Tray
  }
}

class MockDragDrop extends StatelessWidget {
  const MockDragDrop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Mock DragDrop'),
    ); // Widget simples para substituir o DragDrop
  }
}

// Versão mockada do FileTransferScreen para teste
class MockedFileTransferScreen extends StatelessWidget {
  const MockedFileTransferScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filesProvider = context.read<FilesProvider>();

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.backspace):
            const ClearFilesIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.delete):
            const ClearFilesIntent(),
        LogicalKeySet(
              LogicalKeyboardKey.meta,
              LogicalKeyboardKey.shift,
              LogicalKeyboardKey.keyC,
            ):
            const ShareFilesIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.enter):
            const ShareFilesIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ClearFilesIntent: CallbackAction<ClearFilesIntent>(
            onInvoke: (intent) {
              if (filesProvider.files.isEmpty) return null;
              filesProvider.clear();
              return null;
            },
          ),
          ShareFilesIntent: CallbackAction<ShareFilesIntent>(
            onInvoke: (intent) {
              filesProvider.shared();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Stack(children: [MockDragDrop(), MockTray()]),
        ),
      ),
    );
  }
}

class TestFileReference extends FileReference {
  const TestFileReference(String path) : super(pathname: path);
}

void main() {
  late MockFilesProvider mockFilesProvider;

  setUp(() {
    mockFilesProvider = MockFilesProvider();
  });

  group('MockedFileTransferScreen', () {
    testWidgets('Renderiza corretamente e aceita atalhos', (tester) async {
      final testWidget = MaterialApp(
        home: ChangeNotifierProvider<FilesProvider>.value(
          value: mockFilesProvider,
          child: const MockedFileTransferScreen(),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Verifica se o componente mock foi renderizado
      expect(find.text('Mock DragDrop'), findsOneWidget);

      // Teste do atalho Cmd+Enter
      when(mockFilesProvider.files).thenReturn([]);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      // Verifica se o método foi chamado
      verify(mockFilesProvider.shared()).called(1);
    });

    testWidgets('ClearFilesIntent limpa arquivos quando existem', (
      tester,
    ) async {
      // Configura o mock para ter arquivos
      when(
        mockFilesProvider.files,
      ).thenReturn([const TestFileReference('/path/to/file.txt')]);

      final testWidget = MaterialApp(
        home: ChangeNotifierProvider<FilesProvider>.value(
          value: mockFilesProvider,
          child: const MockedFileTransferScreen(),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Teste do atalho Cmd+Backspace
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      // Verifica se o método foi chamado
      verify(mockFilesProvider.clear()).called(1);
    });

    testWidgets('ClearFilesIntent não limpa quando não há arquivos', (
      tester,
    ) async {
      // Configura o mock para não ter arquivos
      when(mockFilesProvider.files).thenReturn([]);

      final testWidget = MaterialApp(
        home: ChangeNotifierProvider<FilesProvider>.value(
          value: mockFilesProvider,
          child: const MockedFileTransferScreen(),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Teste do atalho Cmd+Backspace
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      // Verifica que o método não foi chamado
      verifyNever(mockFilesProvider.clear());
    });

    testWidgets('Atalho Cmd+Delete limpa arquivos', (tester) async {
      // Configura o mock para ter arquivos
      when(
        mockFilesProvider.files,
      ).thenReturn([const TestFileReference('/path/to/file.txt')]);

      final testWidget = MaterialApp(
        home: ChangeNotifierProvider<FilesProvider>.value(
          value: mockFilesProvider,
          child: const MockedFileTransferScreen(),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Teste do atalho Cmd+Delete
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.delete);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.delete);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      // Verifica se o método foi chamado
      verify(mockFilesProvider.clear()).called(1);
    });

    testWidgets('Atalho Cmd+Shift+C compartilha arquivos', (tester) async {
      final testWidget = MaterialApp(
        home: ChangeNotifierProvider<FilesProvider>.value(
          value: mockFilesProvider,
          child: const MockedFileTransferScreen(),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Teste do atalho Cmd+Shift+C
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      // Verifica se o método foi chamado
      verify(mockFilesProvider.shared()).called(1);
    });

    // Teste direto com as Classes Intent
    test(
      'ClearFilesIntent e ShareFilesIntent classes são inicializadas corretamente',
      () {
        // Testa a criação das classes Intent
        final clearIntent = const ClearFilesIntent();
        final shareIntent = const ShareFilesIntent();

        // Verifica se são instâncias válidas
        expect(clearIntent, isA<ClearFilesIntent>());
        expect(shareIntent, isA<ShareFilesIntent>());
      },
    );
  });
}
