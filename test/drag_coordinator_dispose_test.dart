import 'package:easier_drop/controllers/drag_coordinator.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/services/constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'DragCoordinator init idempotent and dispose cancels monitoring',
    (tester) async {
      // Mock start/stop counting
      int startCalls = 0;
      int stopCalls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(PlatformChannels.fileDrop),
            (call) async {
              if (call.method == PlatformChannels.startMonitor) startCalls++;
              if (call.method == PlatformChannels.stopMonitor) stopCalls++;
              return null;
            },
          );

      final provider = FilesProvider(enableMonitoring: false);
      await tester.pumpWidget(
        MultiProvider(
          providers: [ChangeNotifierProvider.value(value: provider)],
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(width: 10, height: 10),
          ),
        ),
      );
      final ctx = tester.element(find.byType(SizedBox));
      final coord = DragCoordinator(ctx);
      await coord.init();
      await coord.init(); // idempotent second call
      expect(startCalls, 1);

      // Add path event to ensure subscription active
      final codec = const StandardMethodCodec();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            PlatformChannels.fileDropEvents,
            codec.encodeSuccessEnvelope(["/tmp/a.txt"]),
            (_) {},
          );
      await tester.pump(const Duration(milliseconds: 20));
      coord.dispose();
      expect(stopCalls, 1);
    },
  );
}
