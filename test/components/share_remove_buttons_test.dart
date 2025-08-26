import 'package:easier_drop/components/parts/files_surface.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:macos_ui/macos_ui.dart';

Widget _wrap(FilesProvider provider, Widget child) =>
    ChangeNotifierProvider.value(
      value: provider,
      child: MacosApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: MacosWindow(
          child: MediaQuery(
            data: const MediaQueryData(size: Size(420, 320)),
            child: child,
          ),
        ),
      ),
    );

FilesSurface _surface(BuildContext c, FilesProvider p) => FilesSurface(
  hovering: false,
  draggingOut: false,
  showLimit: false,
  hasFiles: p.files.isNotEmpty,
  buttonKey: GlobalKey(),
  loc: AppLocalizations.of(c)!,
  onHoverChanged: (_) {},
  onDragCheck: (_) => false,
  onDragRequest: () {},
  onClear: p.clear,
  getButtonPosition: () => null,
  filesProvider: p,
);

void main() {
  testWidgets('Share & Remove buttons semantics reflect file counts', (
    tester,
  ) async {
    final provider = FilesProvider(enableMonitoring: false);
    final semanticsHandle = tester.ensureSemantics();

    Future<void> pump() async {
      await tester.pumpWidget(
        _wrap(provider, Builder(builder: (c) => _surface(c, provider))),
      );
      await tester.pump();
    }

    await pump();
    final loc = await AppLocalizations.delegate.load(const Locale('en'));

    // Sem arquivos: botões não expostos
    expect(find.bySemanticsLabel(loc.share), findsNothing);
    expect(find.bySemanticsLabel(loc.removeAll), findsNothing);

    // Adiciona 1 arquivo
    provider.addFileForTest(const FileReference(pathname: '/tmp/one.txt'));
    await pump();
    // Wait for AnimatedOpacity to settle
    await tester.pump(const Duration(milliseconds: 400));
    final share1 = tester.getSemantics(find.byKey(const ValueKey('shareSem')));
    final remove1 = tester.getSemantics(
      find.byKey(const ValueKey('removeSem')),
    );
    expect(share1.hint, equals(loc.semShareHintSome(1)));
    expect(remove1.hint, equals(loc.semRemoveHintSome(1)));

    // Adiciona 2º arquivo
    provider.addFileForTest(const FileReference(pathname: '/tmp/two.txt'));
    await pump();
    await tester.pump(const Duration(milliseconds: 400));
    final share2 = tester.getSemantics(find.byKey(const ValueKey('shareSem')));
    final remove2 = tester.getSemantics(
      find.byKey(const ValueKey('removeSem')),
    );
    expect(share2.hint, equals(loc.semShareHintSome(2)));
    expect(remove2.hint, equals(loc.semRemoveHintSome(2)));

    // Limpa -> some novamente
    provider.clear();
    await pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('shareSem')), findsNothing);
    expect(find.byKey(const ValueKey('removeSem')), findsNothing);

    semanticsHandle.dispose();
  });
}
