import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsService extends Mock implements SettingsService {}

void main() {
  late MockSettingsService mockSettings;

  setUp(() {
    mockSettings = MockSettingsService();
    // Default behaviors for mock (if we could use it)
    when(() => mockSettings.telemetryEnabled).thenReturn(true);
    when(() => mockSettings.maxFiles).thenReturn(10);
  });

  group('AnalyticsService', () {
    test('instance is accessible', () {
      expect(AnalyticsService.instance, isNotNull);
    });

    test('initialize handles empty key', () async {
      AnalyticsService.debugTestMode = true;
      AnalyticsService.testAppKey = '';
      AnalyticsService.instance.resetForTesting();
      await AnalyticsService.instance.initialize();
      expect(AnalyticsService.instance.testInitialized, isFalse);
    });

    test('trackEvent handles not initialized and disabled', () {
      AnalyticsService.instance.resetForTesting();
      // Since we can't mock SettingsService.instance easily, we'll use the real one's defaults
      // Default telemetryEnabled is true.
      AnalyticsService.instance.trackEvent('test'); // Returns early because not initialized
    });

    test('Log levels and prefixes', () {
      AnalyticsService.debugTestMode = true;
      AnalyticsService.minLevel = LogLevel.trace;
      AnalyticsService.sTrace('msg');
      AnalyticsService.sDebug('msg');
      AnalyticsService.sInfo('msg');
      AnalyticsService.sWarn('msg');
      AnalyticsService.sError('msg');
      
      AnalyticsService.minLevel = LogLevel.error;
      AnalyticsService.sInfo('hidden'); 
    });

    test('trackEvent respects testTrackEvent', () {
      AnalyticsService.debugTestMode = false;
      AnalyticsService.testAppKey = 'test-key';
      AnalyticsService.instance.resetForTesting();
      
      var eventCalled = false;
      AnalyticsService.testTrackEvent = (name, props) {
        eventCalled = true;
      };
      
      AnalyticsService.instance.trackEvent('test');
      expect(eventCalled, isTrue);
      AnalyticsService.testTrackEvent = null;
    });
    
    test('All event methods cover trackEvent calls', () {
      AnalyticsService.debugTestMode = true; // Use debug mode to simplify
      final s = AnalyticsService.instance;
      
      s.appStarted();
      s.fileAdded(extension: 'txt');
      s.fileRemoved(extension: 'txt');
      s.fileShared(count: 1);
      s.fileDroppedOut();
      s.shakeWindowCreated();
      s.shakeDetected(0, 0);
      s.shakeLimitReached();
      s.fileLimitReached();
      s.updateCheckStarted();
      s.updateAvailable('1.0.0');
      s.settingsOpened();
      s.settingsChanged('key', 'value');
      s.windowShown();
      s.windowHidden();
    });
  });
}
