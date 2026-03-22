import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/file_drop_service.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/services/constants.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockAnalyticsService mockAnalytics;
  late FileDropService service;
  const channel = MethodChannel(PlatformChannels.fileDrop);

  setUp(() {
    mockAnalytics = MockAnalyticsService();
    AnalyticsService.instance = mockAnalytics;
    service = FileDropService.instance;
    service.resetForTesting();
    
    when(() => mockAnalytics.error(any(), tag: any(named: 'tag'))).thenReturn(null);
  });

  group('FileDropService', () {
    test('start() invokes native method and listens to events', () async {
      bool startCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == PlatformChannels.startMonitor) {
          startCalled = true;
          return null;
        }
        return null;
      });

      await service.start();
      expect(startCalled, isTrue);
      expect(service.isMonitoring, isTrue);

      // Test event emission
      final future = service.filesStream.first;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(PlatformChannels.fileDropEvents, 
          const StandardMethodCodec().encodeSuccessEnvelope(['file1.txt']), (_) {});
      
      final files = await future;
      expect(files, equals(['file1.txt']));
      
      await service.stop();
    });

    test('start() logs error on exception', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => throw Exception('Start error'));

      await service.start();
      expect(service.isMonitoring, isFalse);
      verify(() => mockAnalytics.error(any(), tag: any(named: 'tag'))).called(1);
    });

    test('stop() invokes native method', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => null);
      await service.start();

      bool stopCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == PlatformChannels.stopMonitor) {
          stopCalled = true;
          return null;
        }
        return null;
      });

      await service.stop();
      expect(stopCalled, isTrue);
      expect(service.isMonitoring, isFalse);
    });
  });
}
