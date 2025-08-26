import 'package:easier_drop/components/parts/files_surface.dart';
import 'package:easier_drop/components/parts/file_name_badge.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mocktail/mocktail.dart';

// Mock das dependências
class MockFilesProvider extends Mock implements FilesProvider {
  final List<FileReference> _files = [];

  @override
  List<FileReference> get files => _files;

  // Sem override de hasFiles porque não existe no FilesProvider original

  @override
  void clear() {
    _files.clear();
  }

  @override
  Future<void> addFile(FileReference file) async {
    _files.add(file);
  }
}

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
  bool hovering = false,
  bool draggingOut = false,
  bool showLimit = false,
  ValueChanged<bool>? onHoverChanged,
  bool Function(double)? onDragCheck,
  VoidCallback? onDragRequest,
}) {
  final loc = AppLocalizations.of(context)!;
  return FilesSurface(
    hovering: hovering,
    draggingOut: draggingOut,
    showLimit: showLimit,
    hasFiles:
        provider
            .files
            .isNotEmpty, // Usando files.isNotEmpty ao invés de hasFiles
    buttonKey: GlobalKey(),
    loc: loc,
    onHoverChanged: onHoverChanged ?? (_) {},
    onDragCheck: onDragCheck ?? (_) => true,
    onDragRequest: onDragRequest ?? () {},
    onClear: provider.clear,
    getButtonPosition: () => const Offset(100, 100),
    filesProvider: provider,
  );
}

void main() {
  late MockFilesProvider provider;

  setUp(() {
    provider = MockFilesProvider();
  });

  testWidgets('FilesSurface responds to hover events', (tester) async {
    bool hoverState = false;

    await tester.pumpWidget(
      _wrapWithApp(
        provider: provider,
        child: Builder(
          builder:
              (context) => _buildSurface(
                context,
                provider,
                onHoverChanged: (value) {
                  hoverState = value;
                },
              ),
        ),
      ),
    );

    // Simulando entrada do mouse
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(find.byType(FilesSurface)));
    await tester.pump();

    // Verificando se o callback onHoverChanged foi chamado com true
    expect(hoverState, isTrue);

    // Simulando saída do mouse
    await gesture.moveTo(const Offset(-10, -10)); // Fora do widget
    await tester.pump();

    // Verificando se o callback onHoverChanged foi chamado com false
    expect(hoverState, isFalse);
  });

  testWidgets('FilesSurface responds to drag gesture', (tester) async {
    bool dragRequested = false;
    bool dragCheckCalled = false;

    await tester.pumpWidget(
      _wrapWithApp(
        provider: provider,
        child: Builder(
          builder:
              (context) => _buildSurface(
                context,
                provider,
                onDragRequest: () {
                  dragRequested = true;
                },
                onDragCheck: (dy) {
                  dragCheckCalled = true;
                  return true; // Permite o drag
                },
              ),
        ),
      ),
    );

    // Simulando pan gesture
    await tester.dragFrom(
      tester.getCenter(find.byType(FilesSurface)),
      const Offset(50, 50),
    );
    await tester.pump();

    // Verificando se os callbacks foram chamados
    expect(dragCheckCalled, isTrue);
    expect(dragRequested, isTrue);
  });

  testWidgets('FilesSurface shows correct UI based on files count', (
    tester,
  ) async {
    // Teste com nenhum arquivo
    await tester.pumpWidget(
      _wrapWithApp(
        provider: provider,
        child: Builder(builder: (context) => _buildSurface(context, provider)),
      ),
    );
    await tester.pump();
    expect(find.byType(FileNameBadge), findsNothing);

    // Adiciona um arquivo
    await provider.addFile(const FileReference(pathname: '/tmp/test.txt'));

    // Reconstroi o widget
    await tester.pumpWidget(
      _wrapWithApp(
        provider: provider,
        child: Builder(builder: (context) => _buildSurface(context, provider)),
      ),
    );
    await tester.pump();

    // Verifica exibição da badge com nome de um arquivo
    expect(find.byType(FileNameBadge), findsOneWidget);

    // Adiciona outro arquivo
    await provider.addFile(const FileReference(pathname: '/tmp/test2.txt'));

    // Reconstroi o widget
    await tester.pumpWidget(
      _wrapWithApp(
        provider: provider,
        child: Builder(builder: (context) => _buildSurface(context, provider)),
      ),
    );
    await tester.pump();

    // Verifica exibição da badge com contagem de múltiplos arquivos
    expect(find.byType(FileNameBadge), findsOneWidget);
  });

  testWidgets('FilesSurface shows different states', (tester) async {
    // Teste com draggingOut = true
    await tester.pumpWidget(
      _wrapWithApp(
        provider: provider,
        child: Builder(
          builder:
              (context) => _buildSurface(context, provider, draggingOut: true),
        ),
      ),
    );
    await tester.pump();

    // Testa estado de hovering = true
    await tester.pumpWidget(
      _wrapWithApp(
        provider: provider,
        child: Builder(
          builder:
              (context) => _buildSurface(context, provider, hovering: true),
        ),
      ),
    );
    await tester.pump();
  });
}
