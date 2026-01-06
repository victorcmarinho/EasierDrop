import 'package:easier_drop/services/analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'AnalyticsService comprehensive coverage including release-mode branches',
    () async {
      final service = AnalyticsService.instance;

      // Case 1: Debug Mode
      AnalyticsService.debugTestMode = true;
      service.info('test debug true');
      service.trackEvent('test_event_debug');

      // Case 2: Simulation of Release Mode
      AnalyticsService.debugTestMode = false;
      AnalyticsService.testAppKey = 'test_key';

      // Hook into trackEvent to avoid Aptabase platform call
      String? trackedName;
      AnalyticsService.testTrackEvent = (name, props) {
        trackedName = name;
      };

      // Need to have initialized true for coverage
      // Actually, trackEvent returns early if !_initialized, but if testTrackEvent is set, it returns before that.
      // To cover line 53, we need _initialized = true.
      // So let's initialize it in debug mode first.
      AnalyticsService.debugTestMode = true;
      await service.initialize();
      AnalyticsService.debugTestMode = false;

      service.trackEvent('test_event_release');
      expect(trackedName, 'test_event_release');

      // Case 3: Not initialized
      // (Already initialized in singleton, so we can't easily reset it, but Step 1 covered it)

      // Covers local log branch for release (should do nothing)
      service.info('this should not be logged locally in release');

      // Reset hook
      AnalyticsService.testTrackEvent = null;
    },
  );

  test('AnalyticsService all methods and aliases', () {
    final service = AnalyticsService.instance;
    AnalyticsService.debugTestMode = true;

    service.trace('trace');
    service.debug('debug');
    service.info('info');
    service.warn('warn');
    service.error('error');

    AnalyticsService.sTrace('sTrace');
    AnalyticsService.sDebug('sDebug');
    AnalyticsService.sInfo('sInfo');
    AnalyticsService.sWarn('sWarn');
    AnalyticsService.sError('sError');

    service.appStarted();
    service.fileAdded(extension: 'txt');
    service.fileAdded();
    service.fileRemoved(extension: 'png');
    service.fileRemoved();
    service.fileLimitReached();
    service.fileShared(count: 3);
    service.fileDroppedOut();
    service.shakeWindowCreated();
    service.shakeDetected(1.0, 2.0);
    service.updateCheckStarted();
    service.updateAvailable('1.1.0');
    service.settingsOpened();
    service.settingsChanged('foo', 'bar');
  });
}
