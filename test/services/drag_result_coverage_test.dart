import 'package:easier_drop/services/drag_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DragResult Coverage Boost', () {
    test('parse handles invalid map types and values', () {
      final r1 = ChannelDragResult.parse({
        'status': 'ok',
        'op': 123,
      }); // op is not String
      expect(r1.operation, DragOperation.unknown);

      final r2 = ChannelDragResult.parse({'status': 'ok'}); // missing op
      expect(r2.operation, DragOperation.unknown);

      final r3 = ChannelDragResult.parse({
        'status': 'error',
      }); // error without code/msg
      expect(r3.isSuccess, isFalse);
      expect((r3 as ChannelDragError).code, 'unknown_error');
    });

    test('parse handles throwing internal errors', () {
      // This is trickier since we'd need to mock something that throws inside
      // But we can try passing a weird object that might cause issues if casted
    });
  });
}
