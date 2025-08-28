import 'package:easier_drop/controllers/drag_coordinator.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Clears files on move, retains on copy/unknown', (tester) async {
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

    provider.files;
    provider.addFileForTest(const FileReference(pathname: '/tmp/a'));
    provider.addFileForTest(const FileReference(pathname: '/tmp/b'));
    await tester.pump();
    expect(provider.files.length, 2);

    coord.handleOutboundTest({'status': 'ok', 'op': 'copy'});
    expect(provider.files.length, 2);

    coord.handleOutboundTest({'status': 'ok', 'op': 'weird'});
    expect(provider.files.length, 2);

    coord.handleOutboundTest({'status': 'ok', 'op': 'move'});
    await tester.pump();
    expect(provider.files.length, 0);
  });
}
