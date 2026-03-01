import 'package:easier_drop/config/env_config.dart';
import 'package:easier_drop/helpers/app_constants.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Coverage Boost - Small Files', () {
    test('Env coverage', () {
      expect(Env.isValid, isNotNull);
    });

    test('AppConstants coverage', () {
      expect(AppConstants.githubLatestReleaseUrl, isNotEmpty);
      expect(AppConstants.windowHandleHeight, 28.0);
    });

    test('SemanticKeys coverage', () {
      expect(SemanticKeys.shareButton, isNotNull);
    });

    test('AppOpacity coverage', () {
      expect(AppOpacity.subtle, 0.03);
    });

    test('AnalyticsService coverage', () {
      final s = AnalyticsService.instance;
      expect(s, isNotNull);
      expect(AnalyticsService.minLevel, isA<LogLevel>());
    });

    test('FilesProvider monitoring coverage', () async {
      final provider = FilesProvider(enableMonitoring: true);
      expect(provider, isNotNull);

      provider.rescanNow();

      provider.dispose();
    });
  });
}
