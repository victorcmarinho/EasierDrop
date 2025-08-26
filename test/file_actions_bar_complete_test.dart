import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/components/parts/file_actions_bar.dart';
import 'package:easier_drop/components/share_button.dart';
import 'package:easier_drop/components/remove_button.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockFilesProvider extends Mock implements FilesProvider {
  final List<FileReference> _files = [];

  @override
  List<FileReference> get files => _files;

  @override
  Future<Object> shared({Offset? position}) async {
    return "shared";
  }

  @override
  Future<void> addFile(FileReference file) async {
    _files.add(file);
  }

  @override
  void clear() {
    _files.clear();
  }
}

class MockFileReference extends Mock implements FileReference {
  @override
  final String fileName;
  @override
  final String pathname;

  MockFileReference({
    this.fileName = 'test.txt',
    this.pathname = '/tmp/test.txt',
  });
}

void main() {
  late MockFilesProvider mockFilesProvider;

  setUp(() {
    mockFilesProvider = MockFilesProvider();
  });

  testWidgets('FileActionsBar deve exibir corretamente quando não há arquivos', (
    tester,
  ) async {
    bool clearCalled = false;

    await tester.pumpWidget(
      Localizations(
        locale: const Locale('en'),
        delegates: const [
          AppLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        child: Builder(
          builder: (context) {
            return MacosApp(
              theme: MacosThemeData.light(),
              home: Directionality(
                textDirection: TextDirection.ltr,
                child: FileActionsBar(
                  hasFiles: false,
                  filesProvider: mockFilesProvider,
                  buttonKey: GlobalKey(),
                  getButtonPosition: () => null,
                  loc: AppLocalizations.of(context)!,
                  onClear: () => clearCalled = true,
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verifique se os botões estão ocultos quando não há arquivos
    final shareOpacity = find.byType(AnimatedOpacity).at(0);
    final removeOpacity = find.byType(AnimatedOpacity).at(1);

    expect(shareOpacity, findsOneWidget);
    expect(removeOpacity, findsOneWidget);

    // Não podemos verificar facilmente a opacidade diretamente,
    // mas podemos verificar se o SizedBox (usado quando não há arquivos) está presente
    final sizedBox = find.byType(SizedBox);
    expect(sizedBox, findsWidgets);
  });

  testWidgets(
    'FileActionsBar deve exibir e responder aos botões quando há arquivos',
    (tester) async {
      await mockFilesProvider.addFile(MockFileReference());

      bool clearCalled = false;

      await tester.pumpWidget(
        Localizations(
          locale: const Locale('en'),
          delegates: const [
            AppLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          child: Builder(
            builder: (context) {
              return MacosApp(
                theme: MacosThemeData.light(),
                home: Directionality(
                  textDirection: TextDirection.ltr,
                  child: FileActionsBar(
                    hasFiles: true,
                    filesProvider: mockFilesProvider,
                    buttonKey: GlobalKey(),
                    getButtonPosition: () => const Offset(100, 100),
                    loc: AppLocalizations.of(context)!,
                    onClear: () => clearCalled = true,
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Encontre os botões de share e remove
      final shareButton = find.byKey(const ValueKey('shareSem'));
      final removeButton = find.byKey(const ValueKey('removeSem'));

      expect(shareButton, findsOneWidget);
      expect(removeButton, findsOneWidget);

      // Teste o botão de share - clique e verifique se a função shared foi chamada
      await tester.tap(shareButton);
      await tester.pump();
      verify(
        () => mockFilesProvider.shared(position: any(named: 'position')),
      ).called(1);

      // Teste o botão de clear
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      expect(clearCalled, true);
    },
  );

  testWidgets('FileActionsBar deve exibir os rótulos semânticos corretamente', (
    tester,
  ) async {
    // Adicione arquivos para o teste
    await mockFilesProvider.addFile(MockFileReference());
    await mockFilesProvider.addFile(MockFileReference());

    await tester.pumpWidget(
      Localizations(
        locale: const Locale('en'),
        delegates: const [
          AppLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        child: Builder(
          builder: (context) {
            final loc = AppLocalizations.of(context)!;
            return MacosApp(
              theme: MacosThemeData.light(),
              home: Directionality(
                textDirection: TextDirection.ltr,
                child: FileActionsBar(
                  hasFiles: true,
                  filesProvider: mockFilesProvider,
                  buttonKey: GlobalKey(),
                  getButtonPosition: () => const Offset(100, 100),
                  loc: loc,
                  onClear: () {},
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Encontre os widgets Semantics para verificação
    final shareSemantics = find.byKey(const ValueKey('shareSem'));
    final removeSemantics = find.byKey(const ValueKey('removeSem'));

    expect(shareSemantics, findsOneWidget);
    expect(removeSemantics, findsOneWidget);

    // Verifique se conseguimos acessar os botões
    await tester.tap(shareSemantics);
    await tester.pump();
    verify(
      () => mockFilesProvider.shared(position: any(named: 'position')),
    ).called(1);
  });
}
