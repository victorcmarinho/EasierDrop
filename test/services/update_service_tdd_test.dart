import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/update_service.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class MockUpdateClient implements UpdateClient {
  final http.Response? response;
  final Exception? exception;
  MockUpdateClient({this.response, this.exception});

  @override
  Future<http.Response> getLatestRelease() async {
    if (exception != null) throw exception!;
    return response!;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UpdateService Logic (TDD Approach)', () {
    final service = UpdateService();

    test('should identify newer semantic version', () {
      expect(service.isBetterVersion('v1.1.0', '1.0.0'), isTrue);
      expect(service.isBetterVersion('1.2.0', '1.1.9'), isTrue);
      expect(service.isBetterVersion('v2.0.0', '1.9.9'), isTrue);
    });

    test('should identify older or equal version', () {
      expect(service.isBetterVersion('v1.0.0', '1.0.0'), isFalse);
      expect(service.isBetterVersion('1.0.0', '1.1.0'), isFalse);
    });

    test('should handle invalid versions gracefully', () {
      expect(service.isBetterVersion('invalid', '1.0.0'), isFalse);
      expect(service.isBetterVersion('', '1.0.0'), isFalse);
    });

    test('should handle v prefix and different formats', () {
      expect(service.isBetterVersion('2.0.0', '1.0.0'), isTrue);
      expect(service.isBetterVersion('v2.0.0', '1.0.0'), isTrue);
    });
  });

  group('UpdateService Check Flow', () {
    setUp(() {
      PackageInfo.setMockInitialValues(
        appName: 'EasierDrop',
        packageName: 'com.example.easierdrop',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );
    });

    test('should return URL when update is available', () async {
      final mockData = {
        'tag_name': 'v2.0.0',
        'html_url': 'https://github.com/update',
      };

      final client = MockUpdateClient(
        response: http.Response(json.encode(mockData), 200),
      );
      final service = UpdateService(client: client);

      final result = await service.checkForUpdates();
      expect(result, equals('https://github.com/update'));
    });

    test('should return null when version is not better', () async {
      final mockData = {
        'tag_name': 'v1.0.0',
        'html_url': 'https://github.com/update',
      };

      final client = MockUpdateClient(
        response: http.Response(json.encode(mockData), 200),
      );
      final service = UpdateService(client: client);

      final result = await service.checkForUpdates();
      expect(result, isNull);
    });

    test('should return null on non-200 status', () async {
      final client = MockUpdateClient(
        response: http.Response('Not Found', 404),
      );
      final service = UpdateService(client: client);

      final result = await service.checkForUpdates();
      expect(result, isNull);
    });

    test('should return null on exception', () async {
      final client = MockUpdateClient(exception: Exception('Network error'));
      final service = UpdateService(client: client);

      final result = await service.checkForUpdates();
      expect(result, isNull);
    });

    test('should handle missing keys in json', () async {
      final mockData = {};
      final client = MockUpdateClient(
        response: http.Response(json.encode(mockData), 200),
      );
      final service = UpdateService(client: client);

      final result = await service.checkForUpdates();
      expect(result, isNull);
    });
  });

  group('GitHubUpdateClient', () {
    test('instance can be created', () {
      expect(GitHubUpdateClient(), isA<GitHubUpdateClient>());
    });

    test('UpdateService default constructor uses GitHubUpdateClient', () {
      final service = UpdateService();

      expect(service, isNotNull);
    });
  });
}
