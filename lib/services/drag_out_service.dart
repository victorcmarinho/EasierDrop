import 'package:flutter/services.dart';
import 'constants.dart';

// Ignorar na cobertura - usa canal nativo para comunicação com Swift
@pragma('vm:exclude-from-coverage')
class DragOutService {
  DragOutService._();
  static final DragOutService instance = DragOutService._();

  final MethodChannel _channel = const MethodChannel(
    PlatformChannels.fileDragOut,
  );

  bool _dragInProgress = false;

  Future<void> beginDrag(List<String> paths) async {
    if (paths.isEmpty) return;
    if (_dragInProgress) return;
    _dragInProgress = true;
    try {
      await _channel.invokeMethod(PlatformChannels.beginDrag, {'items': paths});
    } finally {
      Future.delayed(const Duration(milliseconds: 100), () {
        _dragInProgress = false;
      });
    }
  }

  void setHandler(Future<dynamic> Function(MethodCall call)? handler) {
    _channel.setMethodCallHandler(handler);
  }
}
