import 'package:easier_drop/components/parts/files_surface.dart';
import 'package:easier_drop/components/parts/file_name_badge.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:easier_drop/services/settings_service.dart';

Widget _wrapWithApp({required FilesProvider provider, required Widget child}) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: MacosApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: MacosWindow(
        child: MediaQuery(
          data: const MediaQueryData(size: Size(400, 300)),
          child: child,
        ),
      ),
    ),
  );
}

FilesSurface _buildSurface(
  BuildContext context,
  FilesProvider provider, {
  bool showLimit = false,
}) {
  final loc = AppLocalizations.of(context)!;
  return FilesSurface(
    hovering: false,
    draggingOut: false,
    showLimit: showLimit,
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
}

void main() {
  testWidgets('FilesSurface shows badge after adding a file', (tester) async {
    final provider = FilesProvider(enableMonitoring: false);
    await tester.pumpWidget(
      _wrapWithApp(
        provider: provider,
        child: Builder(builder: (context) => _buildSurface(context, provider)),
      ),
    );
    await tester.pump();
    expect(find.byType(FileNameBadge), findsNothing);

    provider.addFileForTest(const FileReference(pathname: '/tmp/a.txt'));
    await tester.pump();

    await tester.pumpWidget(
      _wrapWithApp(
        provider: provider,
        child: Builder(builder: (context) => _buildSurface(context, provider)),
      ),
    );
    await tester.pump();
    expect(find.byType(FileNameBadge), findsOneWidget);
  });

  testWidgets('FilesSurface shows limit overlay text', (tester) async {
    final provider = FilesProvider(enableMonitoring: false);
    final loc = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(
      _wrapWithApp(
        provider: provider,
        child: Builder(
          builder:
              (context) => _buildSurface(context, provider, showLimit: true),
        ),
      ),
    );
    await tester.pump();
    final expected = loc.limitReached(SettingsService.instance.maxFiles);
    expect(find.text(expected), findsOneWidget);
  });
}
