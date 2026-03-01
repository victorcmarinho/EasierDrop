import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:easier_drop/services/file_drop_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FileDropService', () {
    late FileDropService service;

    setUp(() {
      service = FileDropService.instance;
    });

    test('filesStream retorna um Stream', () {
      expect(service.filesStream, isA<Stream<List<String>>>());
    });

    test('isMonitoring inicialmente é falso', () {
      expect(service.isMonitoring, isFalse);
    });

    test('pushTestEvent envia eventos para o stream', () async {
      final receivedPaths = <List<String>>[];
      final subscription = service.filesStream.listen((paths) {
        receivedPaths.add(paths);
      });

      final testPaths = ['path/to/file1.txt', 'path/to/file2.txt'];
      service.pushTestEvent(testPaths);

      await Future.delayed(Duration.zero);

      expect(receivedPaths, contains(testPaths));

      await subscription.cancel();
    });

    test('setMethodCallHandler configura um handler', () {
      Future<dynamic> handler(MethodCall call) async {
        return null;
      }

      expect(() => service.setMethodCallHandler(handler), returnsNormally);
      service.setMethodCallHandler(null);
    });

    test('start/stop/dispose works with mocked channels', () async {
      const channel = MethodChannel('file_drop_channel');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            return null;
          });

      await service.start();
      expect(service.isMonitoring, isTrue);

      await service.start();
      expect(service.isMonitoring, isTrue);

      await service.stop();
      expect(service.isMonitoring, isFalse);

      await service.stop();
      expect(service.isMonitoring, isFalse);

      await service.dispose();
      expect(service.isMonitoring, isFalse);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
  });
}
