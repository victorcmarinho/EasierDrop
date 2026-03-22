import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:easier_drop/helpers/macos/file_icon_helper.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/services/analytics_service.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('file_icon_channel');
  late MockAnalyticsService mockAnalytics;

  setUp(() {
    mockAnalytics = MockAnalyticsService();
    AnalyticsService.instance = mockAnalytics;
    when(() => mockAnalytics.error(any(), tag: any(named: 'tag'))).thenReturn(null);
    FileIconHelper.debugClearCache();
    
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getFileIcon') {
        return Uint8List.fromList([1, 2, 3]);
      }
      if (call.method == 'getFilePreview') {
        return Uint8List.fromList([4, 5, 6]);
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('FileIconHelper', () {
    test('getFileIcon returns data and caches it', () async {
      final data1 = await FileIconHelper.getFileIcon('test.png');
      expect(data1, isNotNull);
      expect(data1, Uint8List.fromList([1, 2, 3]));

      // Second call should hit the cache (no second channel call)
      // We can verify this by changing the mock return value
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => Uint8List.fromList([9, 9, 9]));
      
      final data2 = await FileIconHelper.getFileIcon('test.png');
      expect(data2, Uint8List.fromList([1, 2, 3])); // Still the old data
    });

    test('getFileIcon returns null for no extension', () async {
      final data = await FileIconHelper.getFileIcon('test');
      expect(data, isNull);
    });

    test('getFilePreview returns data', () async {
      final data = await FileIconHelper.getFilePreview('test.png');
      expect(data, Uint8List.fromList([4, 5, 6]));
    });

    test('getFileIcon handle error', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw Exception('Native Error');
      });

      final data = await FileIconHelper.getFileIcon('error.png');
      expect(data, isNull);
      verify(() => mockAnalytics.error(any(), tag: 'FileIconHelper')).called(1);
    });

    test('getFilePreview handle error', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw Exception('Native Error');
      });

      final data = await FileIconHelper.getFilePreview('error.png');
      expect(data, isNull);
      verify(() => mockAnalytics.error(any(), tag: 'FileIconHelper')).called(1);
    });

    test('cache eviction', () async {
      // Create 129 different extensions to trigger eviction
      for (int i = 0; i <= 128; i++) {
        await FileIconHelper.getFileIcon('file.$i');
      }
      // The first one 'file.0' should have been evicted
    });
    
    test('_extractExtension edge cases', () async {
      expect(await FileIconHelper.getFileIcon('file.'), isNull);
      expect(await FileIconHelper.getFileIcon('.hidden'), isNotNull); // hidden is the extension?
      // in our implementation: dotIndex = 0, length = 7. extension = hidden.
    });
  });
}
