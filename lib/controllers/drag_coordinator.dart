import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:easier_drop/services/file_drop_service.dart';
import 'package:easier_drop/services/drag_out_service.dart';
import 'package:easier_drop/services/drag_result.dart';
import 'package:easier_drop/services/constants.dart';
import 'package:easier_drop/services/logger.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';

/// Coordena interações de drag-in e drag-out, isolando lógica de plataforma
/// do widget principal. Expõe callbacks simples e notifica via [ValueNotifier].
// Ignorar na cobertura - coordena interações com código nativo
@pragma('vm:exclude-from-coverage')
class DragCoordinator {
  DragCoordinator(this.context);

  final BuildContext context;

  final ValueNotifier<bool> draggingOut = ValueNotifier(false);
  final ValueNotifier<bool> hovering = ValueNotifier(false);

  StreamSubscription? _dropSub;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _setupInbound();
    _setupOutbound();
    await FileDropService.instance.start();
    _dropSub = FileDropService.instance.filesStream.listen(_onPaths);
  }

  void dispose() {
    FileDropService.instance.setMethodCallHandler(null);
    DragOutService.instance.setHandler(null);
    _dropSub?.cancel();
    FileDropService.instance.stop();
    draggingOut.dispose();
    hovering.dispose();
  }

  // --- Inbound (drag-in) ---
  void _setupInbound() {
    FileDropService.instance.setMethodCallHandler((call) async {
      if (call.method == PlatformChannels.fileDroppedCallback) {
        final op = call.arguments as String?;
        AppLogger.info(
          // coverage:ignore-line
          'Drag finished (inbound). Operation: ${op ?? 'unknown'}',
          tag: 'DragCoordinator',
        );
      }
      return null;
    });
  }

  // --- Outbound (drag-out) ---
  void _setupOutbound() {
    DragOutService.instance.setHandler((call) async {
      if (call.method == PlatformChannels.fileDroppedCallback) {
        _handleOutboundResult(call.arguments);
      }
      return null;
    });
  }

  void _handleOutboundResult(dynamic raw) {
    final result = ChannelDragResult.parse(raw);
    if (!result.isSuccess) {
      AppLogger.warn(
        'Drag finished with error',
        tag: 'DragCoordinator',
      ); // coverage:ignore-line
      return;
    }
    switch (result.operation) {
      case DragOperation.copy:
        AppLogger.info(
          // coverage:ignore-line
          'Copy detected; retaining files',
          tag: 'DragCoordinator',
        );
        break;
      case DragOperation.move:
        final provider = context.read<FilesProvider>();
        if (provider.files.isNotEmpty) provider.clear();
        break;
      case DragOperation.unknown:
        AppLogger.info(
          'Unknown op; retaining files',
          tag: 'DragCoordinator',
        ); // coverage:ignore-line
        break;
    }
  }

  /// Exposto apenas para testes unitários a fim de validar lógica de limpeza
  /// baseada na operação de drag-out recebida do canal nativo.
  @visibleForTesting
  void handleOutboundTest(dynamic raw) => _handleOutboundResult(raw);

  Future<void> beginExternalDrag() async {
    final filesProvider = context.read<FilesProvider>();
    final files = filesProvider.files.map((f) => f.pathname).toList();
    if (files.isEmpty) {
      AppLogger.warn(
        'No files to drag',
        tag: 'DragCoordinator',
      ); // coverage:ignore-line
      return;
    }
    draggingOut.value = true;
    await DragOutService.instance.beginDrag(files);
    Future.delayed(const Duration(milliseconds: 400), () {
      draggingOut.value = false;
    });
    AppLogger.info(
      'External drag started',
      tag: 'DragCoordinator',
    ); // coverage:ignore-line
  }

  void setHover(bool value) => hovering.value = value;

  Future<void> _onPaths(List<String> paths) async {
    final provider = context.read<FilesProvider>();
    for (final path in paths) {
      final ref = FileReference(pathname: path);
      unawaited(provider.addFile(ref));
    }
  }
}
