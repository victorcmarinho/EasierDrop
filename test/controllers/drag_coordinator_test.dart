import 'package:easier_drop/controllers/drag_coordinator.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/services/file_drop_service.dart';
import 'package:easier_drop/services/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('Testes de DragCoordinator', () {
    late FilesProvider provider;
    late BuildContext context;
    late DragCoordinator coordinator;

    setUp(() {
      provider = FilesProvider(enableMonitoring: false);
    });

    Widget buildTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<FilesProvider>.value(value: provider),
        ],
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(),
        ),
      );
    }

    testWidgets('Limpa arquivos no move, retém no copy/unknown', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      context = tester.element(find.byType(SizedBox));
      coordinator = DragCoordinator(context);

      provider.addFileForTest(const FileReference(pathname: '/tmp/a'));
      provider.addFileForTest(const FileReference(pathname: '/tmp/b'));
      await tester.pump();
      expect(provider.files.length, 2);

      coordinator.handleOutboundTest({'status': 'ok', 'op': 'copy'});
      expect(provider.files.length, 2);

      coordinator.handleOutboundTest({'status': 'ok', 'op': 'move'});
      await tester.pump();
      expect(provider.files.length, 0);
    });

    testWidgets('lida com diferentes respostas de status', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      context = tester.element(find.byType(SizedBox));
      coordinator = DragCoordinator(context);

      provider.addFileForTest(const FileReference(pathname: '/tmp/test'));
      await tester.pump();
      expect(provider.files.length, 1);

      coordinator.handleOutboundTest({'status': 'error', 'op': 'move'});
      expect(provider.files.length, 1);

      coordinator.handleOutboundTest({'status': 'ok', 'op': 'move'});
      await tester.pump();
      expect(provider.files.length, 0);
    });

    testWidgets('beginExternalDrag lida com estados', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      context = tester.element(find.byType(SizedBox));
      coordinator = DragCoordinator(context);

      const dragOutChannel = MethodChannel(PlatformChannels.fileDragOut);
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        dragOutChannel,
        (call) async => null,
      );

      await coordinator.beginExternalDrag();
      expect(coordinator.draggingOut.value, isFalse);

      provider.addFileForTest(const FileReference(pathname: '/tmp/drag_test'));
      await coordinator.beginExternalDrag();
      expect(coordinator.draggingOut.value, isTrue);

      await tester.pump(const Duration(milliseconds: 500));
      expect(coordinator.draggingOut.value, isFalse);

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        dragOutChannel,
        null,
      );
    });
  });
}
