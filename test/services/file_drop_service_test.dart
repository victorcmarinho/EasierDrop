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
      // Criar um listener para o stream
      final receivedPaths = <List<String>>[];
      final subscription = service.filesStream.listen((paths) {
        receivedPaths.add(paths);
      });

      // Enviar um evento de teste
      final testPaths = ['path/to/file1.txt', 'path/to/file2.txt'];
      service.pushTestEvent(testPaths);

      // Aguardar o processamento assíncrono
      await Future.delayed(Duration.zero);

      // Verificar que o evento foi recebido
      expect(receivedPaths, contains(testPaths));

      // Limpar
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

      // We can't easily mock the stream portion of EventChannel without more setup,
      // but we can at least invoke the methods and check monitoring state.

      await service.start();
      expect(service.isMonitoring, isTrue);

      // Test double start
      await service.start();
      expect(service.isMonitoring, isTrue);

      await service.stop();
      expect(service.isMonitoring, isFalse);

      // Test double stop
      await service.stop();
      expect(service.isMonitoring, isFalse);

      await service.dispose();
      expect(service.isMonitoring, isFalse);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
  });
}
