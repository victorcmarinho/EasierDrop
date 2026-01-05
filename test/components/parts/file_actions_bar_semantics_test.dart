import 'package:easier_drop/components/parts/file_actions_bar.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/helpers/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('FileActionsBar semantics for 0 files', (tester) async {
    final semantics = tester.ensureSemantics();
    final provider = FilesProvider(enableMonitoring: false);
    await tester.pumpWidget(
      ChangeNotifierProvider<FilesProvider>.value(
        value: provider,
        child: MacosApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MacosWindow(
            child: MacosScaffold(
              children: [
                ContentArea(
                  builder: (context, _) {
                    return FileActionsBar(
                      hasFiles: false,
                      filesProvider: provider,
                      buttonKey: GlobalKey(),
                      getButtonPosition: () => Offset.zero,
                      loc: AppLocalizations.of(context)!,
                      onClear: () {},
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final shareFinder = find.byKey(SemanticKeys.shareButton);
    final data = tester.getSemantics(shareFinder);
    expect(data.hint, contains('No files'));
    semantics.dispose();
  });

  testWidgets('FileActionsBar semantics for multiple files', (tester) async {
    final semantics = tester.ensureSemantics();
    final provider = FilesProvider(enableMonitoring: false);
    provider.addFileForTest(const FileReference(pathname: '/test1.txt'));
    provider.addFileForTest(const FileReference(pathname: '/test2.txt'));

    await tester.pumpWidget(
      ChangeNotifierProvider<FilesProvider>.value(
        value: provider,
        child: MacosApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MacosWindow(
            child: MacosScaffold(
              children: [
                ContentArea(
                  builder: (context, _) {
                    return FileActionsBar(
                      hasFiles: true,
                      filesProvider: provider,
                      buttonKey: GlobalKey(),
                      getButtonPosition: () => Offset.zero,
                      loc: AppLocalizations.of(context)!,
                      onClear: () {},
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final shareFinder = find.byKey(SemanticKeys.shareButton);
    final data = tester.getSemantics(shareFinder);
    expect(data.hint, contains('2 files'));
    semantics.dispose();
  });
}
