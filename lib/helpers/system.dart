import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class SystemHelper {
  static Future<void> hide() async {
    await windowManager.hide();
  }

  static Future<void> open() async {
    await Future.wait([windowManager.show(), windowManager.focus()]);
  }

  static Future<void> exit() async {
    await SystemNavigator.pop(animated: true);
  }

  static Future<void> setup() async {
    await Future.wait([
      SystemHelper._configureTray(),
      SystemHelper._configureWindow(),
    ]);
  }

  static Future<void> _configureWindow() async {
    await windowManager.ensureInitialized();

    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        minimumSize: Size(150, 150),
        size: Size(250, 250),
        backgroundColor: Colors.transparent,
        alwaysOnTop: true,
        titleBarStyle: TitleBarStyle.hidden,
        title: 'Easier Drop',
        windowButtonVisibility: false,
      ),
      () async {
        await SystemHelper.open();
      },
    );
  }

  static Future<void> _configureTray() async {
    final Menu menu = Menu(
      items: [
        MenuItem(key: 'show_window', label: 'Abrir bandeja'),
        MenuItem.separator(),
        MenuItem(key: 'exit_app', label: 'Fechar o aplicativo'),
      ],
    );

    await trayManager.setIcon('assets/images/icon.icns');

    await trayManager.setContextMenu(menu);
  }
}
