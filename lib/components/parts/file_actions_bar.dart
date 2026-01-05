import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:easier_drop/components/share_button.dart';
import 'package:easier_drop/components/remove_button.dart';
import 'package:easier_drop/helpers/app_constants.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

class FileActionsBar extends StatelessWidget {
  const FileActionsBar({
    super.key,
    required this.hasFiles,
    required this.filesProvider,
    required this.buttonKey,
    required this.getButtonPosition,
    required this.loc,
    required this.onClear,
  });

  final bool hasFiles;
  final FilesProvider filesProvider;
  final GlobalKey buttonKey;
  final Offset? Function() getButtonPosition;
  final AppLocalizations loc;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [_buildShareButton(), _buildRemoveButton()]);
  }

  Widget _buildShareButton() {
    return Positioned(
      top: 4,
      right: 4,
      child: Semantics(
        key: SemanticKeys.shareButton,
        label: loc.share,
        hint: hasFiles
            ? loc.semShareHintSome(filesProvider.fileCount)
            : loc.semShareHintNone,
        button: true,
        enabled: hasFiles,
        child: AnimatedOpacity(
          duration: AppConstants.mediumAnimation,
          opacity: hasFiles ? 1 : 0,
          child: MacosTooltip(
            message: hasFiles ? loc.tooltipShare : '',
            child: hasFiles
                ? ShareButton(
                    key: buttonKey,
                    onPressed: () =>
                        filesProvider.shared(position: getButtonPosition()),
                  )
                : _buildPlaceholder(),
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveButton() {
    return Positioned(
      bottom: 4,
      right: 4,
      child: Semantics(
        key: SemanticKeys.removeButton,
        label: loc.removeAll,
        hint: hasFiles
            ? loc.semRemoveHintSome(filesProvider.fileCount)
            : loc.semRemoveHintNone,
        button: true,
        enabled: hasFiles,
        child: AnimatedOpacity(
          duration: AppConstants.mediumAnimation,
          opacity: hasFiles ? 1 : 0,
          child: MacosTooltip(
            message: hasFiles ? loc.tooltipClear : '',
            child: hasFiles
                ? RemoveButton(onPressed: onClear)
                : _buildPlaceholder(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const SizedBox(
      width: AppConstants.actionButtonSize,
      height: AppConstants.actionButtonSize,
    );
  }
}
