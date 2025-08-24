import 'package:flutter/services.dart';
import 'constants.dart';

/// Serviço isolado para iniciar drag-out (arrastar arquivos para fora do app).
class DragOutService {
  DragOutService._();
  static final DragOutService instance = DragOutService._();

  final MethodChannel _channel = const MethodChannel(
    PlatformChannels.fileDragOut,
  );

  Future<void> beginDrag(List<String> paths) async {
    if (paths.isEmpty) return;
    await _channel.invokeMethod(PlatformChannels.beginDrag, {'items': paths});
  }

  void setHandler(Future<dynamic> Function(MethodCall call)? handler) {
    _channel.setMethodCallHandler(handler);
  }
}
