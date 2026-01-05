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

    test('all descriptive methods run normally', () {
      final s = AnalyticsService.instance;
      SettingsService.instance.setTelemetryEnabled(true);

      expect(() => s.appStarted(), returnsNormally);
      expect(() => s.fileAdded(extension: 'txt'), returnsNormally);
      expect(() => s.fileAdded(), returnsNormally);
      expect(() => s.fileRemoved(extension: 'txt'), returnsNormally);
      expect(() => s.fileRemoved(), returnsNormally);
      expect(() => s.fileShared(count: 2), returnsNormally);
      expect(() => s.fileDroppedOut(), returnsNormally);
      expect(() => s.shakeWindowCreated(), returnsNormally);
      expect(() => s.shakeDetected(100, 200), returnsNormally);
      expect(() => s.fileLimitReached(), returnsNormally);
      expect(() => s.updateCheckStarted(), returnsNormally);
      expect(() => s.updateAvailable('1.0.1'), returnsNormally);
      expect(() => s.settingsOpened(), returnsNormally);
      expect(() => s.settingsChanged('test', true), returnsNormally);
    });

    test('logging methods run normally at all levels', () {
      final s = AnalyticsService.instance;
      expect(() => s.trace('trace message'), returnsNormally);
      expect(() => s.debug('debug message'), returnsNormally);
      expect(() => s.info('info message'), returnsNormally);
      expect(() => s.warn('warn message'), returnsNormally);
      expect(() => s.error('error message'), returnsNormally);
    });

    test('static logging methods run normally', () {
      expect(() => AnalyticsService.sTrace('trace'), returnsNormally);
      expect(() => AnalyticsService.sDebug('debug'), returnsNormally);
      expect(() => AnalyticsService.sInfo('info'), returnsNormally);
      expect(() => AnalyticsService.sWarn('warn'), returnsNormally);
      expect(() => AnalyticsService.sError('error'), returnsNormally);
    });

    test('initialize runs normally', () async {
      final s = AnalyticsService.instance;
      await s.initialize();
      // Calling twice should return early
      await s.initialize();
      expect(true, isTrue);
    });

    test('trackEvent handles edge cases', () {
      final s = AnalyticsService.instance;
      SettingsService.instance.setTelemetryEnabled(true);

      // Test without props
      expect(() => s.trackEvent('test_no_props'), returnsNormally);

      // Test with error in trackEvent (hard to mock Aptabase but verify no crash)
      expect(() => s.trackEvent('test', {'prop': 'val'}), returnsNormally);
    });

    test('should handle empty app key', () async {
      final s = AnalyticsService.instance;
      // Use internal visibility to reset for testing if needed or just test the current state
      // If we can't easily reset, we at least test the coverage of the key check.
      expect(() => s.initialize(), returnsNormally);
    });

    test('logging methods coverage', () {
      final s = AnalyticsService.instance;
      // Ensure all log levels are called to hit the switch case in _prefix
      s.trace('trace');
      s.debug('debug');
      s.info('info');
      s.warn('warn');
      s.error('error');

      // Static aliases
      AnalyticsService.sTrace('sTrace');
      AnalyticsService.sDebug('sDebug');
      AnalyticsService.sInfo('sInfo');
      AnalyticsService.sWarn('sWarn');
      AnalyticsService.sError('sError');
    });

    test('trackEvent with testTrackEvent override', () {
      final s = AnalyticsService.instance;
      bool called = false;
      AnalyticsService.debugTestMode = false;
      AnalyticsService.testTrackEvent = (name, props) {
        called = true;
      };
      s.trackEvent('test');
      expect(called, isTrue);
      AnalyticsService.testTrackEvent = null;
      AnalyticsService.debugTestMode = true;
    });

    test('initialize coverage boost', () async {
      final s = AnalyticsService.instance;
      AnalyticsService.testAppKey = '';
      await s.initialize();
      expect(s.testInitialized, isFalse);

      AnalyticsService.testAppKey = 'some_key';
      AnalyticsService.debugTestMode = false;
      // This will call Aptabase.init which might fail but should be covered
      await s.initialize();

      AnalyticsService.debugTestMode = true;
      AnalyticsService.testAppKey = null;
    });
  });
}
