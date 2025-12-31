import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/settings_service.dart';
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
    required int fileCount,
    required String currentLocale,
  }) async {
    final menu = Menu(
      items: [
        if (_updateUrl != null) ...[
          MenuItem(key: 'update_available', label: '🌟 ${loc.updateAvailable}'),
          MenuItem.separator(),
        ],
        MenuItem(key: 'show_window', label: loc.openTray),
        MenuItem(
          key: 'files_count',
          label:
              fileCount > 0 ? loc.trayFilesCount(fileCount) : loc.trayFilesNone,
          toolTip: loc.filesCountTooltip,
        ),
        MenuItem.separator(),
        MenuItem(key: 'lang_label', label: loc.languageLabel),
        _buildLangItem('en', loc.languageEnglish, currentLocale == 'en'),
        _buildLangItem(
          'pt',
          loc.languagePortuguese,
          currentLocale == 'pt' || currentLocale == 'pt_BR',
        ),
        _buildLangItem('es', loc.languageSpanish, currentLocale == 'es'),
        MenuItem.separator(),
        MenuItem(key: 'exit_app', label: loc.trayExit),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  MenuItem _buildLangItem(String key, String label, bool isSelected) {
    return MenuItem(key: 'lang_$key', label: isSelected ? '• $label' : label);
  }

  Future<void> handleMenuItemClick(MenuItem menuItem) async {
    try {
      switch (menuItem.key) {
        case 'update_available':
          if (_updateUrl != null) await launchUrl(Uri.parse(_updateUrl!));
          break;
        case 'show_window':
          await SystemHelper.open();
          break;
        case 'lang_en':
          SettingsService.instance.setLocale('en');
          break;
        case 'lang_pt':
          SettingsService.instance.setLocale('pt_BR');
          break;
        case 'lang_es':
          SettingsService.instance.setLocale('es');
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
