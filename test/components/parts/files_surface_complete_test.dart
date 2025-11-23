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
import 'package:share_plus/share_plus.dart';

class MockFilesProvider extends ChangeNotifier implements FilesProvider {
  final List<FileReference> _files = [];

  @override
  List<FileReference> get files => _files;

  @override
  bool get hasFiles => _files.isNotEmpty;

  @override
  bool get isEmpty => _files.isEmpty;

  @override
  int get fileCount => _files.length;

  @override
  List<XFile> get validXFiles => _files.map((f) => XFile(f.pathname)).toList();

  @override
  void clear() {
    _files.clear();
    notifyListeners();
  }

  @override
  Future<void> addFile(FileReference file) async {
    _files.add(file);
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
    hasFiles: provider.files.isNotEmpty,
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

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(find.byType(FilesSurface)));
    await tester.pump();

    expect(hoverState, isTrue);

    await gesture.moveTo(const Offset(-10, -10));
    await tester.pump();

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
                  return true;
                },
              ),
        ),
      ),
    );

    await tester.dragFrom(
      tester.getCenter(find.byType(FilesSurface)),
      const Offset(50, 50),
    );
    await tester.pump();

    expect(dragCheckCalled, isTrue);
    expect(dragRequested, isTrue);
  });

  testWidgets('FilesSurface shows correct UI based on files count', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithApp(
        provider: provider,
        child: Builder(builder: (context) => _buildSurface(context, provider)),
      ),
    );
    await tester.pump();
    expect(find.byType(FileNameBadge), findsNothing);

    await provider.addFile(const FileReference(pathname: '/tmp/test.txt'));

    await tester.pumpWidget(
      _wrapWithApp(
        provider: provider,
        child: Builder(builder: (context) => _buildSurface(context, provider)),
      ),
    );
    await tester.pump();

    expect(find.byType(FileNameBadge), findsOneWidget);

    await provider.addFile(const FileReference(pathname: '/tmp/test2.txt'));

    await tester.pumpWidget(
      _wrapWithApp(
        provider: provider,
        child: Builder(builder: (context) => _buildSurface(context, provider)),
      ),
    );
    await tester.pump();

    expect(find.byType(FileNameBadge), findsOneWidget);
  });

  testWidgets('FilesSurface shows different states', (tester) async {
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
