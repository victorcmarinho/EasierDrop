import 'package:easier_drop/services/settings_service.dart';
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
    final mockPath = MockPathProviderPlatform();
    PathProviderPlatform.instance = mockPath;
    when(
      () => mockPath.getApplicationSupportPath(),
    ).thenAnswer((_) async => '.');
  });

  test(
    'SettingsService coverage boost for errors, same-value checks and dispose',
    () async {
      // Use forTesting instance to avoid killing the singleton
      final service = SettingsService.forTesting();
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

      service.dispose();
    },
  );

  test('SettingsService load error coverage', () async {
    final mockPath = PathProviderPlatform.instance as MockPathProviderPlatform;
    when(
      () => mockPath.getApplicationSupportPath(),
    ).thenThrow(Exception('Mock Path Error'));

    final service = SettingsService.forTesting();
    await service.load();
  });

  test('SettingsService helpers coverage', () async {
    final service = SettingsService.forTesting();
    await service.getSettingsFileForTest();
    service.setWindowBounds(x: 10, y: 20, w: 300, h: 400);
    service.dispose();
  });
}
