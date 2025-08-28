import 'package:easier_drop/controllers/drag_coordinator.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Outbound error results do not clear files', (tester) async {
    final provider = FilesProvider(enableMonitoring: false);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<FilesProvider>.value(value: provider),
        ],
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(),
        ),
      ),
    );
    final ctx = tester.element(find.byType(SizedBox));
    final coord = DragCoordinator(ctx);

    provider.addFileForTest(const FileReference(pathname: '/tmp/a'));
    provider.addFileForTest(const FileReference(pathname: '/tmp/b'));
    await tester.pump();
    expect(provider.files.length, 2);

    coord.handleOutboundTest({
      'status': 'error',
      'code': 'E',
      'message': 'fail',
    });
    expect(provider.files.length, 2, reason: 'Error should not clear files');

    coord.handleOutboundTest({'unexpected': 123});
    expect(provider.files.length, 2, reason: 'Malformed map should not clear');
  });

  testWidgets('beginExternalDrag with no files does nothing', (tester) async {
    final provider = FilesProvider(enableMonitoring: false);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<FilesProvider>.value(value: provider),
        ],
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(),
        ),
      ),
    );
    final ctx = tester.element(find.byType(SizedBox));
    final coord = DragCoordinator(ctx);
    expect(coord.draggingOut.value, isFalse);
    await coord.beginExternalDrag();

    expect(coord.draggingOut.value, isFalse);
  });
}
