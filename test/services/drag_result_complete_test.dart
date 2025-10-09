import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/drag_result.dart';

void main() {
  group('DragOperation tests', () {
    test('DragOperationX.parse deve analisar corretamente as strings', () {
      expect(DragOperationX.parse('copy'), DragOperation.copy);
      expect(DragOperationX.parse('move'), DragOperation.move);
      expect(DragOperationX.parse(null), DragOperation.unknown);
      expect(DragOperationX.parse('invalid'), DragOperation.unknown);
    });

    test('DragOperation.name deve retornar o nome correto', () {
      expect(DragOperation.copy.name, 'copy');
      expect(DragOperation.move.name, 'move');
      expect(DragOperation.unknown.name, 'unknown');
    });
  });

  group('ChannelDragResult tests', () {
    test(
      'ChannelDragResult.parse deve analisar corretamente Map com status ok',
      () {
        final result = ChannelDragResult.parse({'status': 'ok', 'op': 'copy'});

        expect(result, isA<ChannelDragSuccess>());
        expect(result.isSuccess, true);
        expect(result.operation, DragOperation.copy);
      },
    );

    test('ChannelDragResult.parse deve analisar corretamente Map com erro', () {
      final result = ChannelDragResult.parse({
        'status': 'error',
        'code': 'access_denied',
        'message': 'Access denied',
      });

      expect(result, isA<ChannelDragError>());
      expect(result.isSuccess, false);
      expect((result as ChannelDragError).code, 'access_denied');
      expect(result.message, 'Access denied');
    });

    test('ChannelDragResult.parse deve lidar com Map de erro incompleto', () {
      final result = ChannelDragResult.parse({'status': 'error'});

      expect(result, isA<ChannelDragError>());
      expect((result as ChannelDragError).code, 'unknown_error');
      expect(result.message, 'Unknown drag error');
    });

    test(
      'ChannelDragResult.parse deve analisar corretamente dados legacy (string)',
      () {
        final result = ChannelDragResult.parse('copy');

        expect(result, isA<ChannelDragSuccess>());
        expect(result.operation, DragOperation.copy);
      },
    );

    test(
      'ChannelDragResult.parse deve lidar com exceção durante o parsing',
      () {
        final result = ChannelDragResult.parse(123);

        expect(result, isA<ChannelDragSuccess>());
        expect(result.operation, DragOperation.unknown);
      },
    );

    test('operation getter deve retornar a operação correta', () {
      final success = ChannelDragSuccess(DragOperation.move);
      final error = ChannelDragError(code: 'test', message: 'Test error');

      expect(success.operation, DragOperation.move);
      expect(error.operation, DragOperation.unknown);
    });
  });
}
