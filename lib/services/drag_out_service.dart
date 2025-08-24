import 'package:flutter/services.dart';
import 'constants.dart';

/// Serviço isolado para iniciar drag-out (arrastar arquivos para fora do app).
class DragOutService {
  DragOutService._();
  static final DragOutService instance = DragOutService._();

  final MethodChannel _channel = const MethodChannel(
    PlatformChannels.fileDragOut,
  );

  bool _dragInProgress = false;

  Future<void> beginDrag(List<String> paths) async {
    if (paths.isEmpty) return;
    if (_dragInProgress) return; // evita reentrância
    _dragInProgress = true;
    try {
      await _channel.invokeMethod(PlatformChannels.beginDrag, {'items': paths});
    } finally {
      // Segurança: libera após um atraso pequeno para não iniciar novo drag imediatamente
      Future.delayed(const Duration(milliseconds: 100), () {
        _dragInProgress = false;
      });
    }
  }

  void setHandler(Future<dynamic> Function(MethodCall call)? handler) {
    _channel.setMethodCallHandler(handler);
  }
}
