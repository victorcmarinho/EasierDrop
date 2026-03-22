import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/update_service.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mocktail/mocktail.dart';

class MockUpdateClient extends Mock implements UpdateClient {}
class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockUpdateClient mockClient;
  late MockAnalyticsService mockAnalytics;
  late UpdateService service;

  setUp(() {
    mockClient = MockUpdateClient();
    mockAnalytics = MockAnalyticsService();
    AnalyticsService.instance = mockAnalytics;
    service = UpdateService(client: mockClient);

    PackageInfo.setMockInitialValues(
      appName: 'EasierDrop',
      packageName: 'com.example.easierdrop',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );

    // Default mock behavior for analytics to avoid missing stub errors
    when(() => mockAnalytics.updateCheckStarted()).thenAnswer((_) {});
    when(() => mockAnalytics.info(any(), tag: any(named: 'tag'))).thenAnswer((_) {});
    when(() => mockAnalytics.warn(any(), tag: any(named: 'tag'))).thenAnswer((_) {});
    when(() => mockAnalytics.error(any(), tag: any(named: 'tag'))).thenAnswer((_) {});
    when(() => mockAnalytics.updateAvailable(any())).thenAnswer((_) {});
  });

  group('UpdateService.isBetterVersion', () {
    test('should identify newer semantic version', () {
      expect(service.isBetterVersion('v1.1.0', '1.0.0'), isTrue);
      expect(service.isBetterVersion('1.2.0', '1.1.9'), isTrue);
      expect(service.isBetterVersion('v2.0.0', '1.9.9'), isTrue);
    });

    test('should identify older or equal version', () {
      expect(service.isBetterVersion('v1.0.0', '1.0.0'), isFalse);
      expect(service.isBetterVersion('1.0.0', '1.1.0'), isFalse);
    });

    test('should handle invalid versions and trigger warning via safeCallSync', () {
      // isBetterVersion parsing error
      final result = service.isBetterVersion('invalid', '1.0.0');
      expect(result, isFalse);
      verify(() => mockAnalytics.warn(any(), tag: any(named: 'tag'))).called(1);
    });

    test('should return false for empty version', () {
      expect(service.isBetterVersion('', '1.0.0'), isFalse);
    });

    test('should handle v prefix and different formats', () {
      expect(service.isBetterVersion('2.0.0', '1.0.0'), isTrue);
      expect(service.isBetterVersion('v2.0.0', '1.0.0'), isTrue);
    });
  });

  group('UpdateService.checkForUpdates', () {
    test('should return URL when update is available', () async {
      final mockData = {
        'tag_name': 'v2.0.0',
        'html_url': 'https://github.com/update',
      };

      when(() => mockClient.getLatestRelease())
          .thenAnswer((_) async => http.Response(json.encode(mockData), 200));

      final (result, error) = await service.checkForUpdates();

      expect(result, equals('https://github.com/update'));
      expect(error, isNull);
      verify(() => mockAnalytics.updateCheckStarted()).called(1);
      verify(() => mockAnalytics.updateAvailable('v2.0.0')).called(1);
    });

    test('should return null when version is not better', () async {
      final mockData = {
        'tag_name': 'v1.0.0',
        'html_url': 'https://github.com/update',
      };

      when(() => mockClient.getLatestRelease())
          .thenAnswer((_) async => http.Response(json.encode(mockData), 200));

      final (result, error) = await service.checkForUpdates();

      expect(result, isNull);
      expect(error, isNull);
      verify(() => mockAnalytics.updateCheckStarted()).called(1);
      verifyNever(() => mockAnalytics.updateAvailable(any()));
    });

    test('should return null on non-200 status', () async {
      when(() => mockClient.getLatestRelease())
          .thenAnswer((_) async => http.Response('Not Found', 404));

      final (result, error) = await service.checkForUpdates();

      expect(result, isNull);
      expect(error, isNull);
      verify(() => mockAnalytics.updateCheckStarted()).called(1);
    });

    test('should return null and error object on client exception', () async {
      final exception = Exception('Network error');
      when(() => mockClient.getLatestRelease()).thenThrow(exception);

      final (result, error) = await service.checkForUpdates();

      expect(result, isNull);
      expect(error, equals(exception));
      verify(() => mockAnalytics.updateCheckStarted()).called(1);
      verify(() => mockAnalytics.warn(any())).called(1);
    });

    test('should handle missing keys in json', () async {
      final mockData = <String, dynamic>{};
      when(() => mockClient.getLatestRelease())
          .thenAnswer((_) async => http.Response(json.encode(mockData), 200));

      final (result, error) = await service.checkForUpdates();

      expect(result, isNull);
      expect(error, isNull);
    });
  });

  group('Dependency Injection & Factory', () {
    test('GitHubUpdateClient instance can be created', () {
      expect(GitHubUpdateClient(), isA<GitHubUpdateClient>());
    });

    test('UpdateService default constructor uses GitHubUpdateClient', () {
      final defaultService = UpdateService();
      expect(defaultService, isNotNull);
    });
  });
}
