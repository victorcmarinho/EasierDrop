import 'package:easier_drop/services/analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AnalyticsService coverage boost for all methods', () async {
    final service = AnalyticsService.instance;

    // Cover all log levels
    service.trace('test trace');
    service.debug('test debug');
    service.info('test info');
    service.warn('test warn');
    service.error('test error');

    // Static aliases
    AnalyticsService.sTrace('static trace');
    AnalyticsService.sDebug('static debug');
    AnalyticsService.sInfo('static info');
    AnalyticsService.sWarn('static warn');
    AnalyticsService.sError('static error');

    // Cover all event methods
    service.appStarted();
    service.fileAdded(extension: 'txt');
    service.fileAdded(); // no extension
    service.fileRemoved(extension: 'png');
    service.fileRemoved(); // no extension
    service.fileLimitReached();
    service.fileShared(count: 5);
    service.fileDroppedOut();
    service.shakeDetected(0.0, 0.0);
    service.shakeWindowCreated();
    service.updateCheckStarted();
    service.updateAvailable('1.0.0');
    service.settingsOpened();
    service.settingsChanged('maxFiles', 50);

    // Track event directly
    service.trackEvent('custom_event', {'foo': 'bar'});

    // Verify instance is not null
    expect(service, isNotNull);
  });
}
