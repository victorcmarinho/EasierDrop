import 'dart:io';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('FilesProvider icon integration', () {
    test('adds icon after file insert', () async {
      SettingsService.instance.setMaxFiles(10);

      final dir = await Directory.systemTemp.createTemp('icon_case');
      final f = File('${dir.path}/sample.zzzz')..writeAsStringSync('1');
      final ref = FileReference(pathname: f.path);
      final p = FilesProvider(enableMonitoring: false);
      await p.addFile(ref);
      expect(p.files.first.pathname, ref.pathname);
    });
  });
}
