enum DragState { idle, hovering, draggingOut }

enum DragOperationType {
  copy,
  move,
  unknown;

  bool get shouldClearFiles => this == DragOperationType.move;

  String get logMessage {
    switch (this) {
      case DragOperationType.copy:
        return 'Copy detected; retaining files';
      case DragOperationType.move:
        return 'Move detected; clearing files';
      case DragOperationType.unknown:
        return 'Unknown operation; retaining files';
    }
  }
}

abstract class DragCoordinatorConfig {
  static const Duration dragEndDelay = Duration(milliseconds: 400);
  static const String logTag = 'DragCoordinator';
}
