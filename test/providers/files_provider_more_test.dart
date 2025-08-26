import 'dart:io';
import 'dart:typed_data';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/services/constants.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FilesProvider extra branches', () {
    setUp(() {
      SettingsService.instance.maxFiles = 50;
    });

    test('adds icon data when channel returns bytes', () async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        const MethodChannel(PlatformChannels.fileIcon),
        (call) async {
          if (call.method == 'getFileIcon') {
            return Uint8List.fromList([1, 2, 3]);
          }
          return null;
        },
      );
      final dir = await Directory.systemTemp.createTemp('fp_icon');
      final f = File('${dir.path}/icon.test')..writeAsStringSync('x');
      final p = FilesProvider(enableMonitoring: false);
      await p.addFile(FileReference(pathname: f.path));
      expect(p.files.first.iconData, isNotNull);
    });

    test('invalid missing file skipped', () async {
      final p = FilesProvider(enableMonitoring: false);
      await p.addFile(FileReference(pathname: '/path/does/not/exist.xyz'));
      expect(p.files, isEmpty);
    });

    test('rescan removes deleted file', () async {
      final dir = await Directory.systemTemp.createTemp('fp_rescan');
      final f = File('${dir.path}/gone.tmp')..writeAsStringSync('abc');
      final p = FilesProvider(enableMonitoring: false);
      await p.addFile(FileReference(pathname: f.path));
      expect(p.files, isNotEmpty);
      await f.delete();
      p.rescanNow();
      // allow microtask notify
      await Future.delayed(Duration.zero);
      expect(p.files, isEmpty);
    });
  });
}
