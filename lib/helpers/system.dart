// coverage: ignore-file

import 'package:flutter/material.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:easier_drop/services/logger.dart';

class SystemHelper with WindowListener {
  static final SystemHelper _instance = SystemHelper();

  static Future<void> hide() async {
    await windowManager.setOpacity(0);
    await windowManager.setSkipTaskbar(true);
  }

  static Future<void> open() async {
    await windowManager.setOpacity(1);
    await windowManager.setSkipTaskbar(false);
    await Future.wait([windowManager.show(), windowManager.focus()]);
  }

  static Future<void> exit() async {
    await trayManager.destroy();
    await windowManager.destroy();
  }

  @override
  Future<void> onWindowClose() async {
    await hide();
  }

  static Future<void> setup() async {
    await SettingsService.instance.load();
    windowManager.addListener(_instance);
    await Future.wait([
      SystemHelper._configureTray(),
      SystemHelper._configureWindow(),
    ]);
  }

  static Future<void> _configureWindow() async {
    await windowManager.ensureInitialized();
    final s = SettingsService.instance;
    final initialSize = const Size(250, 250);
    final options = WindowOptions(
      minimumSize: const Size(250, 250),
      maximumSize: const Size(250, 250),
      size: initialSize,
      backgroundColor: Colors.transparent,
      alwaysOnTop: true,
      titleBarStyle: TitleBarStyle.hidden,
      title: 'Easier Drop',
      windowButtonVisibility: false,
      skipTaskbar: false,
    );

    await windowManager.waitUntilReadyToShow(options, () async {
      if (s.windowX != null && s.windowY != null) {
        try {
          await windowManager.setPosition(
            Offset(s.windowX!.toDouble(), s.windowY!.toDouble()),
            animate: false,
          );
        } catch (e) {
          AppLogger.warn('Failed to restore window position: $e');
        }
      }
      await SystemHelper.open();
    });

    await windowManager.setPreventClose(true);
  }

  static Future<void> _configureTray() async {
    try {
      await trayManager.setIcon('assets/icon/icon.icns');
    } catch (e) {
      AppLogger.warn('Failed to load tray icon: $e');
    }

    final code = SettingsService.instance.localeCode;
    final locale =
        code != null
            ? (code.contains('_')
                ? Locale(code.split('_')[0], code.split('_')[1])
                : Locale(code))
            : const Locale('en');
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

  @override
  void onWindowResize() async {
    final size = await windowManager.getSize();
    SettingsService.instance.setWindowBounds(w: size.width, h: size.height);
  }

  @override
  void onWindowMove() async {
    final pos = await windowManager.getPosition();
    SettingsService.instance.setWindowBounds(x: pos.dx, y: pos.dy);
  }
}
