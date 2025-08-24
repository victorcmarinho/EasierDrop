import 'dart:async';
import 'package:easier_drop/components/drop_hit.dart';
import 'package:easier_drop/components/files_stack.dart';
import 'package:easier_drop/components/remove_button.dart';
import 'package:easier_drop/components/share_button.dart';
import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/services/file_drop_service.dart';
import 'package:easier_drop/services/drag_out_service.dart';
import 'package:easier_drop/services/constants.dart';
import 'package:easier_drop/services/logger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DragDrop extends StatefulWidget {
  const DragDrop({super.key});

  @override
  State<DragDrop> createState() => _DragDropState();
}

class _DragDropState extends State<DragDrop> {
  final GlobalKey _buttonKey = GlobalKey();

  StreamSubscription? _dropSubscription;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _setupMethodCallHandler();
    _startDragMonitor();
  }

  @override
  void dispose() {
    FileDropService.instance.setMethodCallHandler(null);
    DragOutService.instance.setHandler(null);
    _dropSubscription?.cancel();
    FileDropService.instance.stop();
    super.dispose();
  }

  Future<void> _startDragMonitor() async {
    await FileDropService.instance.start();
    _dropSubscription = FileDropService.instance.filesStream.listen((
      paths,
    ) async {
      for (final path in paths) {
        final fileRef = FileReference(pathname: path);
        if (mounted) {
          unawaited(context.read<FilesProvider>().addFile(fileRef));
        }
      }
    });
  }

  void _setupMethodCallHandler() {
    FileDropService.instance.setMethodCallHandler((call) async {
      if (call.method == PlatformChannels.fileDroppedCallback) {
        final op = call.arguments as String?;
        AppLogger.info(
          'Drag finalizado (inbound). Operação: ${op ?? 'desconhecida'}',
          tag: 'DragDrop',
        );
        context.read<FilesProvider>().clear();
      }
      return null;
    });

    // Handler para callbacks do drag-out
    DragOutService.instance.setHandler((call) async {
      if (call.method == PlatformChannels.fileDroppedCallback) {
        final op = call.arguments as String?; // copy | move
        AppLogger.info(
          'Drag finalizado (outbound). Operação: ${op ?? 'desconhecida'}',
          tag: 'DragDrop',
        );
        // Limpa a lista após arrastar para fora
        context.read<FilesProvider>().clear();
      }
      return null;
    });
  }

  Offset? _getButtonPosition() {
    final RenderBox? renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero);
  }

  Widget _buildAnimatedButton({required bool visible, required Widget child}) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: visible ? 1.0 : 0.0,
      child: visible ? child : const SizedBox(width: 40, height: 40),
    );
  }

  Future<void> _handleDragOut() async {
    AppLogger.debug('Iniciando drag out', tag: 'DragDrop');
    final filesProvider = context.read<FilesProvider>();
    final files = filesProvider.files.map((f) => f.pathname).toList();

    if (files.isEmpty) {
      AppLogger.warn('Nenhum arquivo para arrastar', tag: 'DragDrop');
      return;
    }
    await DragOutService.instance.beginDrag(files);
    AppLogger.info('Drag externo iniciado', tag: 'DragDrop');
  }

  @override
  Widget build(BuildContext context) {
    final filesProvider = context.watch<FilesProvider>();
    final hasFiles = filesProvider.files.isNotEmpty;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onPanStart: (_) => _handleDragOut(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color:
                  _hovering
                      ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.6)
                      : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              hasFiles
                  ? FilesStack(droppedFiles: filesProvider.files)
                  : const DropHit(),

              Positioned(
                left: 0,
                top: 0,
                child: CloseButton(onPressed: () => SystemHelper.hide()),
              ),

              Positioned(
                right: 0,
                top: 0,
                child: _buildAnimatedButton(
                  visible: hasFiles,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ShareButton(
                        key: _buttonKey,
                        onPressed:
                            () => filesProvider.shared(
                              position: _getButtonPosition(),
                            ),
                      ),
                      if (hasFiles)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Center(
                              child: Text(
                                filesProvider.files.length.toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              Positioned(
                right: 0,
                bottom: 0,
                child: _buildAnimatedButton(
                  visible: hasFiles,
                  child: RemoveButton(onPressed: filesProvider.clear),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
