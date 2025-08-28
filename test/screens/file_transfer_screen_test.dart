import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/screens/file_transfer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../mocks/mock_drag_drop.dart';

@GenerateNiceMocks([MockSpec<FilesProvider>()])
import 'file_transfer_screen_test.mocks.dart';

class TestFileReference extends FileReference {
  const TestFileReference(String path) : super(pathname: path);
}

// Um handler de atalhos que simula o comportamento do FileTransferScreen
class KeyboardShortcutHandler {
  final FilesProvider filesProvider;

  KeyboardShortcutHandler(this.filesProvider);

  KeyEventResult handleKeyPress(Set<LogicalKeyboardKey> keysPressed) {
    // Cmd+Backspace ou Cmd+Delete para limpar
    if ((keysPressed.contains(LogicalKeyboardKey.meta)) &&
        (keysPressed.contains(LogicalKeyboardKey.backspace) ||
            keysPressed.contains(LogicalKeyboardKey.delete))) {
      if (filesProvider.files.isNotEmpty) {
        filesProvider.clear();
      }
      return KeyEventResult.handled;
    }

    // Cmd+Shift+C ou Cmd+Enter para compartilhar
    if ((keysPressed.contains(LogicalKeyboardKey.meta)) &&
        ((keysPressed.contains(LogicalKeyboardKey.shift) &&
                keysPressed.contains(LogicalKeyboardKey.keyC)) ||
            keysPressed.contains(LogicalKeyboardKey.enter))) {
      filesProvider.shared();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}

// Teste de widget simplificado para testar as ações e intenções
class TestableFileTransferScreen extends StatelessWidget {
  final FilesProvider filesProvider;

  const TestableFileTransferScreen({Key? key, required this.filesProvider})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          child: Container(color: Colors.white, child: const Text('Test')),
        ),
      ),
    );
  }
}

void main() {
  late MockFilesProvider mockFilesProvider;
  late KeyboardShortcutHandler handler;

  setUp(() {
    mockFilesProvider = MockFilesProvider();
    handler = KeyboardShortcutHandler(mockFilesProvider);
  });

  group('FileTransferScreen handler', () {
    test('Cmd+Backspace limpa arquivos quando há arquivos', () {
      // Configurar mock para ter arquivos
      when(
        mockFilesProvider.files,
      ).thenReturn([const TestFileReference('/path/to/file1.txt')]);

      final keysPressed = {
        LogicalKeyboardKey.meta,
        LogicalKeyboardKey.backspace,
      };

      handler.handleKeyPress(keysPressed);

      verify(mockFilesProvider.clear()).called(1);
    });

    test('Cmd+Backspace não limpa arquivos quando não há arquivos', () {
      // Configurar mock para não ter arquivos
      when(mockFilesProvider.files).thenReturn([]);

      final keysPressed = {
        LogicalKeyboardKey.meta,
        LogicalKeyboardKey.backspace,
      };

      handler.handleKeyPress(keysPressed);

      verifyNever(mockFilesProvider.clear());
    });

    test('Cmd+Delete limpa arquivos quando há arquivos', () {
      // Configurar mock para ter arquivos
      when(
        mockFilesProvider.files,
      ).thenReturn([const TestFileReference('/path/to/file1.txt')]);

      final keysPressed = {LogicalKeyboardKey.meta, LogicalKeyboardKey.delete};

      handler.handleKeyPress(keysPressed);

      verify(mockFilesProvider.clear()).called(1);
    });

    test('Cmd+Shift+C compartilha arquivos', () {
      final keysPressed = {
        LogicalKeyboardKey.meta,
        LogicalKeyboardKey.shift,
        LogicalKeyboardKey.keyC,
      };

      handler.handleKeyPress(keysPressed);

      verify(mockFilesProvider.shared()).called(1);
    });

    test('Cmd+Enter compartilha arquivos', () {
      final keysPressed = {LogicalKeyboardKey.meta, LogicalKeyboardKey.enter};

      handler.handleKeyPress(keysPressed);

      verify(mockFilesProvider.shared()).called(1);
    });
  });

  group('FileTransferScreen Actions e Intents', () {
    testWidgets('ClearFilesIntent invoca clear quando há arquivos', (
      tester,
    ) async {
      // Configurar mock para ter arquivos
      when(
        mockFilesProvider.files,
      ).thenReturn([const TestFileReference('/path/to/file1.txt')]);

      final widget = MaterialApp(
        home: ChangeNotifierProvider<FilesProvider>.value(
          value: mockFilesProvider,
          child: TestableFileTransferScreen(filesProvider: mockFilesProvider),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Disparar a ação diretamente
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);

      await tester.pumpAndSettle();

      verify(mockFilesProvider.clear()).called(1);
    });

    testWidgets('ClearFilesIntent não invoca clear quando não há arquivos', (
      tester,
    ) async {
      // Configurar mock para não ter arquivos
      when(mockFilesProvider.files).thenReturn([]);

      final widget = MaterialApp(
        home: ChangeNotifierProvider<FilesProvider>.value(
          value: mockFilesProvider,
          child: TestableFileTransferScreen(filesProvider: mockFilesProvider),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Disparar a ação diretamente
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);

      await tester.pumpAndSettle();

      verifyNever(mockFilesProvider.clear());
    });

    testWidgets('ShareFilesIntent invoca shared', (tester) async {
      final widget = MaterialApp(
        home: ChangeNotifierProvider<FilesProvider>.value(
          value: mockFilesProvider,
          child: TestableFileTransferScreen(filesProvider: mockFilesProvider),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Disparar a ação diretamente
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);

      await tester.pumpAndSettle();

      verify(mockFilesProvider.shared()).called(1);
    });

    testWidgets('FileTransferScreen real com testMode funciona corretamente', (
      tester,
    ) async {
      // Configurar mock para ter arquivos
      when(
        mockFilesProvider.files,
      ).thenReturn([const TestFileReference('/path/to/file1.txt')]);

      final widget = MaterialApp(
        home: ChangeNotifierProvider<FilesProvider>.value(
          value: mockFilesProvider,
          child: FileTransferScreen(
            testMode: true,
            testDragDrop: const MockDragDrop(),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Testa se a tela foi renderizada sem erros
      expect(find.byType(FileTransferScreen), findsOneWidget);
      expect(find.byType(MockDragDrop), findsOneWidget);

      // Disparar a ação diretamente para limpar
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);

      await tester.pumpAndSettle();

      // Verifica se o método foi chamado
      verify(mockFilesProvider.clear()).called(1);

      // Disparar a ação diretamente para compartilhar
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
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
