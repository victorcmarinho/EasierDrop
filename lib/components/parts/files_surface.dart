import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/components/drop_hit.dart';
import 'package:easier_drop/components/files_stack.dart';
import 'package:easier_drop/components/remove_button.dart';
import 'package:easier_drop/components/share_button.dart';
import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import '../mac_close_button.dart';
import 'file_name_badge.dart';

class FilesSurface extends StatelessWidget {
  const FilesSurface({
    super.key,
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
                              child: FileNameBadge(label: fileNameLabel),
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
              top: 4,
              left: 4,
              child: MacCloseButton(onPressed: () => SystemHelper.hide()),
            ),
            Positioned(
              top: 4,
              right: 4,
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
              bottom: 4,
              right: 4,
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
