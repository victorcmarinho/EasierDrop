import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hasLaunchAtLoginPermission = false;
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPermission =
        await SettingsService.instance.checkLaunchAtLoginPermission();
    if (mounted) {
      setState(() {
        _hasLaunchAtLoginPermission = hasPermission;
        _isCheckingPermission = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return AnimatedBuilder(
      animation: SettingsService.instance,
      builder: (context, _) {
        final settings = SettingsService.instance;
        final loc = AppLocalizations.of(context)!;

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Center(
                child: Text(
                  loc.preferences,
                  style: MacosTheme.of(context).typography.title2,
                ),
              ),
            ),
            _buildSectionHeader(context, loc.settingsGeneral),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildSettingsItem(
                context: context,
                icon: CupertinoIcons.rocket_fill,
                label: loc.settingsLaunchAtLogin,
                child: MacosSwitch(
                  value: settings.settings.launchAtLogin,
                  onChanged:
                      _isCheckingPermission || !_hasLaunchAtLoginPermission
                          ? null
                          : (v) async {
                            await settings.setLaunchAtLogin(v);
                            if (v) {
                              await _checkPermission();
                            }
                          },
                ),
              ),

              _buildDivider(),
              _buildSettingsItem(
                context: context,
                icon: CupertinoIcons.pin_fill,
                label: loc.settingsAlwaysOnTop,
                child: MacosSwitch(
                  value: settings.settings.isAlwaysOnTop,
                  onChanged: (v) => settings.setAlwaysOnTop(v),
                ),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader(context, loc.languageLabel),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<String>(
                    children: {
                      'en': Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Text(
                          loc.languageEnglish,
                          style: MacosTheme.of(context).typography.body,
                        ),
                      ),
                      'pt_BR': Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Text(
                          loc.languagePortuguese,
                          style: MacosTheme.of(context).typography.body,
                        ),
                      ),
                      'es': Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Text(
                          loc.languageSpanish,
                          style: MacosTheme.of(context).typography.body,
                        ),
                      ),
                    },
                    groupValue: settings.localeCode ?? 'en',
                    onValueChanged: (v) {
                      if (v != null) settings.setLocale(v);
                    },
                  ),
                ),
              ),
            ]),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: MacosTheme.of(context).typography.caption1.copyWith(
          fontWeight: FontWeight.w600,
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
    required BuildContext context,
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
          Text(label, style: MacosTheme.of(context).typography.body),
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
      indent: 50,
    );
  }
}
