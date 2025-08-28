import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:easier_drop/components/share_button.dart';
import 'package:easier_drop/components/remove_button.dart';
import 'package:easier_drop/components/mac_close_button.dart';
import 'package:easier_drop/helpers/system.dart';
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
    return Stack(
      children: [
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
                        key: const ValueKey('shareSem'),
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
                        key: const ValueKey('removeSem'),
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
    );
  }
}
