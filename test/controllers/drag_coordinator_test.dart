import 'package:easier_drop/controllers/drag_coordinator.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('DragCoordinator', () {
    late FilesProvider provider;
    late BuildContext context;
    late DragCoordinator coordinator;

    setUp(() async {
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

    testWidgets('Clears files on move, retains on copy/unknown', (
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

      coordinator.handleOutboundTest({'status': 'ok', 'op': 'weird'});
      expect(provider.files.length, 2);

      coordinator.handleOutboundTest({'status': 'ok', 'op': 'move'});
      await tester.pump();
      expect(provider.files.length, 0);
    });

    testWidgets('handles different status responses', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      context = tester.element(find.byType(SizedBox));
      coordinator = DragCoordinator(context);

      provider.addFileForTest(const FileReference(pathname: '/tmp/test'));
      await tester.pump();
      expect(provider.files.length, 1);

      // Test with error status
      coordinator.handleOutboundTest({'status': 'error', 'op': 'move'});
      expect(provider.files.length, 1); // Should not clear on error

      // Test with missing status
      coordinator.handleOutboundTest({'op': 'move'});
      expect(provider.files.length, 1); // Should not clear without status

      // Test with ok status and move
      coordinator.handleOutboundTest({'status': 'ok', 'op': 'move'});
      await tester.pump();
      expect(provider.files.length, 0); // Should clear on ok move
    });

    testWidgets('handles empty and null responses', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      context = tester.element(find.byType(SizedBox));
      coordinator = DragCoordinator(context);

      provider.addFileForTest(const FileReference(pathname: '/tmp/test'));
      await tester.pump();
      expect(provider.files.length, 1);

      // Test with empty map
      coordinator.handleOutboundTest({});
      expect(provider.files.length, 1);

      // Test with null values
      coordinator.handleOutboundTest({'status': null, 'op': null});
      expect(provider.files.length, 1);
    });

    testWidgets('coordinator can be created and disposed', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      context = tester.element(find.byType(SizedBox));
      coordinator = DragCoordinator(context);

      // Test basic functionality
      expect(coordinator, isA<DragCoordinator>());

      // Test multiple files
      provider.addFileForTest(const FileReference(pathname: '/tmp/file1'));
      provider.addFileForTest(const FileReference(pathname: '/tmp/file2'));
      provider.addFileForTest(const FileReference(pathname: '/tmp/file3'));
      await tester.pump();
      expect(provider.files.length, 3);

      // Test move operation clears all files
      coordinator.handleOutboundTest({'status': 'ok', 'op': 'move'});
      await tester.pump();
      expect(provider.files.length, 0);
    });

    testWidgets('handles various operation types', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      context = tester.element(find.byType(SizedBox));
      coordinator = DragCoordinator(context);

      // Test with different operation types
      final operations = ['copy', 'link', 'generic', 'unknown', ''];

      for (final op in operations) {
        provider.addFileForTest(FileReference(pathname: '/tmp/test_$op'));
        await tester.pump();
        expect(provider.files.length, 1);

        coordinator.handleOutboundTest({'status': 'ok', 'op': op});

        if (op == 'move') {
          expect(provider.files.length, 0);
        } else {
          expect(provider.files.length, 1);
          provider.clear();
        }
      }
    });

    testWidgets('init and dispose cover more lines', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      context = tester.element(find.byType(SizedBox));
      coordinator = DragCoordinator(context);

      // Mock channels
      const dropChannel = MethodChannel('file_drop_channel');
      const dragOutChannel = MethodChannel('file_drag_out_channel');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(dropChannel, (call) async => null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(dragOutChannel, (call) async => null);

      await coordinator.init();
      // Calling init again moves early return
      await coordinator.init();

      coordinator.setHover(true);
      expect(coordinator.hovering.value, isTrue);

      coordinator.dispose();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(dropChannel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(dragOutChannel, null);
    });

    testWidgets('beginExternalDrag handles states', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      context = tester.element(find.byType(SizedBox));
      coordinator = DragCoordinator(context);

      const dragOutChannel = MethodChannel('file_drag_out_channel');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(dragOutChannel, (call) async => null);

      // No files case
      await coordinator.beginExternalDrag();
      expect(coordinator.draggingOut.value, isFalse);

      // With files
      provider.addFileForTest(const FileReference(pathname: '/tmp/test'));
      await coordinator.beginExternalDrag();
      expect(coordinator.draggingOut.value, isTrue);

      // Wait for timers to complete
      await tester.pump(const Duration(milliseconds: 500));

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(dragOutChannel, null);
    });
  });
}
