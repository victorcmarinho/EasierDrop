import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/drag_result.dart';

void main() {
  group('DragOperationX', () {
    test('parse works correctly', () {
      expect(DragOperationX.parse('copy'), DragOperation.copy);
      expect(DragOperationX.parse('move'), DragOperation.move);
      expect(DragOperationX.parse('invalid'), DragOperation.unknown);
      expect(DragOperationX.parse(null), DragOperation.unknown);
    });

    test('name getter works correctly', () {
      expect(DragOperation.copy.name, 'copy');
      expect(DragOperation.move.name, 'move');
      expect(DragOperation.unknown.name, 'unknown');
    });
  });

  group('ChannelDragResult', () {
    test('isSuccess and operation getters', () {
      const success = ChannelDragSuccess(DragOperation.copy);
      expect(success.isSuccess, true);
      expect(success.operation, DragOperation.copy);

      const error = ChannelDragError(code: '404', message: 'Not Found');
      expect(error.isSuccess, false);
      expect(error.operation, DragOperation.unknown);
      expect(error.code, '404');
      expect(error.message, 'Not Found');
    });

    test('parse handles Map ok with op', () {
      final res = ChannelDragResult.parse({'status': 'ok', 'op': 'move'});
      expect(res.isSuccess, true);
      expect(res.operation, DragOperation.move);
    });

    test('parse handles Map ok without op', () {
      final res = ChannelDragResult.parse({'status': 'ok'});
      expect(res.isSuccess, true);
      expect(res.operation, DragOperation.unknown);
    });

    test('parse handles empty Map', () {
      final res = ChannelDragResult.parse({});
      expect(res.isSuccess, true);
      expect(res.operation, DragOperation.unknown);
    });

    test('parse handles Map with error', () {
      final res = ChannelDragResult.parse({'status': 'error', 'code': '1', 'message': 'fail'});
      expect(res.isSuccess, false);
      expect((res as ChannelDragError).code, '1');
      expect(res.message, 'fail');
    });

    test('parse handles Map with error defaulting code/message', () {
      final res = ChannelDragResult.parse({'status': 'error'});
      expect(res.isSuccess, false);
      expect((res as ChannelDragError).code, 'unknown_error');
      expect(res.message, 'Unknown drag error');
    });

    test('parse handles String', () {
      final res = ChannelDragResult.parse('copy');
      expect(res.isSuccess, true);
      expect(res.operation, DragOperation.copy);
    });

    test('parse handles unknown type', () {
      final res = ChannelDragResult.parse(123);
      expect(res.isSuccess, true);
      expect(res.operation, DragOperation.unknown);
    });

    test('parse catch block coverage — triggers error path', () {
      // Passing {status: 'ok', op: 42} causes `raw['op'] as String?` to throw a
      // TypeError inside safeCallSync. The catch block (lines 54-60) then logs a
      // warning and returns ChannelDragSuccess(DragOperation.unknown).
      final res = ChannelDragResult.parse({'status': 'ok', 'op': 42});
      expect(res.isSuccess, isTrue);
      expect(res.operation, DragOperation.unknown);
    });
  });
}
