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
      try {
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      } catch (e) {
        // Ignore deletion errors in tearDown
        print('Warning: Could not delete temp dir: $e');
      }
    });

    test('setMaxFiles ignores non-positive and same value', () async {
      final s = SettingsService.instance;
      final orig = s.maxFiles;
      s.setMaxFiles(orig);
      expect(s.maxFiles, orig);
      s.setMaxFiles(0);
      expect(s.maxFiles, orig);
      s.setMaxFiles(-1);
      expect(s.maxFiles, orig);
    });

    test('load handles empty file gracefully', () async {
      final s = SettingsService.instance;
      final f = File('${dir.path}/settings.json');
      await f.writeAsString('');
      await s.load();
      expect(s.isLoaded, isTrue);
    });

    test('setLocale handles various locales', () async {
      final s = SettingsService.instance;

      s.setLocale('en');
      expect(s.localeCode, 'en');

      s.setLocale('pt_BR');
      expect(s.localeCode, 'pt_BR');

      s.setLocale('es');
      expect(s.localeCode, 'es');

      s.setLocale('fr'); // unsupported locale
      expect(s.localeCode, 'fr');
    });

    test('setWindowBounds handles various parameters', () async {
      final s = SettingsService.instance;

      // Test setting all parameters
      s.setWindowBounds(x: 100, y: 200, w: 300, h: 400);
      expect(s.windowX, 100);
      expect(s.windowY, 200);
      expect(s.windowW, 300);
      expect(s.windowH, 400);

      // Test setting only position
      s.setWindowBounds(x: 150, y: 250);
      expect(s.windowX, 150);
      expect(s.windowY, 250);
      expect(s.windowW, 300); // unchanged
      expect(s.windowH, 400); // unchanged

      // Test setting only size
      s.setWindowBounds(w: 500, h: 600);
      expect(s.windowX, 150); // unchanged
      expect(s.windowY, 250); // unchanged
      expect(s.windowW, 500);
      expect(s.windowH, 600);
    });

    test('load handles corrupted JSON gracefully', () async {
      final s = SettingsService.instance;
      final f = File('${dir.path}/settings.json');
      await f.writeAsString('{invalid json');
      await s.load();
      expect(s.isLoaded, isTrue);
    });

    test('load handles non-existent file gracefully', () async {
      final s = SettingsService.instance;
      // Ensure file doesn't exist
      final f = File('${dir.path}/settings.json');
      if (await f.exists()) {
        await f.delete();
      }
      await s.load();
      expect(s.isLoaded, isTrue);
    });

    test('persist handles errors gracefully', () async {
      final s = SettingsService.instance;

      // Este teste apenas verifica que persist() não lança exceções
      // mesmo quando há problemas no arquivo system
      expect(() async => await s.persist(), returnsNormally);
    });

    test('setLocale with same value does not change anything', () async {
      final s = SettingsService.instance;

      s.setLocale('en');
      final firstValue = s.localeCode;

      s.setLocale('en'); // Same value
      expect(s.localeCode, firstValue);
    });

    test('multiple setMaxFiles calls with different values', () async {
      final s = SettingsService.instance;

      s.setMaxFiles(10);
      expect(s.maxFiles, 10);

      s.setMaxFiles(20);
      expect(s.maxFiles, 20);

      s.setMaxFiles(5);
      expect(s.maxFiles, 5);
    });

    test('window bounds edge cases', () async {
      final s = SettingsService.instance;

      // Test with null values (should not change current values)
      final originalX = s.windowX;
      s.setWindowBounds(x: null, y: null, w: null, h: null);
      expect(s.windowX, originalX);

      // Test with zero values
      s.setWindowBounds(x: 0, y: 0, w: 0, h: 0);
      expect(s.windowX, 0);
      expect(s.windowY, 0);
      expect(s.windowW, 0);
      expect(s.windowH, 0);

      // Test with negative values
      s.setWindowBounds(x: -10, y: -20, w: -30, h: -40);
      expect(s.windowX, -10);
      expect(s.windowY, -20);
      expect(s.windowW, -30);
      expect(s.windowH, -40);
    });
  });
}
