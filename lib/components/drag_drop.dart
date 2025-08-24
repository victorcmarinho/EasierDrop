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
        if (FeatureFlags.autoClearInbound) {
          final provider = context.read<FilesProvider>();
          final removed = provider.files.length;
          provider.clear();
          if (mounted && removed > 0) {
            _showUndoSnackbar(removed);
          }
        }
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
        // Se a operação for cópia (segurando Cmd no início do drag), mantém arquivos
        if (op == 'copy') {
          AppLogger.info(
            'Operação de cópia detectada. Arquivos mantidos na bandeja.',
            tag: 'DragDrop',
          );
          return null;
        }
        // Caso contrário (move ou desconhecida) limpa a lista
        final provider = context.read<FilesProvider>();
        final removed = provider.files.length;
        if (removed > 0) {
          provider.clear();
          if (mounted) {
            _showUndoSnackbar(removed, dragOut: true);
          }
        }
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

  Future<void> _confirmAndClear(FilesProvider provider) async {
    if (provider.files.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Limpar arquivos?'),
            content: const Text(
              'Essa ação removerá todos os arquivos coletados.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Limpar'),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      final count = provider.files.length;
      provider.clear();
      if (mounted) _showUndoSnackbar(count);
    }
  }

  void _showUndoSnackbar(int removed, {bool dragOut = false}) {
    final provider = context.read<FilesProvider>();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            dragOut
                ? '$removed arquivo(s) movidos. Desfazer?'
                : '$removed arquivo(s) removidos. Desfazer?',
          ),
          action:
              provider.canUndo
                  ? SnackBarAction(
                    label: 'DESFAZER',
                    onPressed: () {
                      provider.undoClear();
                    },
                  )
                  : null,
          duration: const Duration(seconds: 5),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final filesProvider = context.read<FilesProvider>();
    final hasFiles = context.select<FilesProvider, bool>(
      (p) => p.files.isNotEmpty,
    );

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: MouseRegion(
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
              fit: StackFit.expand,
              children: [
                Selector<FilesProvider, List<FileReference>>(
                  selector: (_, p) => p.files,
                  builder:
                      (context, files, _) => Semantics(
                        label: 'Área de colecionar arquivos',
                        hint:
                            hasFiles
                                ? 'Contém ${files.length} arquivos. Arraste para fora para mover ou use compartilhar.'
                                : 'Vazio. Arraste arquivos aqui.',
                        liveRegion: true,
                        child:
                            files.isNotEmpty
                                ? FilesStack(droppedFiles: files)
                                : const DropHit(),
                      ),
                ),

                Positioned(
                  left: 0,
                  top: 0,
                  child: Semantics(
                    label: AppTexts.close,
                    button: true,
                    child: CloseButton(onPressed: () => SystemHelper.hide()),
                  ),
                ),

                Positioned(
                  right: 0,
                  top: 0,
                  child: _buildAnimatedButton(
                    visible: hasFiles,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Semantics(
                          label: AppTexts.share,
                          hint:
                              hasFiles
                                  ? 'Compartilhar ${filesProvider.files.length} arquivos'
                                  : 'Nenhum arquivo para compartilhar',
                          button: true,
                          child: ShareButton(
                            key: _buttonKey,
                            onPressed:
                                () => filesProvider.shared(
                                  position: _getButtonPosition(),
                                ),
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
                                  context
                                      .select<FilesProvider, int>(
                                        (p) => p.files.length,
                                      )
                                      .toString(),
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
                    child: Semantics(
                      label: AppTexts.removeAll,
                      hint:
                          hasFiles
                              ? 'Remover ${filesProvider.files.length} arquivos'
                              : 'Nenhum arquivo para remover',
                      button: true,
                      child: RemoveButton(
                        onPressed: () => _confirmAndClear(filesProvider),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
