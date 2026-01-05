import 'package:easier_drop/services/analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'AnalyticsService comprehensive coverage including release-mode branches',
    () async {
      final service = AnalyticsService.instance;

      // Cover kDebugMode = true as usual
      AnalyticsService.debugTestMode = true;
      service.info('test debug true');
      service.trackEvent('test_event_debug');

      // Switch to simulated "Release Mode" for coverage
      AnalyticsService.debugTestMode = false;

      // Covers initialization branch
      await service.initialize();

      // Covers trackEvent branch for release
      service.trackEvent('test_event_release');

      // Covers local log branch for release (should do nothing)
      service.info('this should not be logged locally in release');

      // Reset for other tests
      AnalyticsService.debugTestMode = true;
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
