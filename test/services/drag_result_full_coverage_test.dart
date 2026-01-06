import 'package:easier_drop/services/drag_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ChannelDragResult coverage boost for malformed maps and getters', () {
    // Malformed maps
    final r1 = ChannelDragResult.parse({'status': 'invalid'});
    expect(r1.isSuccess, isFalse);
    expect(
      r1.operation,
      DragOperation.unknown,
    ); // Hits operation getter for non-success

    final r2 = ChannelDragResult.parse({});
    expect(r2.isSuccess, isTrue); // empty map returns success unknown

    final r3 = ChannelDragResult.parse(null);
    expect(r3.isSuccess, isTrue); // null returns ChannelDragSuccess(unknown)

    final r4 = ChannelDragResult.parse({'status': 'ok', 'op': 'copy'});
    expect(r4.isSuccess, isTrue);
    expect(
      r4.operation,
      DragOperation.copy,
    ); // Hits operation getter for success

    final r5 = ChannelDragResult.parse({'status': 'ok', 'op': 'move'});
    expect(r5.operation, DragOperation.move);

    final r6 = ChannelDragResult.parse({'status': 'ok', 'op': 'invalid'});
    expect(r6.operation, DragOperation.unknown);

    final r7 = ChannelDragResult.parse('copy');
    expect(r7.isSuccess, isTrue);
    expect(r7.operation, DragOperation.copy);

    final r8 = ChannelDragResult.parse(123); // Invalid type
    expect(r8.isSuccess, isTrue);
    expect(r8.operation, DragOperation.unknown);

    final r9 = ChannelDragResult.parse({'status': 'ok'}); // Missing op
    expect(r9.operation, DragOperation.unknown);

    // Explicitly hit the success class
    const success = ChannelDragSuccess(DragOperation.copy);
    expect(success.operation, DragOperation.copy);
  });

  test('DragOperationX coverage', () {
    expect(DragOperationX.parse('copy'), DragOperation.copy);
    expect(DragOperationX.parse('move'), DragOperation.move);
    expect(DragOperationX.parse('other'), DragOperation.unknown);
    expect(DragOperation.copy.name, 'copy');
    expect(DragOperation.move.name, 'move');
    expect(DragOperation.unknown.name, 'unknown');
  });

  test('ChannelDragResult error cases', () {
    final r = ChannelDragResult.parse({
      'status': 'error',
      'code': '404',
      'message': 'Not found',
    });
    expect(r, isA<ChannelDragError>());
    final err = r as ChannelDragError;
    expect(err.code, '404');
    expect(err.message, 'Not found');
    expect(r.isSuccess, isFalse);
    expect(r.operation, DragOperation.unknown);
  });
}
