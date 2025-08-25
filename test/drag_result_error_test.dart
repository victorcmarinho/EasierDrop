import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/drag_result.dart';

void main() {
  test('ChannelDragResult parses error map', () {
    final r = ChannelDragResult.parse({
      'status': 'error',
      'code': 'perm',
      'message': 'Permission denied',
    });
    expect(r.isSuccess, isFalse);
    expect(r.operation, DragOperation.unknown);
    expect(r, isA<ChannelDragError>());
    final err = r as ChannelDragError;
    expect(err.code, 'perm');
  });

  test('ChannelDragResult legacy string parsing', () {
    final r = ChannelDragResult.parse('move');
    expect(r.isSuccess, isTrue);
    expect(r.operation, DragOperation.move);
  });
}
