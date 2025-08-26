import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:easier_drop/components/parts/file_actions_bar.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';

// Mocks
class MockFilesProvider extends Mock implements FilesProvider {}
class MockFileReference extends Mock implements FileReference {}
class MockAppLocalizations extends Mock implements AppLocalizations {}

class TestingWrapper extends StatelessWidget {
  final Widget child;
  final AppLocalizations mockLocalizations;

  const TestingWrapper({
    super.key, 
    required this.child,
    required this.mockLocalizations,
  });

  @override
  Widget build(BuildContext context) {
    return Localizations(
      locale: const Locale('en'),
      delegates: [
        _TestAppLocalizationsDelegate(mockLocalizations),
      ],
      child: child,
    );
  }
}

class _TestAppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final AppLocalizations appLocalizations;

  const _TestAppLocalizationsDelegate(this.appLocalizations);

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(appLocalizations);
  }

  @override
  bool shouldReload(_TestAppLocalizationsDelegate old) => false;
}

void main() {
  late MockFilesProvider mockFilesProvider;
  late MockAppLocalizations mockLoc;
  late List<FileReference> mockFiles;
  
  setUp(() {
    mockFilesProvider = MockFilesProvider();
    mockLoc = MockAppLocalizations();
    mockFiles = [MockFileReference(), MockFileReference()];
    
    // Configurar comportamento dos mocks
    when(() => mockFilesProvider.files).thenReturn(mockFiles);
    when(() => mockFilesProvider.shared(position: any(named: 'position')))
        .thenAnswer((_) async => "shared");
    
    // Configurar strings de localização
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
  
  testWidgets('FileActionsBar deve exibir corretamente quando não há arquivos', 
      (tester) async {
    // Indicar que não há arquivos para este teste
    when(() => mockFilesProvider.files).thenReturn([]);
    
    await tester.pumpWidget(
      MaterialApp(
        home: TestingWrapper(
          mockLocalizations: mockLoc,
          child: MacosApp(
            theme: MacosThemeData.light(),
            home: Directionality(
              textDirection: TextDirection.ltr,
              child: FileActionsBar(
                hasFiles: false,
                filesProvider: mockFilesProvider,
                buttonKey: GlobalKey(),
                getButtonPosition: () => null,
                loc: mockLoc,
                onClear: () {},
              ),
            ),
          ),
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    // Verifique se os botões estão ocultos quando não há arquivos
    final shareOpacity = find.byType(AnimatedOpacity);
    
    expect(shareOpacity, findsWidgets);
    
    // Verificar se há SizedBox (usado quando não há arquivos)
    final sizedBox = find.byType(SizedBox);
    expect(sizedBox, findsWidgets);
  });
  
  testWidgets('FileActionsBar deve exibir e responder aos botões quando há arquivos', 
      (tester) async {
    bool clearCalled = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: TestingWrapper(
          mockLocalizations: mockLoc,
          child: MacosApp(
            theme: MacosThemeData.light(),
            home: Directionality(
              textDirection: TextDirection.ltr,
              child: FileActionsBar(
                hasFiles: true,
                filesProvider: mockFilesProvider,
                buttonKey: GlobalKey(),
                getButtonPosition: () => const Offset(100, 100),
                loc: mockLoc,
                onClear: () => clearCalled = true,
              ),
            ),
          ),
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    // Encontre os widgets Semantics
    final removeSemantics = find.byKey(const ValueKey('removeSem'));
    
    expect(removeSemantics, findsOneWidget);
    
    // Verificar a funcionalidade do botão remove
    await tester.tap(removeSemantics);
    await tester.pumpAndSettle();
    
    expect(clearCalled, true);
  });
}
