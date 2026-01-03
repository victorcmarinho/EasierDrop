import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';

class TrayService with ChangeNotifier {
  static final TrayService instance = TrayService._();
  TrayService._();

  String? _updateUrl;
  String? get updateUrl => _updateUrl;

  Future<void> configure() async {
    try {
      await trayManager.setIcon('assets/icon/icon.icns');
    } catch (e) {
      AnalyticsService.instance.warn('Failed to load tray icon: $e');
    }
  }

  Future<void> checkForUpdates() async {
    final url = await UpdateService.instance.checkForUpdates();
    if (url != _updateUrl) {
      _updateUrl = url;
      notifyListeners();
    }
  }

  Future<void> rebuildMenu({
    required AppLocalizations loc,
    required String currentLocale,
  }) async {
    final menu = Menu(
      items: [
        if (_updateUrl != null) ...[
          MenuItem(key: 'update_available', label: '🌟 ${loc.updateAvailable}'),
          MenuItem.separator(),
        ],
        MenuItem(key: 'preferences', label: loc.preferences),
        MenuItem(key: 'show_window', label: loc.openTray),
        MenuItem.separator(),
        MenuItem(key: 'exit_app', label: loc.trayExit),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  Future<void> handleMenuItemClick(MenuItem menuItem) async {
    try {
      switch (menuItem.key) {
        case 'update_available':
          if (_updateUrl != null) await launchUrl(Uri.parse(_updateUrl!));
          break;
        case 'preferences':
          await SystemHelper.openSettings();
          break;
        case 'show_window':
          await SystemHelper.open();
          break;

        case 'exit_app':
          await SystemHelper.exit();
          break;
      }
    } catch (e) {
      AnalyticsService.instance.error('Error handling tray menu item: $e');
    }
  }

  Future<void> destroy() async {
    await trayManager.destroy();
  }
}
