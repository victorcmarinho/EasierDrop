// coverage: ignore-file

import 'package:flutter/material.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:easier_drop/services/logger.dart';
import 'package:flutter/services.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'dart:convert';

class SystemHelper with WindowListener {
  static final SystemHelper _instance = SystemHelper();
  static const MethodChannel _shakeChannel = MethodChannel(
    'com.easier_drop/shake',
  );

  static Future<void> hide() async {
    await Future.wait([
      windowManager.hide(),
      windowManager.setSkipTaskbar(true),
    ]);
  }

  static Future<void> open() async {
    await Future.wait([
      windowManager.show(),
      windowManager.focus(),
      windowManager.setSkipTaskbar(false),
    ]);
  }

  static Future<void> exit() async {
    await Future.wait([trayManager.destroy(), windowManager.destroy()]);
  }

  @override
  Future<void> onWindowClose() async {
    await hide();
    return;
  }

  static Future<void> setup({
    bool isSecondaryWindow = false,
    String? windowId,
  }) async {
    await SettingsService.instance.load();

    if (isSecondaryWindow) {
      // Secondary window setup
      await windowManager.ensureInitialized();
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );

      try {
        final controller = await WindowController.fromCurrentEngine();
        final args = jsonDecode(controller.arguments) as Map<String, dynamic>;

        if (args['x'] != null && args['y'] != null) {
          final width = (args['width'] as num?)?.toDouble() ?? 250.0;
          final height = (args['height'] as num?)?.toDouble() ?? 250.0;
          await windowManager.setBounds(
            Rect.fromLTWH(
              (args['x'] as num).toDouble(),
              (args['y'] as num).toDouble(),
              width,
              height,
            ),
          );
        }

        await controller.show();
      } catch (e) {
        AppLogger.warn('Failed to setup secondary window: $e');
        // Fallback to showing if possible
        if (windowId != null) {
          WindowController.fromWindowId(windowId.toString()).show();
        }
      }
      return;
    }

    // Main window setup
    windowManager.addListener(_instance);
    await Future.wait([
      SystemHelper._configureTray(),
      SystemHelper._configureWindow(),
    ]);

    // Listen for shake events
    _shakeChannel.setMethodCallHandler((call) async {
      if (call.method == 'shake_detected') {
        final args = call.arguments as Map;
        final x = args['x'] as double;
        final y = args['y'] as double;
        await _createNewWindow(x, y);
      }
    });
  }

  static Future<void> _createNewWindow(double x, double y) async {
    const width = 250.0;
    const height = 250.0;

    // Position the window centered on the mouse
    final left = x - (width / 2);
    final top = y - (height / 2);

    await WindowController.create(
      WindowConfiguration(
        arguments: jsonEncode({
          'args': 'shake_window',
          'x': left,
          'y': top,
          'width': width,
          'height': height,
        }),
      ),
    );
    // Note: The window is shown in setup() after positioning
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

      await Future.wait([
        windowManager.setPreventClose(true),
        windowManager.setVisibleOnAllWorkspaces(true),
      ]);
    });
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
