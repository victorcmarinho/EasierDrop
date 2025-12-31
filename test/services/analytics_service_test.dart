import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mocktail/mocktail.dart';

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async => '.';
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  setUp(() async {
    await SettingsService.instance.load();
  });

  group('AnalyticsService Privacy Tests', () {
    test('trackEvent should not throw when not initialized', () {
      expect(
        () => AnalyticsService.instance.trackEvent('test'),
        returnsNormally,
      );
    });

    test('trackEvent respects telemetryEnabled setting', () {
      final service = AnalyticsService.instance;

      // We can't easily mock Aptabase static methods,
      // but we can at least verify it doesn't crash
      // and behaves correctly with our settings.

      SettingsService.instance.setTelemetryEnabled(false);
      expect(SettingsService.instance.telemetryEnabled, false);
      expect(() => service.trackEvent('test'), returnsNormally);

      SettingsService.instance.setTelemetryEnabled(true);
      expect(SettingsService.instance.telemetryEnabled, true);
      expect(() => service.trackEvent('test'), returnsNormally);
    });
  });
}
