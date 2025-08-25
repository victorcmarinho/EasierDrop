import 'package:easier_drop/services/logger.dart';

/// Supported drag operations returned by native layer.
/// Falls back to [DragOperation.unknown] when parsing fails.
enum DragOperation { copy, move, unknown }

extension DragOperationX on DragOperation {
  static DragOperation parse(String? raw) {
    switch (raw) {
      case 'copy':
        return DragOperation.copy;
      case 'move':
        return DragOperation.move;
      default:
        return DragOperation.unknown;
    }
  }

  String get name => switch (this) {
    DragOperation.copy => 'copy',
    DragOperation.move => 'move',
    DragOperation.unknown => 'unknown',
  };
}

/// Structured result coming from a drag completion callback (inbound/outbound).
sealed class ChannelDragResult {
  const ChannelDragResult();

  bool get isSuccess => this is ChannelDragSuccess;
  DragOperation get operation =>
      this is ChannelDragSuccess
          ? (this as ChannelDragSuccess).operation
          : DragOperation.unknown;

  static ChannelDragResult parse(dynamic raw) {
    try {
      if (raw is Map) {
        final status = raw['status'] as String?;
        if (status == 'ok') {
          return ChannelDragSuccess(DragOperationX.parse(raw['op'] as String?));
        }
        return ChannelDragError(
          code: raw['code']?.toString() ?? 'unknown_error',
          message: raw['message']?.toString() ?? 'Unknown drag error',
        );
      }
      // Legacy: platform sent just the operation string (copy|move)
      if (raw is String) {
        return ChannelDragSuccess(DragOperationX.parse(raw));
      }
      return const ChannelDragSuccess(DragOperation.unknown);
    } catch (e, st) {
      AppLogger.warn(
        'Failed to parse drag result: $e',
        tag: 'DragResult',
      ); // coverage:ignore-line
      AppLogger.debug(st.toString(), tag: 'DragResult'); // coverage:ignore-line
      return const ChannelDragSuccess(DragOperation.unknown);
    }
  }
}

class ChannelDragSuccess extends ChannelDragResult {
  const ChannelDragSuccess(this.operation);
  @override
  final DragOperation operation;
}

class ChannelDragError extends ChannelDragResult {
  const ChannelDragError({required this.code, required this.message});
  final String code;
  final String message;
}
