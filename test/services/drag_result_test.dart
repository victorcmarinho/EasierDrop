import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/drag_result.dart';

void main() {
  group('DragOperationX.parse', () {
    test(
      'parse copy',
      () => expect(DragOperationX.parse('copy'), DragOperation.copy),
    );
    test(
      'parse move',
      () => expect(DragOperationX.parse('move'), DragOperation.move),
    );
    test(
      'parse null -> unknown',
      () => expect(DragOperationX.parse(null), DragOperation.unknown),
    );
    test(
      'parse other -> unknown',
      () => expect(DragOperationX.parse('x'), DragOperation.unknown),
    );
  });

  group('ChannelDragResult.parse legacy string', () {
    test('legacy copy string', () {
      final r = ChannelDragResult.parse('copy');
      expect(r.isSuccess, isTrue);
      expect(r.operation, DragOperation.copy);
    });
    test('legacy unknown', () {
      final r = ChannelDragResult.parse('weird');
      expect(r.isSuccess, isTrue);
      expect(r.operation, DragOperation.unknown);
    });
  });

  group('ChannelDragResult.parse map structured', () {
    test('success map copy', () {
      final r = ChannelDragResult.parse({'status': 'ok', 'op': 'move'});
      expect(r.isSuccess, isTrue);
      expect(r.operation, DragOperation.move);
    });
    test('error map', () {
      final r = ChannelDragResult.parse({
        'status': 'error',
        'code': 'E',
        'message': 'fail',
      });
      expect(r.isSuccess, isFalse);
      expect(r.operation, DragOperation.unknown);
      expect(r, isA<ChannelDragError>());
      final err = r as ChannelDragError;
      expect(err.code, 'E');
      expect(err.message, 'fail');
    });
    test('malformed map ignored', () {
      final r = ChannelDragResult.parse({'unexpected': 123});
      expect(
        r.isSuccess,
        isFalse,
      ); // missing status -> becomes error? (logic returns error branch)
    });
  });

  group('ChannelDragResult.parse unknown raw', () {
    test('int raw returns success unknown', () {
      final r = ChannelDragResult.parse(123);
      expect(r.isSuccess, isTrue);
      expect(r.operation, DragOperation.unknown);
    });
  });
}
