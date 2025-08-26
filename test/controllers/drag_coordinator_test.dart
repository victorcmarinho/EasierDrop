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

    // Simula arquivos
    provider.files; // ensure lazy list init
    provider.addFileForTest(const FileReference(pathname: '/tmp/a'));
    provider.addFileForTest(const FileReference(pathname: '/tmp/b'));
    await tester.pump();
    expect(provider.files.length, 2);

    // COPY -> mantém
    coord.handleOutboundTest({'status': 'ok', 'op': 'copy'});
    expect(provider.files.length, 2);

    // UNKNOWN -> mantém
    coord.handleOutboundTest({'status': 'ok', 'op': 'weird'});
    expect(provider.files.length, 2);

    // MOVE -> limpa (usa microtask notifyListeners). Pump para processar microtasks.
    coord.handleOutboundTest({'status': 'ok', 'op': 'move'});
    await tester.pump(); // process clear microtask
    expect(provider.files.length, 0);
  });
}
