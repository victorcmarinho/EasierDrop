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
import 'files_surface_helpers.dart';

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
          if (onDragCheck(details.localPosition.dy)) {
            onDragRequest();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildMainContainer(context),
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

  Widget _buildMainContainer(BuildContext context) {
    return AnimatedContainer(
      duration: FilesSurfaceStyles.animationDuration,
      decoration: _buildContainerDecoration(context),
      child: _buildFileContent(),
    );
  }

  BoxDecoration _buildContainerDecoration(BuildContext context) {
    final theme = MacosTheme.of(context);
    return BoxDecoration(
      color: theme.canvasColor.withValues(alpha: 0.03),
      border: Border.all(
        color: hovering
            ? theme.primaryColor.withValues(alpha: 0.7)
            : MacosColors.transparent,
        width: FilesSurfaceStyles.borderWidth,
      ),
      borderRadius: BorderRadius.circular(FilesSurfaceStyles.borderRadius),
    );
  }

  Widget _buildFileContent() {
    return Selector<FilesProvider, List<FileReference>>(
      selector: (_, provider) => provider.files,
      builder: (context, files, _) {
        final hint = FilesSemanticsHelper.generateHint(files, loc);
        final fileLabel = FilesSemanticsHelper.generateFileLabel(files, loc);

        return Semantics(
          label: loc.semAreaLabel,
          hint: hint,
          liveRegion: true,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilesDisplay(context, files),
                if (fileLabel.isNotEmpty) _buildFileLabel(fileLabel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilesDisplay(BuildContext context, List<FileReference> files) {
    return SizedBox(
      height:
          MediaQuery.of(context).size.height *
          FilesSurfaceStyles.contentHeightFactor,
      child: files.isNotEmpty
          ? FilesStack(droppedFiles: files)
          : const DropHit(),
    );
  }

  Widget _buildFileLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: FilesSurfaceStyles.badgeTopPadding),
      child: FileNameBadge(label: label),
    );
  }
}
