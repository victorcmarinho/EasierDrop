import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/services/logger.dart';

class TrayService {
  static final TrayService instance = TrayService._();
  TrayService._();

  Future<void> configure() async {
    try {
      await trayManager.setIcon('assets/icon/icon.icns');
    } catch (e) {
      AppLogger.warn('Failed to load tray icon: $e');
    }

    final code = SettingsService.instance.localeCode;
    final locale = _getLocale(code);
    final loc = lookupAppLocalizations(locale);

    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(key: 'show_window', label: loc.openTray),
          MenuItem(key: 'files_count', label: loc.trayFilesNone),
          MenuItem.separator(),
          MenuItem(key: 'exit_app', label: loc.trayExit),
        ],
      ),
    );
  }

  Locale _getLocale(String? code) {
    if (code == null) return const Locale('en');

    if (code.contains('_')) {
      final parts = code.split('_');
      return Locale(parts[0], parts[1]);
    }
    return Locale(code);
  }

  Future<void> destroy() async {
    await trayManager.destroy();
  }
}
