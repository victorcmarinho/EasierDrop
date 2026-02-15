import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  bool _hasLaunchAtLoginPermission = false;
  bool _isCheckingPermission = true;
  bool _hasShakePermission = false;
  bool _checkingShake = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    setState(() {
      _isCheckingPermission = true;
      _checkingShake = true;
    });

    final launchPerm = await SettingsService.instance
        .checkLaunchAtLoginPermission();
    final shakePerm = await SystemHelper.checkShakePermission();

    if (mounted) {
      setState(() {
        _hasLaunchAtLoginPermission = launchPerm;
        _isCheckingPermission = false;
        _hasShakePermission = shakePerm;
        _checkingShake = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: AppTheme.getCupertinoTheme(context),
      child: Material(color: Colors.transparent, child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    return AnimatedBuilder(
      animation: SettingsService.instance,
      builder: (context, _) {
        final settings = SettingsService.instance;
        final loc = AppLocalizations.of(context)!;

        return ListView(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: Text(
                  loc.preferences,
                  style: MacosTheme.of(context).typography.title2,
                ),
              ),
            ),
            CupertinoListSection.insetGrouped(
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
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.pin_fill),
                  title: Text(loc.settingsAlwaysOnTop),
                  trailing: MacosSwitch(
                    value: settings.settings.isAlwaysOnTop,
                    onChanged: (v) => settings.setAlwaysOnTop(v),
                  ),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: Text(
                loc.settingsShakeGesture.toUpperCase(),
                style: MacosTheme.of(context).typography.title3,
              ),
              backgroundColor: Colors.transparent,
              footer: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_hasShakePermission)
                    Text(loc.settingsShakePermissionDescription)
                  else ...[
                    Text(loc.settingsShakePermissionInstruction),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: MacosTheme.of(context).typography.footnote
                            .copyWith(
                              color:
                                  MacosTheme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFFCCCCCC)
                                  : const Color(0xFF666666),
                            ),
                        children: [..._buildRestartHintSpans(context, loc)],
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
                  additionalInfo: _checkingShake
                      ? const CupertinoActivityIndicator()
                      : Text(
                          _hasShakePermission
                              ? loc.settingsShakePermissionActive
                              : loc.settingsShakePermissionInactive,
                          style: TextStyle(
                            color: _hasShakePermission
                                ? CupertinoColors.activeGreen
                                : CupertinoColors.destructiveRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  onTap: !_hasShakePermission
                      ? () => SystemHelper.openAccessibilitySettings()
                      : null,
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: Text(
                loc.languageLabel.toUpperCase(),
                style: MacosTheme.of(context).typography.title3,
              ),
              backgroundColor: Colors.transparent,
              children: [
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
              ],
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
            onTap: () => SystemHelper.restartApp(),
            child: Text(
              linkText,
              style: TextStyle(
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
