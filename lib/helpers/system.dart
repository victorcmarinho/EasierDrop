import 'package:flutter/material.dart';
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
    // Carrega settings
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
          AppLogger.warn('Falha ao restaurar posição janela: $e');
        }
      }
      await SystemHelper.open();
    });
  }

  static Future<void> _configureTray() async {
    try {
      await trayManager.setIcon('assets/images/icon.icns');
    } catch (e) {
      AppLogger.warn('Falha ao carregar ícone da tray: $e');
    }
    // Menu inicial mínimo; será substituído pelo widget/traduções após build.
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(key: 'show_window', label: 'Open tray'),
          MenuItem(key: 'files_count', label: '\uD83D\uDCC2 No files'),
          MenuItem.separator(),
          MenuItem(key: 'exit_app', label: 'Quit application'),
        ],
      ),
    );
  }

  // WindowListener impl
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
