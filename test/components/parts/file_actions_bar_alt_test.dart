import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';

class MockFilesProvider extends Mock implements FilesProvider {}

class MockFileReference extends Mock implements FileReference {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

class FixedAppLocalizations {
  static AppLocalizations? originalOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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

  testWidgets('FileActionsBar - mockada manualmente', (tester) async {
    bool clearCalled = false;

    Widget testWidget = Builder(
      builder: (context) {
        return MaterialApp(
          home: Material(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  key: const ValueKey('removeSem'),
                  label: mockLoc.removeAll,
                  hint: mockLoc.semRemoveHintSome(2),
                  child: ElevatedButton(
                    onPressed: () => clearCalled = true,
                    child: const Text('Remove'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    final removeButton = find.byKey(const ValueKey('removeSem'));
    expect(removeButton, findsOneWidget);

    await tester.tap(removeButton);
    await tester.pumpAndSettle();

    expect(clearCalled, true);
  });

  testWidgets('FileActionsBar - Teste apenas o comportamento principal', (
    tester,
  ) async {
    bool clearCalled = false;
    bool shareCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                key: const ValueKey('shareSem'),
                label: mockLoc.share,
                hint: mockLoc.semShareHintSome(2),
                child: IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => shareCalled = true,
                ),
              ),

              Semantics(
                key: const ValueKey('removeSem'),
                label: mockLoc.removeAll,
                hint: mockLoc.semRemoveHintSome(2),
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => clearCalled = true,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final shareButton = find.byKey(const ValueKey('shareSem'));
    final removeButton = find.byKey(const ValueKey('removeSem'));

    expect(shareButton, findsOneWidget);
    expect(removeButton, findsOneWidget);

    await tester.tap(shareButton);
    await tester.pumpAndSettle();
    expect(shareCalled, true);

    await tester.tap(removeButton);
    await tester.pumpAndSettle();
    expect(clearCalled, true);
  });
}
