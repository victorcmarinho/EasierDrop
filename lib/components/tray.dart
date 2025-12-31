import 'package:easier_drop/services/settings_service.dart';
import 'package:provider/provider.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/tray_service.dart';
import 'dart:async';

class Tray extends StatefulWidget {
  const Tray({super.key});

  @override
  State<Tray> createState() => _TrayState();
}

class _TrayState extends State<Tray> with TrayListener {
  int _lastCount = 0;
  Timer? _updateTimer;
  FilesProvider? _filesProvider;

  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);

    TrayService.instance.checkForUpdates();
    _updateTimer = Timer.periodic(
      const Duration(hours: 6),
      (_) => TrayService.instance.checkForUpdates(),
    );

    TrayService.instance.addListener(_rebuildMenu);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filesProvider = context.read<FilesProvider>();
      _filesProvider?.addListener(_onFilesChanged);
      _lastCount = _filesProvider?.files.length ?? 0;
      _rebuildMenu();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    TrayService.instance.removeListener(_rebuildMenu);
    if (_filesProvider != null) {
      _filesProvider!.removeListener(_onFilesChanged);
      _filesProvider = null;
    }
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onTrayIconMouseDown() {
    TrayService.instance.checkForUpdates();
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    TrayService.instance.handleMenuItemClick(menuItem);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  void _onFilesChanged() {
    final count = _filesProvider?.files.length ?? 0;
    if (count == _lastCount) return;
    _lastCount = count;
    _rebuildMenu();
  }

  void _rebuildMenu() {
    if (!mounted) return;

    final loc = AppLocalizations.of(context)!;
    final settings = SettingsService.instance;
    final current = settings.localeCode ?? loc.localeName.split('_').first;

    TrayService.instance.rebuildMenu(
      loc: loc,
      fileCount: _lastCount,
      currentLocale: current,
    );
  }
}
