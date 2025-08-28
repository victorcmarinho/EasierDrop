import 'dart:io';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _EdgePathProvider extends PathProviderPlatform {
  final Directory dir;
  _EdgePathProvider(this.dir);
  @override
  Future<String?> getApplicationSupportPath() async => dir.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('SettingsService edge cases', () {
    late Directory dir;
    late PathProviderPlatform original;

    setUp(() async {
      original = PathProviderPlatform.instance;
      dir = await Directory.systemTemp.createTemp('settings_edges');
      PathProviderPlatform.instance = _EdgePathProvider(dir);
    });

    tearDown(() async {
      PathProviderPlatform.instance = original;
      await dir.delete(recursive: true);
    });

    test('setMaxFiles ignores non-positive and same value', () async {
      final s = SettingsService.instance;
      final orig = s.maxFiles;
      s.setMaxFiles(orig);
      expect(s.maxFiles, orig);
      s.setMaxFiles(0);
      expect(s.maxFiles, orig);
    });

    test('load handles empty file gracefully', () async {
      final s = SettingsService.instance;
      final f = File('${dir.path}/settings.json');
      await f.writeAsString('');
      await s.load();
      expect(s.isLoaded, isTrue);
    });
  });
}
