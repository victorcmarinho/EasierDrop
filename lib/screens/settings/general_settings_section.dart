import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/screens/settings/settings_view_model.dart';

class GeneralSettingsSection extends StatelessWidget {
  final SettingsViewModel viewModel;

  const GeneralSettingsSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([SettingsService.instance, viewModel]),
      builder: (context, _) {
        final settings = SettingsService.instance;
        final loc = AppLocalizations.of(context)!;

        return CupertinoListSection.insetGrouped(
          header: Text(
            loc.settingsGeneral.toUpperCase(),
            style: MacosTheme.of(context).typography.title3,
          ),
          backgroundColor: Colors.transparent,
          children: [
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.rocket_fill),
              title: Text(loc.settingsLaunchAtLogin),
              trailing: MacosSwitch(
                value: settings.settings.launchAtLogin,
                onChanged:
                    viewModel.isCheckingPermission ||
                        !viewModel.hasLaunchAtLoginPermission
                    ? null
                    : (v) async {
                        await settings.setLaunchAtLogin(v);
                        if (v) {
                          await viewModel.checkPermissions();
                        }
                      },
              ),
            ),
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.pin_fill),
              title: Text(loc.settingsAlwaysOnTop),
              trailing: MacosSwitch(
                value: settings.settings.isAlwaysOnTop,
                onChanged: (v) => settings.setAlwaysOnTop(v),
              ),
            ),
          ],
        );
      },
    );
  }
}
