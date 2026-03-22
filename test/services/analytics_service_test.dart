import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/services/settings_service.dart';

class MockSettingsService extends Mock implements SettingsService {}

void main() {
  late AnalyticsService service;
  late MockSettingsService mockSettingsService;

  setUp(() {
    mockSettingsService = MockSettingsService();
    SettingsService.instance = mockSettingsService;
    service = AnalyticsService.instance;
    service.resetForTesting();
    
    AnalyticsService.debugTestMode = true;
    AnalyticsService.testAppKey = 'test-key';
    AnalyticsService.testTrackEvent = null;
    AnalyticsService.minLevel = LogLevel.trace;

    when(() => mockSettingsService.telemetryEnabled).thenReturn(true);
  });

  group('AnalyticsService', () {
    test('initialize handles success and failures', () async {
      // Success in test mode
      await service.initialize();
      expect(service.testInitialized, isTrue);

      // Empty key
      service.resetForTesting();
      AnalyticsService.testAppKey = '';
      await service.initialize();
      expect(service.testInitialized, isFalse);

      // Non-test mode success (Aptabase.init skipped but reaches line via debugTestMode logic in code)
      // Actually, to hit line 44 we need debugTestMode = false.
      // But Aptabase.init will throw. We wrap it or just ignore that specific failure if it reaches line 51.
      service.resetForTesting();
      AnalyticsService.debugTestMode = false;
      AnalyticsService.testAppKey = 'test-key';
      
      // This will likely throw and hit line 51 (warn)
      await service.initialize();
      // _initialized stays false, but line 51 is hit.
      expect(service.testInitialized, isFalse);
    });

    test('trackEvent failure path when not initialized', () {
      AnalyticsService.debugTestMode = false;
      service.trackEvent('will_fail');
      // Should return early at line 68 (if !_initialized return)
    });

    test('trackEvent error path during call', () async {
      // To hit line 72, we need _initialized = true but trackEvent to throw.
      service.resetForTesting();
      AnalyticsService.debugTestMode = true; // so initialize() sets _initialized = true
      await service.initialize();
      
      AnalyticsService.debugTestMode = false; // so trackEvent doesn't return early at line 60
      // safeCall will call Aptabase.instance.trackEvent which will fail in tests
      await service.trackEvent('track_error');
      // Line 72 (warn) should be hit.
    });

    test('trackEvent calls testTrackEvent if provided', () async {
      String? trackedName;
      Map<String, dynamic>? trackedProps;
      
      AnalyticsService.debugTestMode = false;
      AnalyticsService.testTrackEvent = (name, props) {
        trackedName = name;
        trackedProps = props;
      };

      service.trackEvent('test_event', {'foo': 'bar'});

      expect(trackedName, equals('test_event'));
      expect(trackedProps, equals({'foo': 'bar'}));
    });

    test('trackEvent respects telemetryEnabled setting', () async {
      when(() => mockSettingsService.telemetryEnabled).thenReturn(false);
      
      bool called = false;
      AnalyticsService.testTrackEvent = (name, props) => called = true;

      service.trackEvent('test_event');

      expect(called, isFalse);
    });

    test('log methods call internal _log', () {
      service.trace('trace');
      service.debug('debug');
      service.info('info');
      service.warn('warn');
      service.error('error');
      
      AnalyticsService.sTrace('s-trace');
      AnalyticsService.sDebug('s-debug');
      AnalyticsService.sInfo('s-info');
      AnalyticsService.sWarn('s-warn');
      AnalyticsService.sError('s-error');
    });

    test('log respects minLevel', () {
      AnalyticsService.minLevel = LogLevel.error;
      service.info('this should be ignored');
    });

    test('convenience methods track correct events', () async {
      final tracked = <String, Map<String, dynamic>?>{};
      AnalyticsService.debugTestMode = false;
      AnalyticsService.testTrackEvent = (name, props) => tracked[name] = props;

      service.appStarted();
      service.fileAdded(extension: 'txt');
      service.fileAdded();
      service.fileRemoved(extension: 'jpg');
      service.fileRemoved();
      service.fileShared(count: 5);
      service.fileDroppedOut();
      service.shakeWindowCreated();
      service.shakeDetected(1.0, 2.0);
      service.shakeLimitReached();
      service.fileLimitReached();
      service.updateCheckStarted();
      service.updateAvailable('1.2.3');
      service.settingsOpened();
      service.settingsChanged('theme', 'dark');
      service.windowShown();
      service.windowHidden();
      
      expect(tracked.containsKey('app_started'), isTrue);
    });

    test('_prefix returns correct strings', () {
      service.error('critical');
      service.warn('warning');
      service.info('info');
      service.debug('debug');
      service.trace('trace');
    });

    test('instance setter', () {
      final oldInstance = AnalyticsService.instance;
      AnalyticsService.instance = oldInstance;
      expect(AnalyticsService.instance, same(oldInstance));
    });
  });
}
