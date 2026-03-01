import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/screens/settings/settings_view_model.dart';
import 'package:easier_drop/services/native_events_service.dart';

class ShakeGestureSection extends StatelessWidget {
  final SettingsViewModel viewModel;

  const ShakeGestureSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        final loc = AppLocalizations.of(context)!;

        return CupertinoListSection.insetGrouped(
          header: Text(
            loc.settingsShakeGesture.toUpperCase(),
            style: MacosTheme.of(context).typography.title3,
          ),
          backgroundColor: Colors.transparent,
          footer: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (viewModel.hasShakePermission)
                Text(loc.settingsShakePermissionDescription)
              else ...[
                Text(loc.settingsShakePermissionInstruction),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: MacosTheme.of(context).typography.footnote.copyWith(
                      color:
                          MacosTheme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFCCCCCC)
                          : const Color(0xFF666666),
                    ),
                    children: _buildRestartHintSpans(context, loc),
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
          children: [
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.shuffle),
              title: Text(loc.settingsShakeGesture),
              additionalInfo: viewModel.checkingShake
                  ? const CupertinoActivityIndicator()
                  : Text(
                      viewModel.hasShakePermission
                          ? loc.settingsShakePermissionActive
                          : loc.settingsShakePermissionInactive,
                      style: TextStyle(
                        color: viewModel.hasShakePermission
                            ? CupertinoColors.activeGreen
                            : CupertinoColors.destructiveRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              onTap: !viewModel.hasShakePermission
                  ? () =>
                        NativeEventsService.instance.openAccessibilitySettings()
                  : null,
            ),
          ],
        );
      },
    );
  }

  List<InlineSpan> _buildRestartHintSpans(
    BuildContext context,
    AppLocalizations loc,
  ) {
    final String linkText = loc.settingsShakeRestartLink;

    const token = '@@LINK@@';
    final String textWithToken = loc.settingsShakeRestartHint(token);
    final List<String> parts = textWithToken.split(token);

    final List<InlineSpan> spans = [];

    if (parts.isNotEmpty) {
      spans.add(TextSpan(text: parts[0]));
    }

    if (parts.length > 1) {
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: GestureDetector(
            onTap: () => NativeEventsService.instance.restartApp(),
            child: Text(
              linkText,
              style: const TextStyle(
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
      spans.add(TextSpan(text: parts[1]));
    }

    return spans;
  }
}
