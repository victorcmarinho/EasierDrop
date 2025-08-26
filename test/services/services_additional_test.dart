import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/drag_out_service.dart';
import 'package:easier_drop/services/file_drop_service.dart';
import 'package:easier_drop/services/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Services additional', () {
    test('DragOutService prevents re-entrant beginDrag', () async {
      int invokes = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(PlatformChannels.fileDragOut),
            (call) async {
              invokes++;
              // simulate slow platform call
              await Future.delayed(const Duration(milliseconds: 50));
              return null;
            },
          );
      final s = DragOutService.instance;
      // Fire two calls quickly; second should be ignored due to guard
      s.beginDrag(['a']);
      s.beginDrag(['b']);
      await Future.delayed(const Duration(milliseconds: 200));
      expect(invokes, 1);
    });

    test('FileDropService stop no-op when not started', () async {
      // No mock handler required because stop will early return
      await FileDropService.instance.stop();
      expect(FileDropService.instance.isMonitoring, isFalse);
    });
  });
}
