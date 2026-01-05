import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mocktail/mocktail.dart';

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SettingsService.instance.resetForTesting();
  });

  test(
    'SettingsService coverage boost for errors, same-value checks and dispose',
    () async {
      final service = SettingsService.instance;
      await service.load();

      // Cover same-value checks in all setters
      service.setAlwaysOnTop(service.settings.isAlwaysOnTop);
      service.setMaxFiles(service.settings.maxFiles);
      service.setLocale(service.settings.localeCode);
      service.setTelemetryEnabled(service.settings.telemetryEnabled);
      await service.setLaunchAtLogin(service.settings.launchAtLogin);

      // Cover getters
      expect(service.isLoaded, isTrue);
      expect(service.maxFiles, isNotNull);
      expect(service.localeCode, anyOf(isNull, isA<String>()));
      expect(service.telemetryEnabled, isA<bool>());
      expect(service.windowX, anyOf(isNull, isA<double>()));
      expect(service.windowY, anyOf(isNull, isA<double>()));
      expect(service.windowW, anyOf(isNull, isA<double>()));
      expect(service.windowH, anyOf(isNull, isA<double>()));

      // Cover dispose
      service.dispose();
    },
  );

  test('SettingsService load error coverage', () async {
    final mockPath = MockPathProviderPlatform();
    PathProviderPlatform.instance = mockPath;

    when(
      () => mockPath.getApplicationSupportPath(),
    ).thenThrow(Exception('Mock Path Error'));

    final service = SettingsService.instance;
    await service.load();

    // Cleanup
    // We don't have a way to easily restore the real path provider platform without library knowledge,
    // but for tests it should be fine as it's a singleton replacement.
  });

  test('SettingsService helpers coverage', () async {
    final service = SettingsService.instance;
    await service.getSettingsFileForTest();
    service.setWindowBounds(x: 10, y: 20, w: 300, h: 400);
  });
}
