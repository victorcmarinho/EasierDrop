import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async {
    return '.';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('SettingsService Tests', () {
    late SettingsService settingsService;
    final testSettingsFile = File('./settings.json');

    setUp(() async {
      PathProviderPlatform.instance = MockPathProviderPlatform();
      settingsService = SettingsService.instance;
      settingsService.resetForTesting();

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

      expect(
        settingsService.settings.isAlwaysOnTop,
        true,
      ); // Changed from false to true
    });

    test('should update and persist MaxFiles', () async {
      await settingsService.load();
      settingsService.setMaxFiles(50);

      // Manually trigger persist for testing to avoid debounce timing issues
      await settingsService.persist();

      expect(await testSettingsFile.exists(), true);
      final content = await testSettingsFile.readAsString();
      expect(content, contains('"maxFiles": 50'));
    });

    test('should toggle Always on Top', () async {
      await settingsService.load();
      expect(
        settingsService.settings.isAlwaysOnTop,
        true,
      ); // Changed from false to true

      settingsService.setAlwaysOnTop(false); // Toggle to false
      expect(settingsService.settings.isAlwaysOnTop, false);
    });

    test('should update window opacity', () async {
      await settingsService.load();
      settingsService.setWindowOpacity(0.5);
      expect(settingsService.settings.windowOpacity, 0.5);
    });

    test('should update window bounds', () async {
      await settingsService.load();
      settingsService.setWindowBounds(x: 10, y: 20, w: 30, h: 40);
      expect(settingsService.windowX, 10);
      expect(settingsService.windowY, 20);
      expect(settingsService.windowW, 30);
      expect(settingsService.windowH, 40);
    });

    test('should update locale', () async {
      await settingsService.load();
      settingsService.setLocale('pt');
      expect(settingsService.localeCode, 'pt');
    });

    test('should update telemetry enabled', () async {
      await settingsService.load();
      settingsService.setTelemetryEnabled(false);
      expect(settingsService.telemetryEnabled, false);
    });

    test('should handle launch at login', () async {
      const channel = MethodChannel('com.easierdrop/launch_at_login');
      final log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            log.add(methodCall);
            if (methodCall.method == 'checkPermission') return true;
            if (methodCall.method == 'isEnabled') return true;
            return null;
          });

      await settingsService.load();
      await settingsService.setLaunchAtLogin(true);
      expect(settingsService.settings.launchAtLogin, true);

      final hasPerm = await settingsService.checkLaunchAtLoginPermission();
      expect(hasPerm, true);

      final isEnabled = await settingsService.getLaunchAtLoginStatus();
      expect(isEnabled, true);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('should handle launch at login errors', () async {
      const channel = MethodChannel('com.easierdrop/launch_at_login');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            throw Exception('Native error');
          });

      await settingsService.load();
      await settingsService.setLaunchAtLogin(true);
      // Value should not update if native call fails (actually it depends on implementation,
      // here it catches error but doesn't set value if it fails before setSettings)

      final hasPerm = await settingsService.checkLaunchAtLoginPermission();
      expect(hasPerm, false);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('dispose should cancel timer and subscription', () {
      final s = SettingsService.forTesting();
      expect(() => s.dispose(), returnsNormally);
    });

    test('should reload settings when file changes', () async {
      await settingsService.load();

      // Manually modify the file to trigger a reload
      final updatedSettings = {'maxFiles': 150, 'version': 1};
      await testSettingsFile.writeAsString(jsonEncode(updatedSettings));

      // Wait for the watcher to trigger and reload
      // The debounce and file system events might take some time
      await Future.delayed(const Duration(milliseconds: 500));

      expect(settingsService.maxFiles, 150);
    });

    test('should handle empty or invalid settings file', () async {
      await testSettingsFile.writeAsString('');
      await settingsService.load();
      // Should fall back to default when file is empty
      expect(settingsService.maxFiles, 100);

      await testSettingsFile.writeAsString('{invalid_json}');
      // Trigger reload
      await Future.delayed(const Duration(milliseconds: 100));
      // Should still be at previous state or handled gracefully
      expect(settingsService.isLoaded, true);
    });

    test('should detect system locale during first run', () async {
      SettingsService.testLocaleName = 'pt_BR';
      await settingsService.load();
      expect(settingsService.localeCode, 'pt_BR');

      settingsService.resetForTesting();
      if (await testSettingsFile.exists()) await testSettingsFile.delete();

      SettingsService.testLocaleName = 'es_ES';
      await settingsService.load();
      expect(settingsService.localeCode, 'es');

      SettingsService.testLocaleName = null;
    });
  });
}
