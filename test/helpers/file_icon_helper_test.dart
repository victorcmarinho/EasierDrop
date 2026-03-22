import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/helpers/macos/file_icon_helper.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/services/constants.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockAnalyticsService mockAnalytics;
  const channel = MethodChannel(PlatformChannels.fileIcon);

  setUp(() {
    mockAnalytics = MockAnalyticsService();
    AnalyticsService.instance = mockAnalytics;
    FileIconHelper.debugClearCache();
    
    when(() => mockAnalytics.error(any(), tag: any(named: 'tag'))).thenReturn(null);
  });

  group('FileIconHelper', () {
    test('getFileIcon returns data and caches it', () async {
      final fakeData = Uint8List.fromList([1, 2, 3]);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getFileIcon') return fakeData;
        return null;
      });

      final result1 = await FileIconHelper.getFileIcon('test.png');
      expect(result1, equals(fakeData));

      // Second call should use cache (no second method call)
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => throw Exception('Should use cache'));
      
      final result2 = await FileIconHelper.getFileIcon('test.png');
      expect(result2, equals(fakeData));
    });

    test('getFileIcon returns null for no extension', () async {
      final result = await FileIconHelper.getFileIcon('test');
      expect(result, isNull);
    });

    test('getFileIcon logs error and returns null on exception', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => throw Exception('Native error'));

      final result = await FileIconHelper.getFileIcon('error.png');
      expect(result, isNull);
      verify(() => mockAnalytics.error(any(), tag: any(named: 'tag'))).called(1);
    });

    test('getFilePreview returns data', () async {
      final fakeData = Uint8List.fromList([4, 5, 6]);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getFilePreview') return fakeData;
        return null;
      });

      final result = await FileIconHelper.getFilePreview('preview.png');
      expect(result, equals(fakeData));
    });

    test('getFilePreview logs error and returns null on exception', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => throw Exception('Preview error'));

      final result = await FileIconHelper.getFilePreview('error_preview.png');
      expect(result, isNull);
      verify(() => mockAnalytics.error(any(), tag: any(named: 'tag'))).called(1);
    });
  });
}
