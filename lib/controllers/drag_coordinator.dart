import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:easier_drop/services/file_drop_service.dart';
import 'package:easier_drop/services/drag_out_service.dart';
import 'package:easier_drop/services/drag_result.dart';
import 'package:easier_drop/services/constants.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'drag_coordinator_types.dart';

/// Coordenador responsável por gerenciar operações de drag & drop
///
/// Funcionalidades:
/// - Coordena drag in (receber arquivos)
/// - Coordena drag out (arrastar arquivos para fora)
/// - Gerencia estados visuais de hover e dragging
/// - Processa resultados de operações de drag
class DragCoordinator {
  DragCoordinator(this.context);

  final BuildContext context;
  final ValueNotifier<bool> draggingOut = ValueNotifier(false);
  final ValueNotifier<bool> hovering = ValueNotifier(false);

  StreamSubscription? _dropSubscription;
  bool _initialized = false;

  /// Inicializa o coordenador
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _setupInboundDrag();
    _setupOutboundDrag();

    await FileDropService.instance.start();
    _dropSubscription = FileDropService.instance.filesStream.listen(
      _onFilesDropped,
    );
  }

  /// Limpa recursos e encerra serviços
  void dispose() {
    FileDropService.instance.setMethodCallHandler(null);
    DragOutService.instance.setHandler(null);
    _dropSubscription?.cancel();
    FileDropService.instance.stop();
    draggingOut.dispose();
    hovering.dispose();
  }

  /// Configura o tratamento de arquivos sendo arrastados para dentro
  void _setupInboundDrag() {
    FileDropService.instance.setMethodCallHandler((call) async {
      if (call.method == PlatformChannels.fileDroppedCallback) {
        final operation = call.arguments as String?;
        AnalyticsService.instance.info(
          'Drag finished (inbound). Operation: ${operation ?? 'unknown'}',
          tag: DragCoordinatorConfig.logTag,
        );
      }
      return null;
    });
  }

  /// Configura o tratamento de arquivos sendo arrastados para fora
  void _setupOutboundDrag() {
    DragOutService.instance.setHandler((call) async {
      if (call.method == PlatformChannels.fileDroppedCallback) {
        _handleOutboundResult(call.arguments);
      }
      return null;
    });
  }

  /// Processa o resultado de uma operação de drag para fora
  void _handleOutboundResult(dynamic raw) {
    final result = ChannelDragResult.parse(raw);

    if (!result.isSuccess) {
      AnalyticsService.instance.warn(
        'Drag finished with error',
        tag: DragCoordinatorConfig.logTag,
      );
      return;
    }

    final operationType = _mapDragOperation(result.operation);

    AnalyticsService.instance.info(
      operationType.logMessage,
      tag: DragCoordinatorConfig.logTag,
    );

    if (operationType.shouldClearFiles) {
      final provider = context.read<FilesProvider>();
      if (provider.hasFiles) {
        provider.clear();
      }
    }
  }

  /// Mapeia DragOperation para DragOperationType
  DragOperationType _mapDragOperation(DragOperation operation) {
    switch (operation) {
      case DragOperation.copy:
        return DragOperationType.copy;
      case DragOperation.move:
        return DragOperationType.move;
      case DragOperation.unknown:
        return DragOperationType.unknown;
    }
  }

  /// Inicia uma operação de drag para fora
  Future<void> beginExternalDrag() async {
    final filesProvider = context.read<FilesProvider>();
    final filePaths = filesProvider.files.map((f) => f.pathname).toList();

    if (filePaths.isEmpty) {
      AnalyticsService.instance.warn(
        'No files to drag',
        tag: DragCoordinatorConfig.logTag,
      );
      return;
    }

    draggingOut.value = true;

    try {
      await DragOutService.instance.beginDrag(filePaths);
      AnalyticsService.instance.info(
        'External drag started',
        tag: DragCoordinatorConfig.logTag,
      );
    } finally {
      // Reset do estado após delay
      Future.delayed(DragCoordinatorConfig.dragEndDelay, () {
        draggingOut.value = false;
      });
    }
  }

  /// Define o estado de hover
  void setHover(bool value) => hovering.value = value;

  /// Processa arquivos que foram dropados
  Future<void> _onFilesDropped(List<String> paths) async {
    final provider = context.read<FilesProvider>();
    final fileRefs = paths.map((path) => FileReference(pathname: path));
    await provider.addFiles(fileRefs);
  }

  @visibleForTesting
  void handleOutboundTest(dynamic raw) => _handleOutboundResult(raw);
}
