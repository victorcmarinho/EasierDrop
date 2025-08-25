import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/components/drop_hit.dart';
import 'package:easier_drop/components/files_stack.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'file_name_badge.dart';
import 'dragging_overlay.dart';
import 'limit_overlay.dart';
import 'file_actions_bar.dart';

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
            DraggingOverlay(visible: draggingOut),
            LimitOverlay(visible: showLimit, loc: loc),
            FileActionsBar(
              hasFiles: hasFiles,
              filesProvider: filesProvider,
              buttonKey: buttonKey,
              getButtonPosition: getButtonPosition,
              loc: loc,
              onClear: onClear,
            ),
          ],
        ),
      ),
    );
  }
}
