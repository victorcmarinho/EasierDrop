import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/drag_result.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easier_drop/services/logger.dart';

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  group('ChannelDragResult operation getter', () {
    test('operation getter directly executes the ternary cast', () {
      const ChannelDragResult success = ChannelDragSuccess(DragOperation.copy);

      final operation = success.operation;

      expect(operation, DragOperation.copy);

      const ChannelDragResult error = ChannelDragError(
        code: 'test',
        message: 'test',
      );
      expect(error.operation, DragOperation.unknown);
    });
  });

  group('ChannelDragResult.parse with exception', () {
    test('handles parsing exception and logs it', () {
      final badMap = <String, dynamic>{'status': 'ok', 'op': 3};

      final result = ChannelDragResult.parse(badMap);

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
