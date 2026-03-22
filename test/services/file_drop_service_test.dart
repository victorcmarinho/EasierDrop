import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/services/file_drop_service.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/services/constants.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FileDropService service;
  late MockAnalyticsService mockAnalyticsService;
  
  const MethodChannel methodChannel = MethodChannel(PlatformChannels.fileDrop);

  setUp(() {
    mockAnalyticsService = MockAnalyticsService();
    AnalyticsService.instance = mockAnalyticsService;
    service = FileDropService.instance;
    service.resetForTesting();
    
    // Clear mock handlers before each test
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
    
    // We can't easily clear EventChannel mocks but we can set them
  });

  group('FileDropService', () {
    test('start initiates monitoring and listens to events', () async {
      bool startCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (methodCall) async {
        if (methodCall.method == PlatformChannels.startMonitor) {
          startCalled = true;
          return null;
        }
        return null;
      });

      // Mock EventChannel
      const codec = StandardMethodCodec();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(PlatformChannels.fileDropEvents, (message) async {
        // This is called when the stream is listened to
        final methodCall = codec.decodeMethodCall(message);
        if (methodCall.method == 'listen') {
          return codec.encodeSuccessEnvelope(null);
        }
        return null;
      });

      await service.start();

      expect(startCalled, isTrue);
      expect(service.isMonitoring, isTrue);
    });

    test('start handles errors', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (methodCall) async {
        throw Exception('Native error');
      });

      when(() => mockAnalyticsService.error(any(), tag: any(named: 'tag'))).thenReturn(null);

      await service.start();

      expect(service.isMonitoring, isFalse);
      verify(() => mockAnalyticsService.error(any(), tag: 'FileDropService')).called(1);
    });

    test('filesStream receives events from native', () async {
      // Mock startMonitor
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (methodCall) async => null);

      // Mock EventChannel to send data
      const codec = StandardMethodCodec();
      
      await service.start();
      
      final completer = Completer<List<String>>();
      final sub = service.filesStream.listen((files) {
        completer.complete(files);
      });

      // Simulate event from native
      final message = codec.encodeSuccessEnvelope(['file1.txt', 'file2.jpg']);
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(PlatformChannels.fileDropEvents, message, (_) {});

      final received = await completer.future.timeout(const Duration(seconds: 1));
      expect(received, equals(['file1.txt', 'file2.jpg']));
      
      await sub.cancel();
    });

    test('stop stops monitoring', () async {
      // Start first
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (methodCall) async => null);
      await service.start();
      expect(service.isMonitoring, isTrue);

      bool stopCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (methodCall) async {
        if (methodCall.method == PlatformChannels.stopMonitor) {
          stopCalled = true;
          return null;
        }
        return null;
      });

      await service.stop();

      expect(stopCalled, isTrue);
      expect(service.isMonitoring, isFalse);
    });

    test('stop handles errors', () async {
      // Start first
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (methodCall) async => null);
      await service.start();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (methodCall) async {
        throw Exception('Native error');
      });
      when(() => mockAnalyticsService.error(any(), tag: any(named: 'tag'))).thenReturn(null);

      await service.stop();

      expect(service.isMonitoring, isFalse); // Monitoring is set to false regardless of sync error in this impl
      verify(() => mockAnalyticsService.error(any(), tag: 'FileDropService')).called(1);
    });

    test('pushTestEvent adds events to stream', () async {
      final completer = Completer<List<String>>();
      final sub = service.filesStream.listen((files) {
        completer.complete(files);
      });

      service.pushTestEvent(['test.txt']);

      final received = await completer.future.timeout(const Duration(seconds: 1));
      expect(received, equals(['test.txt']));
      
      await sub.cancel();
    });

    test('dispose cancels subscription and closes controller', () async {
      // Start first
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (methodCall) async => null);
      await service.start();

      await service.dispose();
      
      expect(service.isMonitoring, isFalse);
    });

    test('setMethodCallHandler sets handler on channel', () async {
      bool handlerCalled = false;
      service.setMethodCallHandler((call) async {
        handlerCalled = true;
        return null;
      });

      // Simulate a call to the channel from native (or using binary messenger)
      // Actually setMethodCallHandler sets it on _channel.
      // We can trigger it by sending a message to the channel from "native" side.
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(PlatformChannels.fileDrop, const StandardMethodCodec().encodeMethodCall(const MethodCall('any')), (_) {});

      expect(handlerCalled, isTrue);
    });
  });
}
