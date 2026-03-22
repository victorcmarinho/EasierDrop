import 'package:easier_drop/controllers/drag_coordinator.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/services/file_drop_service.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DragCoordinator', () {
    late FilesProvider provider;
    late DragCoordinator coordinator;
    late BuildContext context;



    setUp(() async {
      provider = FilesProvider(enableMonitoring: false);
      try {
        await FileDropService.instance.stop();
      } catch (_) {}
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

    testWidgets('Mapeamento de resultados de drag outbound', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      context = tester.element(find.byType(SizedBox).first);
      coordinator = DragCoordinator(context);

      provider.addFileForTest(const FileReference(pathname: '/test'));

      // Error status (WARN)
      coordinator.handleOutboundTest({'status': 'error'});
      expect(provider.files.length, 1);

      // Copy (Retain)
      coordinator.handleOutboundTest({'status': 'ok', 'op': 'copy'});
      expect(provider.files.length, 1);

      // Move (Clear)
      coordinator.handleOutboundTest({'status': 'ok', 'op': 'move'});
      await tester.pump();
      expect(provider.files.length, 0);

      // Unknown (Retain)
      provider.addFileForTest(const FileReference(pathname: '/unknown_test'));
      coordinator.handleOutboundTest({'status': 'ok', 'op': 'unknown'});
      expect(provider.files.length, 1);

      // Hover
      coordinator.setHover(true);
      expect(coordinator.hovering.value, isTrue);
      coordinator.setHover(false);
      expect(coordinator.hovering.value, isFalse);

      // Clear when already empty (branching)
      provider.clear();
      coordinator.handleOutboundTest({'status': 'ok', 'op': 'move'});
      expect(provider.files.length, 0);
    });

    testWidgets('beginExternalDrag com lista vazia (cobertura)', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      context = tester.element(find.byType(SizedBox).first);
      coordinator = DragCoordinator(context);

      await coordinator.beginExternalDrag();
      expect(coordinator.draggingOut.value, isFalse);
    });
  });
}
