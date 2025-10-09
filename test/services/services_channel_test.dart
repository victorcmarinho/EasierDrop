import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/drag_out_service.dart';
import 'package:easier_drop/services/file_drop_service.dart';
import 'package:easier_drop/services/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DragOutService', () {
    final calls = <MethodCall>[];
    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(PlatformChannels.fileDragOut),
            (call) async {
              calls.add(call);
              return null;
            },
          );
    });

    test('beginDrag sends method with items and prevents reentrancy', () async {
      await DragOutService.instance.beginDrag(['a', 'b']);
      expect(calls.length, 1);
      expect(calls.first.method, PlatformChannels.beginDrag);
      final args = calls.first.arguments as Map;
      expect(args['items'], ['a', 'b']);

      await DragOutService.instance.beginDrag(['c']);
      expect(calls.length, 1, reason: 'Second call suppressed during drag');
      await Future.delayed(const Duration(milliseconds: 120));
      await DragOutService.instance.beginDrag(['d']);
      expect(calls.length, 2, reason: 'Flag reset after delay');
    });
  });

  group('FileDropService', () {
    final methodCalls = <MethodCall>[];
    late StreamSubscription sub;
    final received = <List<String>>[];

    setUp(() async {
      methodCalls.clear();
      received.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(PlatformChannels.fileDrop),
            (call) async {
              methodCalls.add(call);
              return null;
            },
          );

      const eventChannel = EventChannel(PlatformChannels.fileDropEvents);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(eventChannel.name, (message) async {
            Timer(const Duration(milliseconds: 10), () {
              TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
                  .handlePlatformMessage(
                    eventChannel.name,
                    const StandardMethodCodec().encodeSuccessEnvelope([
                      'one',
                      'two',
                    ]),
                    (_) {},
                  );
            });
            return const StandardMethodCodec().encodeSuccessEnvelope(null);
          });

      await FileDropService.instance.start();
      sub = FileDropService.instance.filesStream.listen(received.add);
      await Future.delayed(const Duration(milliseconds: 40));
    });

    tearDown(() async {
      await sub.cancel();
      await FileDropService.instance.stop();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(PlatformChannels.fileDropEvents, null);
    });

    test('start invokes startMonitor and receives events', () async {
      expect(
        methodCalls.map((c) => c.method),
        contains(PlatformChannels.startMonitor),
      );
      expect(received, isNotEmpty);
      expect(received.first, ['one', 'two']);
    });

    test('stop invokes stopMonitor', () async {
      await FileDropService.instance.stop();
      expect(
        methodCalls.map((c) => c.method),
        contains(PlatformChannels.stopMonitor),
      );
    });
  });
}
