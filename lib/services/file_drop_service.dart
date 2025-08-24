import 'dart:async';
import 'package:flutter/services.dart';
import 'constants.dart';

/// Serviço singleton responsável por monitorar eventos de drop de arquivos
/// vindos do canal nativo macOS.
class FileDropService {
  FileDropService._();
  static final FileDropService instance = FileDropService._();

  final MethodChannel _channel = const MethodChannel(PlatformChannels.fileDrop);
  StreamSubscription? _sub;
  final StreamController<List<String>> _filesController =
      StreamController.broadcast();

  Stream<List<String>> get filesStream => _filesController.stream;

  bool _monitoring = false;
  bool get isMonitoring => _monitoring;

  Future<void> start() async {
    if (_monitoring) return;
    await _channel.invokeMethod(PlatformChannels.startMonitor);
    final eventChannel = const EventChannel(PlatformChannels.fileDropEvents);
    _sub = eventChannel.receiveBroadcastStream().listen((event) {
      if (event is List) {
        _filesController.add(List<String>.from(event));
      }
    });
    _monitoring = true;
  }

  Future<void> stop() async {
    if (!_monitoring) return;
    await _channel.invokeMethod(PlatformChannels.stopMonitor);
    await _sub?.cancel();
    _sub = null;
    _monitoring = false;
  }

  Future<void> dispose() async {
    await stop();
    await _filesController.close();
  }

  void setMethodCallHandler(
    Future<dynamic> Function(MethodCall call)? handler,
  ) {
    _channel.setMethodCallHandler(handler);
  }
}
