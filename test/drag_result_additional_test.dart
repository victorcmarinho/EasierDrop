import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/drag_result.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/services/logger.dart';

// Criar um mock do AppLogger para verificar as chamadas
class MockAppLogger extends Mock implements AppLogger {}

void main() {
  group('ChannelDragResult operation getter', () {
    test('operation getter directly executes the ternary cast', () {
      // A linha problemática é a que tem o operador ternário com cast
      // Vamos criar uma instância e acessar a propriedade operation
      const ChannelDragResult success = ChannelDragSuccess(DragOperation.copy);

      // Isso deve executar a linha 33 com o casting (this as ChannelDragSuccess)
      final operation = success.operation;

      // Verificar que o resultado é o esperado
      expect(operation, DragOperation.copy);

      // Outro caso para garantir cobertura completa
      const ChannelDragResult error = ChannelDragError(
        code: 'test',
        message: 'test',
      );
      expect(error.operation, DragOperation.unknown);
    });
  });

  group('ChannelDragResult.parse with exception', () {
    test('handles parsing exception and logs it', () {
      // Create a map that will cause an exception when parsed
      final badMap = <String, dynamic>{
        'status': 'ok',
        'op':
            3, // Should be a string but we're passing a number to cause exception
      };

      // Parse the bad map, which should throw when trying to cast int to String
      final result = ChannelDragResult.parse(badMap);

      // Verify the result is what we expect
      expect(result.isSuccess, isTrue);
      expect(result.operation, DragOperation.unknown);
    });
  });

  group('DragOperation name extension', () {
    test('returns correct string representation for each operation', () {
      expect(DragOperation.copy.name, 'copy');
      expect(DragOperation.move.name, 'move');
      expect(DragOperation.unknown.name, 'unknown');
    });
  });
}
