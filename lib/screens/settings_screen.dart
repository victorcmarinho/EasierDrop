import 'dart:ui';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      backgroundColor: Colors.transparent,
      toolBar: ToolBar(
        title: const Text('Preferences'),
        titleWidth: 150.0,
        centerTitle: true,
        decoration: BoxDecoration(color: Colors.transparent),
        dividerColor: Colors.transparent,
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return _buildBody(context);
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          color: MacosTheme.of(context).canvasColor.withValues(alpha: 0.5),
          child: AnimatedBuilder(
            animation: SettingsService.instance,
            builder: (context, _) {
              final settings = SettingsService.instance;
              final loc = AppLocalizations.of(context)!;

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildSectionHeader(loc.settingsGeneral),
                  const SizedBox(height: 12),
                  _buildSettingsGroup([
                    _buildSettingsItem(
                      icon: CupertinoIcons.rocket_fill,
                      label: loc.settingsLaunchAtLogin,
                      child: MacosSwitch(
                        value: settings.settings.launchAtLogin,
                        onChanged: (v) => settings.setLaunchAtLogin(v),
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingsItem(
                      icon: CupertinoIcons.eye_slash_fill,
                      label: loc.settingsAutoHide,
                      child: MacosSwitch(
                        value: settings.settings.isAutoHideEnabled,
                        onChanged: (v) => settings.setAutoHide(v),
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingsItem(
                      icon: CupertinoIcons.pin_fill,
                      label: loc.settingsAlwaysOnTop,
                      child: MacosSwitch(
                        value: settings.settings.isAlwaysOnTop,
                        onChanged: (v) => settings.setAlwaysOnTop(v),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionHeader(loc.languageLabel),
                  const SizedBox(height: 12),
                  _buildSettingsGroup([
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: CupertinoSegmentedControl<String>(
                          children: {
                            'en': Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              child: Text(loc.languageEnglish),
                            ),
                            'pt_BR': Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              child: Text(loc.languagePortuguese),
                            ),
                            'es': Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              child: Text(loc.languageSpanish),
                            ),
                          },
                          groupValue: settings.localeCode ?? 'en',
                          onValueChanged: (v) => settings.setLocale(v),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ]),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: MacosColors.secondaryLabelColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: MacosColors.controlBackgroundColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: MacosColors.separatorColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: MacosColors.controlColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: MacosColors.labelColor),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: MacosColors.labelColor),
          ),
          const Spacer(),
          child,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      color: MacosColors.separatorColor,
      indent: 50, // Matches icon offset
    );
  }
}
