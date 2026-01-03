import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:io';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async {
    return '.';
  }
}

void main() {
  group('SettingsService Tests', () {
    late SettingsService settingsService;
    final testSettingsFile = File('./settings.json');

    setUp(() async {
      PathProviderPlatform.instance = MockPathProviderPlatform();
      settingsService = SettingsService.instance;

      // Cleanup before test
      if (await testSettingsFile.exists()) {
        await testSettingsFile.delete();
      }
    });

    tearDown(() async {
      if (await testSettingsFile.exists()) {
        await testSettingsFile.delete();
      }
    });

    test('should load default values when no file exists', () async {
      await settingsService.load();

      expect(settingsService.isLoaded, true);
      expect(settingsService.maxFiles, 100); // Default from AppSettings

      expect(settingsService.settings.isAlwaysOnTop, false);
    });

    test('should update and persist MaxFiles', () async {
      await settingsService.load();
      settingsService.setMaxFiles(50);

      expect(settingsService.maxFiles, 50);

      // Verification of file persistence might need a small delay or manual check
      // mocking the write would be better, but integration style here:
      await Future.delayed(const Duration(milliseconds: 300)); // Debounce wait

      expect(await testSettingsFile.exists(), true);
      final content = await testSettingsFile.readAsString();
      expect(content, contains('"maxFiles": 50'));
    });

    test('should toggle Always on Top', () async {
      await settingsService.load();
      expect(settingsService.settings.isAlwaysOnTop, false);

      settingsService.setAlwaysOnTop(true);
      expect(settingsService.settings.isAlwaysOnTop, true);
    });

    test('should update window opacity', () async {
      await settingsService.load();
      // Assuming default is 1.0 or null
      settingsService.setWindowOpacity(0.5);
      expect(settingsService.settings.windowOpacity, 0.5);
    });
  });
}
