import 'package:easier_drop/helpers/macos/file_icon_helper.dart';
import 'package:easier_drop/services/constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FileIconHelper cache', () {
    final callCount = <String, int>{};

    setUp(() {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        const MethodChannel(PlatformChannels.fileIcon),
        (call) async {
          if (call.method == 'getFileIcon') {
            final path = call.arguments as String;
            final ext = path.split('.').last;
            callCount[ext] = (callCount[ext] ?? 0) + 1;
            return Uint8List.fromList([ext.length]);
          } else if (call.method == 'getFilePreview') {
            final path = call.arguments as String;
            if (path.contains('fail')) return null;
            return Uint8List.fromList([1, 2, 3]);
          }
          return null;
        },
      );
      callCount.clear();
    });

    test(
      'returns cached icon without extra channel call before eviction',
      () async {
        final path = '/tmp/file.ext0';
        await FileIconHelper.getFileIcon(path);
        expect(callCount['ext0'], 1);

        await FileIconHelper.getFileIcon(path);
        expect(callCount['ext0'], 1);
      },
    );

    test('LRU evicts oldest after capacity exceeded', () async {
      FileIconHelper.debugClearCache();
      callCount.clear();

      for (int i = 0; i < 128; i++) {
        await FileIconHelper.getFileIcon('/tmp/file_$i.ext$i');
      }
      expect(callCount.length, 128);

      await FileIconHelper.getFileIcon('/tmp/file_0.ext0');
      expect(callCount['ext0'], 1);

      await FileIconHelper.getFileIcon('/tmp/file_999.ext999');
      expect(callCount['ext999'], 1);

      await FileIconHelper.getFileIcon('/tmp/file_1.ext1');
      expect(callCount['ext1'], 2);
    });

    test('getFilePreview returns data on success', () async {
      final preview = await FileIconHelper.getFilePreview('/tmp/image.png');
      expect(preview, isNotNull);
      expect(preview!.length, 3);
    });

    test('getFilePreview returns null on failure', () async {
      final preview = await FileIconHelper.getFilePreview('/tmp/fail.png');
      expect(preview, isNull);
    });
  });
}
