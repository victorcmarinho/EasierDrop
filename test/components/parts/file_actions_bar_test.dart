import 'package:easier_drop/components/parts/files_surface.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:easier_drop/components/share_button.dart';
import 'package:easier_drop/components/remove_button.dart';

void main() {
  testWidgets('Share/Remove buttons fade in and out with files', (
    tester,
  ) async {
    final provider = FilesProvider(enableMonitoring: false);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MacosApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MacosWindow(
            child: Builder(
              builder: (c) {
                final loc = AppLocalizations.of(c)!;
                return FilesSurface(
                  hovering: false,
                  draggingOut: false,
                  showLimit: false,
                  hasFiles: provider.files.isNotEmpty,
                  buttonKey: GlobalKey(),
                  loc: loc,
                  onHoverChanged: (_) {},
                  onDragCheck: (_) => false,
                  onDragRequest: () {},
                  onClear: provider.clear,
                  getButtonPosition: () => null,
                  filesProvider: provider,
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(ShareButton), findsNothing);
    expect(find.byType(RemoveButton), findsNothing);

    provider.addFileForTest(const FileReference(pathname: '/tmp/a.txt'));
    await tester.pump();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MacosApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MacosWindow(
            child: Builder(
              builder: (c) {
                final loc = AppLocalizations.of(c)!;
                return FilesSurface(
                  hovering: false,
                  draggingOut: false,
                  showLimit: false,
                  hasFiles: provider.files.isNotEmpty,
                  buttonKey: GlobalKey(),
                  loc: loc,
                  onHoverChanged: (_) {},
                  onDragCheck: (_) => false,
                  onDragRequest: () {},
                  onClear: provider.clear,
                  getButtonPosition: () => null,
                  filesProvider: provider,
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(ShareButton), findsOneWidget);
    expect(find.byType(RemoveButton), findsOneWidget);

    provider.clear();
    await tester.pump();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MacosApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MacosWindow(
            child: Builder(
              builder: (c) {
                final loc = AppLocalizations.of(c)!;
                return FilesSurface(
                  hovering: false,
                  draggingOut: false,
                  showLimit: false,
                  hasFiles: provider.files.isNotEmpty,
                  buttonKey: GlobalKey(),
                  loc: loc,
                  onHoverChanged: (_) {},
                  onDragCheck: (_) => false,
                  onDragRequest: () {},
                  onClear: provider.clear,
                  getButtonPosition: () => null,
                  filesProvider: provider,
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(ShareButton), findsNothing);
    expect(find.byType(RemoveButton), findsNothing);
  });
}
