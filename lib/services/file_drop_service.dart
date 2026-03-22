import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'constants.dart';
import 'analytics_service.dart';
import 'package:easier_drop/core/utils/result_handler.dart';

class FileDropService {
  FileDropService._();
  static final FileDropService instance = FileDropService._();

  final MethodChannel _channel = const MethodChannel(PlatformChannels.fileDrop);
  StreamSubscription? _sub;
  final StreamController<List<String>> _filesController =
      StreamController.broadcast();

  @visibleForTesting
  void resetForTesting() {
    _monitoring = false;
    _sub?.cancel();
    _sub = null;
  }

  Stream<List<String>> get filesStream => _filesController.stream;

  bool _monitoring = false;
  bool get isMonitoring => _monitoring;

  Future<void> start() async {
    if (_monitoring) return;
    
    final (_, error) = await safeCall(() async {
      await _channel.invokeMethod(PlatformChannels.startMonitor); // coverage:ignore-line
      final eventChannel = const EventChannel(PlatformChannels.fileDropEvents);
      _sub = eventChannel.receiveBroadcastStream().listen((event) { // coverage:ignore-line
        if (event is List) {
          _filesController.add(List<String>.from(event));
        }
      });
    });

    if (error != null) {
      AnalyticsService.instance.error(
        'Falha ao iniciar monitoramento de arquivos: $error',
        tag: 'FileDropService',
      );
      return;
    }

    _monitoring = true;
  }

  Future<void> stop() async {
    if (!_monitoring) return;
    
    final (_, error) = await safeCall(() async {
      await _channel.invokeMethod(PlatformChannels.stopMonitor); // coverage:ignore-line
      await _sub?.cancel();
    });

    if (error != null) {
       AnalyticsService.instance.error(
        'Falha ao parar monitoramento de arquivos: $error',
        tag: 'FileDropService',
      );
    }

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

  @visibleForTesting
  void pushTestEvent(List<String> paths) {
    if (!_filesController.isClosed) {
      _filesController.add(paths);
    }
  }
}
