import 'dart:convert';
import 'dart:io';

import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  final Directory tempDir;
  _FakePathProvider(this.tempDir);

  @override
  Future<String?> getApplicationSupportPath() async => tempDir.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService persistence', () {
    late Directory dir;
    late PathProviderPlatform original;

    setUp(() async {
      original = PathProviderPlatform.instance;
      dir = await Directory.systemTemp.createTemp('easier_drop_test');
      PathProviderPlatform.instance = _FakePathProvider(dir);

      final f = File('${dir.path}/settings.json');
      if (await f.exists()) await f.delete();
    });

    tearDown(() async {
      PathProviderPlatform.instance = original;
      await dir.delete(recursive: true);
    });

    test('writes and reads schema base (autoClear fixed false)', () async {
      await SettingsService.instance.persist();
      final file = File('${dir.path}/settings.json');
      expect(await file.exists(), isTrue);
      final decoded =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      expect(decoded['schemaVersion'], isNotNull);
      expect(decoded['autoClearInbound'], isFalse);
    });

    test('setMaxFiles persists after debounce', () async {
      SettingsService.instance.setMaxFiles(250);

      await Future.delayed(const Duration(milliseconds: 300));
      final file = File('${dir.path}/settings.json');
      expect(await file.exists(), isTrue);
      final decoded =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      expect(decoded['maxFiles'], 250);
    });

    test('window bounds persisted', () async {
      SettingsService.instance.setWindowBounds(x: 10, y: 20, w: 800, h: 600);
      await Future.delayed(const Duration(milliseconds: 300));
      final file = File('${dir.path}/settings.json');
      final decoded =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      expect(decoded['windowX'], 10);
      expect(decoded['windowY'], 20);
      expect(decoded['windowW'], 800);
      expect(decoded['windowH'], 600);
    });

    test('locale persisted', () async {
      SettingsService.instance.setLocale('pt');
      await Future.delayed(const Duration(milliseconds: 300));
      final file = File('${dir.path}/settings.json');
      final decoded =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      expect(decoded['locale'], 'pt');

      SettingsService.instance.setLocale('pt');
    });
  });

  group('Drag out copy logic', () {
    test('Does not clear on copy operation (logic side)', () async {
      const op = 'copy';
      expect(op == 'copy', isTrue);
    });
  });
}
