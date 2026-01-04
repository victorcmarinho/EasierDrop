/// Estados e configurações para operações de drag & drop
enum DragState { idle, hovering, draggingOut }

/// Tipos de operação de drag
enum DragOperationType {
  copy,
  move,
  unknown;

  /// Determina se os arquivos devem ser removidos após o drag
  bool get shouldClearFiles => this == DragOperationType.move;

  /// Mensagem de log para a operação
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

/// Configurações para o DragCoordinator
abstract class DragCoordinatorConfig {
  static const Duration dragEndDelay = Duration(milliseconds: 400);
  static const String logTag = 'DragCoordinator';
}
