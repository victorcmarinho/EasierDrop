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
  bool _draggingOut = false;

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
        // Auto limpar desativado permanentemente: não limpa após drag-in.
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
    setState(() => _draggingOut = true);
    await DragOutService.instance.beginDrag(files);
    // Pequeno atraso para permitir overlay durante arraste
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _draggingOut = false);
    });
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
      provider.clear();
    }
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
                if (_draggingOut)
                  IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: 0.9,
                      duration: const Duration(milliseconds: 120),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
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
                        Tooltip(
                          message: 'Compartilhar (Cmd+Shift+C)',
                          child: Semantics(
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
                    child: Tooltip(
                      message: 'Limpar (Cmd+Backspace)',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
