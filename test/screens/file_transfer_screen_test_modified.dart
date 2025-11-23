import 'package:easier_drop/helpers/keyboard_shortcuts.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

@GenerateNiceMocks([MockSpec<FilesProvider>()])
import 'file_transfer_screen_test.mocks.dart';

class MockTray extends StatelessWidget {
  const MockTray({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class MockDragDrop extends StatelessWidget {
  const MockDragDrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Mock DragDrop');
  }
}

class MockedFileTransferScreen extends StatelessWidget {
  const MockedFileTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final filesProvider = context.read<FilesProvider>();

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.backspace):
            const ClearAllIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.delete):
            const ClearAllIntent(),
        LogicalKeySet(
              LogicalKeyboardKey.meta,
              LogicalKeyboardKey.shift,
              LogicalKeyboardKey.keyC,
            ):
            const ShareIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.enter):
            const ShareIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ClearAllIntent: CallbackAction<ClearAllIntent>(
            onInvoke: (intent) {
              if (filesProvider.files.isEmpty) return null;
              filesProvider.clear();
              return null;
            },
          ),
          ShareIntent: CallbackAction<ShareIntent>(
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

      expect(find.text('Mock DragDrop'), findsOneWidget);

      when(mockFilesProvider.files).thenReturn([]);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      verify(mockFilesProvider.shared()).called(1);
    });

    testWidgets('ClearAllIntent limpa arquivos quando existem', (tester) async {
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

      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      verify(mockFilesProvider.clear()).called(1);
    });

    testWidgets('ClearAllIntent não limpa quando não há arquivos', (
      tester,
    ) async {
      when(mockFilesProvider.files).thenReturn([]);

      final testWidget = MaterialApp(
        home: ChangeNotifierProvider<FilesProvider>.value(
          value: mockFilesProvider,
          child: const MockedFileTransferScreen(),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      verifyNever(mockFilesProvider.clear());
    });

    testWidgets('Atalho Cmd+Delete limpa arquivos', (tester) async {
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

      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.delete);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.delete);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

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

      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      verify(mockFilesProvider.shared()).called(1);
    });

    test(
      'ClearAllIntent e ShareIntent classes são inicializadas corretamente',
      () {
        final clearIntent = const ClearAllIntent();
        final shareIntent = const ShareIntent();

        expect(clearIntent, isA<ClearAllIntent>());
        expect(shareIntent, isA<ShareIntent>());
      },
    );
  });
}
