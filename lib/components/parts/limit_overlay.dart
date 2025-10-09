import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

class LimitOverlay extends StatelessWidget {
  const LimitOverlay({super.key, required this.visible, required this.loc});
  final bool visible;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final theme = MacosTheme.of(context);
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.85),
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
    );
  }
}
