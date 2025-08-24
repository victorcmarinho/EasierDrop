import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
// window_manager não necessário aqui (usado no WindowHandle)
import 'window_handle.dart';
import 'package:easier_drop/components/drop_hit.dart';
import 'package:easier_drop/components/files_stack.dart';
import 'package:easier_drop/components/remove_button.dart';
import 'package:easier_drop/components/share_button.dart';
import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/services/file_drop_service.dart';
import 'package:easier_drop/services/drag_out_service.dart';
import 'package:easier_drop/services/drag_result.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/constants.dart';
import 'package:easier_drop/services/logger.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'hover_icon_button.dart';

class DragDrop extends StatefulWidget {
  const DragDrop({super.key});

  @override
  State<DragDrop> createState() => _DragDropState();
}

class _DragDropState extends State<DragDrop> {
  final GlobalKey _buttonKey = GlobalKey();
  static const double _handleGestureHeight =
      28.0; // manter para lógica de bloqueio drag-out

  StreamSubscription? _dropSubscription;
  bool _hovering = false;
  bool _draggingOut = false;

  void _onOperationFinished(dynamic raw) {
    final result = ChannelDragResult.parse(raw);
    if (!result.isSuccess) {
      AppLogger.warn('Drag finished with error', tag: 'DragDrop');
      return;
    }
    switch (result.operation) {
      case DragOperation.copy:
        AppLogger.info('Copy detected; retaining files', tag: 'DragDrop');
        break;
      case DragOperation.move:
        final provider = context.read<FilesProvider>();
        if (provider.files.isNotEmpty) provider.clear();
        break;
      case DragOperation.unknown:
        AppLogger.info('Unknown operation; retaining files', tag: 'DragDrop');
        break;
    }
  }

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
          'Drag finished (inbound). Operation: ${op ?? 'unknown'}',
          tag: 'DragDrop',
        );
      }
      return null;
    });

    DragOutService.instance.setHandler((call) async {
      if (call.method == PlatformChannels.fileDroppedCallback) {
        _onOperationFinished(call.arguments);
      }
      return null;
    });
  }

  Offset? _getButtonPosition() {
    final RenderBox? renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero);
  }

  Future<void> _handleDragOut() async {
    AppLogger.debug('Starting drag out', tag: 'DragDrop');
    final filesProvider = context.read<FilesProvider>();
    final files = filesProvider.files.map((f) => f.pathname).toList();

    if (files.isEmpty) {
      AppLogger.warn('No files to drag', tag: 'DragDrop');
      return;
    }
    setState(() => _draggingOut = true);
    await DragOutService.instance.beginDrag(files);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _draggingOut = false);
    });
    AppLogger.info('External drag started', tag: 'DragDrop');
  }

  Future<void> _confirmAndClear(FilesProvider provider) async {
    if (provider.files.isEmpty) return;
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showMacosAlertDialog<bool>(
      context: context,
      builder:
          (_) => MacosAlertDialog(
            appIcon: const MacosIcon(CupertinoIcons.trash),
            title: Text(loc.clearFilesTitle),
            message: Text(loc.clearFilesMessage),
            primaryButton: PushButton(
              controlSize: ControlSize.large,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(loc.clearConfirm),
            ),
            secondaryButton: PushButton(
              secondary: true,
              controlSize: ControlSize.large,
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(loc.clearCancel),
            ),
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
    final limitHitAt = context.select<FilesProvider, DateTime?>(
      (p) => p.lastLimitHit,
    );
    final showLimit =
        limitHitAt != null &&
        DateTime.now().difference(limitHitAt) < const Duration(seconds: 2);
    final loc = AppLocalizations.of(context)!;

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Stack(
        children: [
          _FilesSurface(
            hovering: _hovering,
            draggingOut: _draggingOut,
            showLimit: showLimit,
            hasFiles: hasFiles,
            buttonKey: _buttonKey,
            loc: loc,
            onHoverChanged: (h) => setState(() => _hovering = h),
            onDragCheck: (dy) => dy > _handleGestureHeight,
            onDragRequest: _handleDragOut,
            onClear: () => _confirmAndClear(filesProvider),
            getButtonPosition: _getButtonPosition,
            filesProvider: filesProvider,
          ),
          const WindowHandle(),
        ],
      ),
    );
  }
}

class _FilesSurface extends StatelessWidget {
  const _FilesSurface({
    required this.hovering,
    required this.draggingOut,
    required this.showLimit,
    required this.hasFiles,
    required this.buttonKey,
    required this.loc,
    required this.onHoverChanged,
    required this.onDragCheck,
    required this.onDragRequest,
    required this.onClear,
    required this.getButtonPosition,
    required this.filesProvider,
  });

  final bool hovering;
  final bool draggingOut;
  final bool showLimit;
  final bool hasFiles;
  final GlobalKey buttonKey;
  final AppLocalizations loc;
  final ValueChanged<bool> onHoverChanged;
  final bool Function(double dy) onDragCheck;
  final VoidCallback onDragRequest;
  final VoidCallback onClear;
  final Offset? Function() getButtonPosition;
  final FilesProvider filesProvider;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: GestureDetector(
        onPanStart: (details) {
          if (!onDragCheck(details.localPosition.dy)) return;
          onDragRequest();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              decoration: BoxDecoration(
                color: MacosTheme.of(
                  context,
                ).canvasColor.withValues(alpha: 0.03),
                border: Border.all(
                  color:
                      hovering
                          ? MacosTheme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.7)
                          : MacosColors.transparent,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Selector<FilesProvider, List<FileReference>>(
                selector: (_, p) => p.files,
                builder: (context, files, _) {
                  final hint =
                      files.isEmpty
                          ? loc.semAreaHintEmpty
                          : loc.semAreaHintHas(files.length);
                  final fileNameLabel = () {
                    if (files.isEmpty) return '';
                    if (files.length == 1) {
                      final name = files.first.fileName;
                      return loc.fileLabelSingle(name);
                    }
                    return loc.fileLabelMultiple(files.length);
                  }();
                  return Semantics(
                    label: loc.semAreaLabel,
                    hint: hint,
                    liveRegion: true,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child:
                                files.isNotEmpty
                                    ? FilesStack(droppedFiles: files)
                                    : const DropHit(),
                          ),
                          if (fileNameLabel.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                fileNameLabel,
                                style:
                                    MacosTheme.of(context).typography.caption1,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (draggingOut)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: 0.9,
                    duration: const Duration(milliseconds: 120),
                    child: Container(
                      decoration: BoxDecoration(
                        color: MacosTheme.of(
                          context,
                        ).canvasColor.withValues(alpha: 0.85),
                        border: Border.all(
                          color: MacosTheme.of(context).primaryColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            if (showLimit)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: showLimit ? 1 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      decoration: BoxDecoration(
                        color: MacosTheme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        loc.limitReached(SettingsService.instance.maxFiles),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: MacosColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 8,
              left: 8,
              child: MacosTooltip(
                message: AppLocalizations.of(context)!.close,
                child: HoverIconButton(
                  icon: const MacosIcon(CupertinoIcons.clear_thick),
                  onPressed: () => SystemHelper.hide(),
                  semanticsLabel: AppLocalizations.of(context)!.close,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: hasFiles ? 1 : 0,
                child:
                    hasFiles
                        ? MacosTooltip(
                          message: loc.tooltipShare,
                          child: Semantics(
                            label: loc.share,
                            hint:
                                hasFiles
                                    ? loc.semShareHintSome(
                                      filesProvider.files.length,
                                    )
                                    : loc.semShareHintNone,
                            button: true,
                            child: ShareButton(
                              key: buttonKey,
                              onPressed:
                                  () => filesProvider.shared(
                                    position: getButtonPosition(),
                                  ),
                            ),
                          ),
                        )
                        : const SizedBox(width: 40, height: 40),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: hasFiles ? 1 : 0,
                child:
                    hasFiles
                        ? MacosTooltip(
                          message: loc.tooltipClear,
                          child: Semantics(
                            label: loc.removeAll,
                            hint:
                                hasFiles
                                    ? loc.semRemoveHintSome(
                                      filesProvider.files.length,
                                    )
                                    : loc.semRemoveHintNone,
                            button: true,
                            child: RemoveButton(onPressed: onClear),
                          ),
                        )
                        : const SizedBox(width: 40, height: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
