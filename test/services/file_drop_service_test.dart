import 'package:flutter_test/flutter_test.dart';
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
      // Função de callback
      Future<dynamic> handler(dynamic call) async {
        return null;
      }

      // Deve ser possível definir um handler
      expect(() => service.setMethodCallHandler(handler), returnsNormally);

      // Limpar: remover o handler
      service.setMethodCallHandler(null);
    });

    // Nota: não podemos testar start(), stop() e dispose() diretamente
    // porque eles dependem de plugins nativos que não estão disponíveis nos testes
  });
}
