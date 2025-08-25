import 'package:easier_drop/components/parts/files_surface.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:macos_ui/macos_ui.dart';

Widget _wrap(FilesProvider provider, {required Widget child}) =>
    ChangeNotifierProvider.value(
      value: provider,
      child: MacosApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: MacosWindow(
          child: MediaQuery(
            data: const MediaQueryData(size: Size(420, 300)),
            child: child,
          ),
        ),
      ),
    );

FilesSurface _surface(
  BuildContext ctx,
  FilesProvider p, {
  bool showLimit = false,
}) => FilesSurface(
  hovering: false,
  draggingOut: false,
  showLimit: showLimit,
  hasFiles: p.files.isNotEmpty,
  buttonKey: GlobalKey(),
  loc: AppLocalizations.of(ctx)!,
  onHoverChanged: (_) {},
  onDragCheck: (_) => false,
  onDragRequest: () {},
  onClear: p.clear,
  getButtonPosition: () => null,
  filesProvider: p,
);

void main() {
  testWidgets('Semantics hints change with file count', (tester) async {
    final provider = FilesProvider(enableMonitoring: false);
    AppLocalizations? loc;
    await tester.pumpWidget(
      _wrap(
        provider,
        child: Builder(
          builder: (c) {
            loc = AppLocalizations.of(c);
            return _surface(c, provider);
          },
        ),
      ),
    );
    await tester.pump();
    // Zero files -> share/remove buttons hidden (opacity 0 placeholder size boxes)
    expect(find.text(loc!.share), findsNothing);
    // Add one file
    provider.addFileForTest(const FileReference(pathname: '/tmp/one.txt'));
    await tester.pump();
    await tester.pumpWidget(
      _wrap(provider, child: Builder(builder: (c) => _surface(c, provider))),
    );
    await tester.pump();
    // Badge should include filename (localized prefix may exist, just search substring)
    expect(find.textContaining('one.txt'), findsOneWidget);
  });

  testWidgets('ShareNone message resolver', (tester) async {
    final provider = FilesProvider(enableMonitoring: false);
    AppLocalizations? loc;
    await tester.pumpWidget(
      _wrap(
        provider,
        child: Builder(
          builder: (c) {
            loc = AppLocalizations.of(c);
            return _surface(c, provider);
          },
        ),
      ),
    );
    await tester.pump();
    await provider.shared(); // empty -> ShareResult with key shareNone
    // raw é ShareResult, convertemos via toString para pegar label; resolvemos key manualmente
    final msg = FilesProvider.resolveShareMessage('shareNone', loc!);
    expect(msg, equals(loc!.shareNone));
  });
}
