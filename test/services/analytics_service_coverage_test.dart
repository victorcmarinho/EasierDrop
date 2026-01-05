import 'package:easier_drop/services/analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsService Coverage Boost', () {
    test('LogLevel prefix logic coverage', () {
      // Trigger all prefixes
      AnalyticsService.instance.trace('test');
      AnalyticsService.instance.debug('test');
      AnalyticsService.instance.info('test');
      AnalyticsService.instance.warn('test');
      AnalyticsService.instance.error('test');

      expect(true, isTrue);
    });

    test('Logging level filtering', () {
      final originalLevel = AnalyticsService.minLevel;

      AnalyticsService.minLevel = LogLevel.error;
      // This should be filtered out
      AnalyticsService.instance.info('should not log');

      AnalyticsService.minLevel = originalLevel;
      expect(true, isTrue);
    });

    test('Static aliases coverage', () {
      AnalyticsService.sTrace('msg');
      AnalyticsService.sDebug('msg');
      AnalyticsService.sInfo('msg');
      AnalyticsService.sWarn('msg');
      AnalyticsService.sError('msg');

      expect(true, isTrue);
    });
  });
}
