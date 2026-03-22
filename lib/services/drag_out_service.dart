import 'package:flutter/services.dart';
import 'constants.dart';
import 'package:easier_drop/core/utils/result_handler.dart';

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
    await safeCall(() => _channel.invokeMethod(PlatformChannels.beginDrag, {'items': paths}));

    Future.delayed(const Duration(milliseconds: 100), () {
      _dragInProgress = false;
    });
  }

  void setHandler(Future<dynamic> Function(MethodCall call)? handler) {
    _channel.setMethodCallHandler(handler);
  }
}
