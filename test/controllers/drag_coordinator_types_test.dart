import 'package:easier_drop/controllers/drag_coordinator_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DragCoordinatorTypes Tests', () {
    test('DragState enum values', () {
      expect(DragState.values, contains(DragState.idle));
      expect(DragState.values, contains(DragState.hovering));
      expect(DragState.values, contains(DragState.draggingOut));
    });

    group('DragOperationType', () {
      test('shouldClearFiles getter', () {
        expect(DragOperationType.move.shouldClearFiles, isTrue);
        expect(DragOperationType.copy.shouldClearFiles, isFalse);
        expect(DragOperationType.unknown.shouldClearFiles, isFalse);
      });

      test('logMessage getter', () {
        expect(DragOperationType.copy.logMessage, contains('Copy detected'));
        expect(DragOperationType.move.logMessage, contains('Move detected'));
        expect(
          DragOperationType.unknown.logMessage,
          contains('Unknown operation'),
        );
      });
    });

    group('DragCoordinatorConfig', () {
      test('constants', () {
        expect(DragCoordinatorConfig.dragEndDelay, isA<Duration>());
        expect(DragCoordinatorConfig.logTag, equals('DragCoordinator'));
      });
    });
  });
}
