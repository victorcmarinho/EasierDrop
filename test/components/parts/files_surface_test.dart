import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/components/parts/files_surface.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:easier_drop/helpers/app_constants.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/components/files_stack.dart';
import 'package:easier_drop/components/parts/file_name_badge.dart';

class MockFilesProvider extends Mock implements FilesProvider {}

void main() {
  late MockFilesProvider mockFiles;

  setUp(() {
    mockFiles = MockFilesProvider();
    when(() => mockFiles.files).thenReturn([]);
    when(() => mockFiles.fileCount).thenReturn(0);
    when(() => mockFiles.hasFiles).thenReturn(false);
    when(() => mockFiles.addListener(any())).thenAnswer((_) {});
    when(() => mockFiles.removeListener(any())).thenAnswer((_) {});
  });

  Widget createWidget({
    bool hovering = false,
    bool draggingOut = false,
    bool showLimit = false,
    bool hasFiles = false,
    ValueChanged<bool>? onHoverChanged,
    bool Function(double)? onDragCheck,
    VoidCallback? onDragRequest,
    VoidCallback? onClear,
  }) {
    return MacosApp(
      theme: MacosThemeData.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChangeNotifierProvider<FilesProvider>.value(
        value: mockFiles,
        child: MacosWindow(
          child: MacosScaffold(
            children: [
              ContentArea(
                builder: (context, _) => FilesSurface(
                  hovering: hovering,
                  draggingOut: draggingOut,
                  showLimit: showLimit,
                  hasFiles: hasFiles,
                  buttonKey: GlobalKey(),
                  loc: AppLocalizations.of(context)!,
                  onHoverChanged: onHoverChanged ?? (_) {},
                  onDragCheck: onDragCheck ?? (_) => true,
                  onDragRequest: onDragRequest ?? () {},
                  onClear: onClear ?? () {},
                  getButtonPosition: () => null,
                  filesProvider: mockFiles,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('FilesSurface', () {
    testWidgets('hovering border color e interações mouse', (tester) async {
      bool hoverVal = false;
      await tester.pumpWidget(
        createWidget(hovering: true, onHoverChanged: (v) => hoverVal = v),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(find.byType(FilesSurface)));
      await tester.pumpAndSettle();
      expect(hoverVal, isTrue);

      await gesture.moveTo(const Offset(999, 999));
      await tester.pumpAndSettle();
      expect(hoverVal, isFalse);
      await gesture.removePointer();
    });

    testWidgets('pan gestures - drag simulation', (tester) async {
      bool dragCalled = false;
      await tester.pumpWidget(
        createWidget(
          onDragCheck: (dy) => true,
          onDragRequest: () => dragCalled = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(FilesSurface), const Offset(0, 50));
      await tester.pumpAndSettle();
      expect(dragCalled, isTrue);
    });

    testWidgets('Garante renderização de FilesStack e FileNameBadge com hasFiles == true e teste de tap Action', (tester) async {
      when(() => mockFiles.hasFiles).thenReturn(true);
      when(() => mockFiles.fileCount).thenReturn(1);
      final ref = const FileReference(pathname: '/mock/path/file.png');
      when(() => mockFiles.files).thenReturn([ref]);
      when(() => mockFiles.shared(position: any(named: 'position')))
          .thenAnswer((_) async => Object());

      await tester.pumpWidget(
        createWidget(hasFiles: true),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FilesStack), findsOneWidget);
      expect(find.byType(FileNameBadge), findsOneWidget);

      final shareBtn = find.byKey(SemanticKeys.shareButton);
      expect(shareBtn, findsOneWidget);

      await tester.tap(shareBtn);
      await tester.pumpAndSettle();

      verify(() => mockFiles.shared(position: any(named: 'position'))).called(1);
    });
  });
}
