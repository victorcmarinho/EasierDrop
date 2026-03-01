import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/theme/app_theme.dart';
import 'package:easier_drop/screens/settings/settings_view_model.dart';
import 'package:easier_drop/screens/settings/general_settings_section.dart';
import 'package:easier_drop/screens/settings/shake_gesture_section.dart';
import 'package:easier_drop/screens/settings/language_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  late final SettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SettingsViewModel();
    WidgetsBinding.instance.addObserver(this);
    _viewModel.checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _viewModel.checkPermissions();
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
        GeneralSettingsSection(viewModel: _viewModel),
        ShakeGestureSection(viewModel: _viewModel),
        const LanguageSection(),
      ],
    );
  }
}
