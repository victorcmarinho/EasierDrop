import 'package:flutter/material.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:easier_drop/services/logger.dart';

class SystemHelper with WindowListener {
  static Future<void> hide() async {
    await windowManager.hide();
  }

  static Future<void> open() async {
    await Future.wait([windowManager.show(), windowManager.focus()]);
  }

  static Future<void> exit() async {
    await trayManager.destroy();
    await windowManager.destroy();
  }

  static Future<void> setup() async {
    await SettingsService.instance.load();
    windowManager.addListener(SystemHelper());
    await Future.wait([
      SystemHelper._configureTray(),
      SystemHelper._configureWindow(),
    ]);
  }

  static Future<void> _configureWindow() async {
    await windowManager.ensureInitialized();
    final s = SettingsService.instance;
    final initialSize =
        (s.windowW != null && s.windowH != null)
            ? Size(s.windowW!.clamp(150, 800), s.windowH!.clamp(150, 800))
            : const Size(250, 250);
    final options = WindowOptions(
      minimumSize: const Size(150, 150),
      size: initialSize,
      backgroundColor: Colors.transparent,
      alwaysOnTop: true,
      titleBarStyle: TitleBarStyle.hidden,
      title: 'Easier Drop',
      windowButtonVisibility: false,
      skipTaskbar: true,
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
  }

  static Future<void> _configureTray() async {
    try {
      await trayManager.setIcon('assets/images/icon.icns');
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
