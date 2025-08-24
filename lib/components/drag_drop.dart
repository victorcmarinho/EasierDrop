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
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/constants.dart';
import 'package:easier_drop/services/logger.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:flutter/cupertino.dart';
import 'hover_icon_button.dart';
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
          'Drag finished (inbound). Operation: ${op ?? 'unknown'}',
          tag: 'DragDrop',
        );
      }
      return null;
    });

    DragOutService.instance.setHandler((call) async {
      if (call.method == PlatformChannels.fileDroppedCallback) {
        final op = call.arguments as String?; // copy | move
        AppLogger.info(
          'Drag finished (outbound). Operation: ${op ?? 'unknown'}',
          tag: 'DragDrop',
        );
        if (op == 'copy') {
          AppLogger.info(
            'Copy operation detected. Files kept in tray.',
            tag: 'DragDrop',
          );
          return null;
        }
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

  Widget _buildAnimatedButton({required bool visible, required Widget child}) =>
      AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: visible ? 1.0 : 0.0,
        child: visible ? child : const SizedBox(width: 40, height: 40),
      );

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
              controlSize: ControlSize.regular,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(loc.clearConfirm),
            ),
            secondaryButton: PushButton(
              secondary: true,
              controlSize: ControlSize.regular,
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
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onPanStart: (_) => _handleDragOut(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: MacosTheme.of(context).canvasColor.withValues(alpha: 0.05),
              border: Border.all(
                color:
                    _hovering
                        ? MacosTheme.of(context).primaryColor.withValues(alpha: 0.6)
                        : MacosTheme.of(context).primaryColor.withValues(alpha: 0.0),
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
                          color: MacosTheme.of(
                            context,
                          ).canvasColor.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: MacosTheme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
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
                Selector<FilesProvider, List<FileReference>>(
                  selector: (_, p) => p.files,
                  builder: (context, files, _) {
                    final hint =
                        files.isEmpty
                            ? loc.semAreaHintEmpty
                            : loc.semAreaHintHas(files.length);
                    return Semantics(
                      label: loc.semAreaLabel,
                      hint: hint,
                      liveRegion: true,
                      child:
                          files.isNotEmpty
                              ? FilesStack(droppedFiles: files)
                              : const DropHit(),
                    );
                  },
                ),

                Positioned(
                  left: 0,
                  top: 0,
                  child: Semantics(
                    label: AppLocalizations.of(context)!.close,
                    button: true,
                    child: HoverIconButton(
                      icon: const MacosIcon(CupertinoIcons.clear_thick),
                      onPressed: () => SystemHelper.hide(),
                      addSemantics: false,
                    ),
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
                        MacosTooltip(
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
                                color: MacosTheme.of(context).primaryColor,
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
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: MacosColors.white,
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
                    child: MacosTooltip(
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
