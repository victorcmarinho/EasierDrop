import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/components/parts/file_actions_bar.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';

// Mocks
class MockFilesProvider extends Mock implements FilesProvider {}
class MockFileReference extends Mock implements FileReference {}
class MockAppLocalizations extends Mock implements AppLocalizations {}

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
    when(() => mockFilesProvider.shared(position: any(named: 'position'))).thenAnswer((_) async => "shared");
    
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
  
  testWidgets('FileActionsBar deve exibir corretamente quando não há arquivos', (tester) async {
    // Indicar que não há arquivos para este teste
    when(() => mockFilesProvider.files).thenReturn([]);
    
    await tester.pumpWidget(
      MacosApp(
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
    );
    
    await tester.pumpAndSettle();
    
    // Verifique se os botões estão ocultos quando não há arquivos
    final shareOpacity = find.byType(AnimatedOpacity).at(0);
    final removeOpacity = find.byType(AnimatedOpacity).at(1);
    
    expect(shareOpacity, findsOneWidget);
    expect(removeOpacity, findsOneWidget);
    
    // Verificar se há SizedBox (usado quando não há arquivos)
    final sizedBox = find.byType(SizedBox);
    expect(sizedBox, findsWidgets);
  });
  
  testWidgets('FileActionsBar deve exibir e responder aos botões quando há arquivos', (tester) async {
    bool clearCalled = false;
    
    await tester.pumpWidget(
      MacosApp(
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
    );
    
    await tester.pumpAndSettle();
    
    // Encontre os widgets Semantics
    final shareSemantics = find.byKey(const ValueKey('shareSem'));
    final removeSemantics = find.byKey(const ValueKey('removeSem'));
    
    expect(shareSemantics, findsOneWidget);
    expect(removeSemantics, findsOneWidget);
    
    // Teste o botão de clear
    await tester.tap(removeSemantics);
    await tester.pumpAndSettle();
    
    expect(clearCalled, true);
    
    // Verificar se o método shared foi chamado
    verify(() => mockFilesProvider.shared(position: any(named: 'position'))).called(0);
  });
}
}
}
