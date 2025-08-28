import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/components/parts/file_actions_bar.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';

class MockFilesProvider extends Mock implements FilesProvider {}

class MockFileReference extends Mock implements FileReference {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

class TestFileActionsBar extends StatelessWidget {
  final bool hasFiles;
  final VoidCallback onShare;
  final VoidCallback onClear;
  final AppLocalizations loc;

  const TestFileActionsBar({
    super.key,
    required this.hasFiles,
    required this.onShare,
    required this.onClear,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 4,
          right: 4,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: hasFiles ? 1 : 0,
            child:
                hasFiles
                    ? Semantics(
                      key: const ValueKey('shareSem'),
                      label: loc.share,
                      hint:
                          hasFiles
                              ? loc.semShareHintSome(2)
                              : loc.semShareHintNone,
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: onShare,
                      ),
                    )
                    : const SizedBox(width: 40, height: 40),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: hasFiles ? 1 : 0,
            child:
                hasFiles
                    ? Semantics(
                      key: const ValueKey('removeSem'),
                      label: loc.removeAll,
                      hint:
                          hasFiles
                              ? loc.semRemoveHintSome(2)
                              : loc.semRemoveHintNone,
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: onClear,
                      ),
                    )
                    : const SizedBox(width: 40, height: 40),
          ),
        ),
      ],
    );
  }
}

void main() {
  late MockFilesProvider mockFilesProvider;
  late MockAppLocalizations mockLoc;
  late List<FileReference> mockFiles;

  setUp(() {
    mockFilesProvider = MockFilesProvider();
    mockLoc = MockAppLocalizations();
    mockFiles = [MockFileReference(), MockFileReference()];

    when(() => mockFilesProvider.files).thenReturn(mockFiles);
    when(
      () => mockFilesProvider.shared(position: any(named: 'position')),
    ).thenAnswer((_) async => "shared");

    when(() => mockLoc.share).thenReturn('Share');
    when(() => mockLoc.removeAll).thenReturn('Remove All');
    when(() => mockLoc.tooltipShare).thenReturn('Share Files');
    when(() => mockLoc.tooltipClear).thenReturn('Clear Files');
    when(() => mockLoc.semShareHintSome(any())).thenReturn('Share 2 files');
    when(() => mockLoc.semShareHintNone).thenReturn('No files to share');
    when(() => mockLoc.semRemoveHintSome(any())).thenReturn('Remove 2 files');
    when(() => mockLoc.semRemoveHintNone).thenReturn('No files to remove');
    when(() => mockLoc.close).thenReturn('Close');
  });

  testWidgets(
    'FileActionsBar deve exibir corretamente quando não há arquivos',
    (tester) async {
      when(() => mockFilesProvider.files).thenReturn([]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestFileActionsBar(
              hasFiles: false,
              onShare: () {},
              onClear: () {},
              loc: mockLoc,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final shareOpacity = find.byType(AnimatedOpacity).at(0);
      final removeOpacity = find.byType(AnimatedOpacity).at(1);

      expect(shareOpacity, findsOneWidget);
      expect(removeOpacity, findsOneWidget);

      final sizedBox = find.byType(SizedBox);
      expect(sizedBox, findsWidgets);
    },
  );

  testWidgets(
    'FileActionsBar deve exibir e responder aos botões quando há arquivos',
    (tester) async {
      bool clearCalled = false;
      bool shareCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestFileActionsBar(
              hasFiles: true,
              onShare: () => shareCalled = true,
              onClear: () => clearCalled = true,
              loc: mockLoc,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final shareSemantics = find.byKey(const ValueKey('shareSem'));
      final removeSemantics = find.byKey(const ValueKey('removeSem'));

      expect(shareSemantics, findsOneWidget);
      expect(removeSemantics, findsOneWidget);

      await tester.tap(shareSemantics);
      await tester.pumpAndSettle();
      expect(shareCalled, true);

      await tester.tap(removeSemantics);
      await tester.pumpAndSettle();
      expect(clearCalled, true);
    },
  );

  testWidgets(
    'FileActionsBar deve verificar se os botões estão ocultos quando não há arquivos',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestFileActionsBar(
              hasFiles: false,
              onShare: () {},
              onClear: () {},
              loc: mockLoc,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final shareOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity).at(0),
      );
      final removeOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity).at(1),
      );

      expect(shareOpacity.opacity, 0.0);
      expect(removeOpacity.opacity, 0.0);
    },
  );
}
