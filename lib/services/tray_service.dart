import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easier_drop/services/window_manager_service.dart';
import 'package:easier_drop/core/utils/result_handler.dart';

class TrayService with ChangeNotifier {
  static final TrayService instance = TrayService._();
  TrayService._();

  String? _updateUrl;
  String? get updateUrl => _updateUrl;

  Future<void> configure() async {
    final (_, error) = await safeCall(() => trayManager.setIcon('assets/icon/icon.icns'));
    if (error != null) {
      AnalyticsService.instance.warn('Failed to load tray icon: $error');
    }
  }

  Future<void> checkForUpdates() async {
    final (url, error) = await UpdateService.instance.checkForUpdates();
    if (error == null && url != _updateUrl) {
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
    final (_, error) = await safeCall(() async {
      switch (menuItem.key) {
        case 'update_available':
          if (_updateUrl != null) await launchUrl(Uri.parse(_updateUrl!));
          break;
        case 'preferences':
          await WindowManagerService.instance.openSettings();
          break;
        case 'show_window':
          await WindowManagerService.instance.open();
          break;

        case 'exit_app':
          await WindowManagerService.instance.exitApp();
          break;
      }
    });

    if (error != null) {
      AnalyticsService.instance.error('Error handling tray menu item: $error');
    }
  }

  Future<void> destroy() async {
    await trayManager.destroy();
  }
}
