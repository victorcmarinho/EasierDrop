import 'package:flutter/material.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:window_manager/window_manager.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/services/tray_service.dart';
import 'package:easier_drop/helpers/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'dart:convert';

class SystemHelper with WindowListener {
  static final SystemHelper _instance = SystemHelper();

  static const MethodChannel _shakeChannel = MethodChannel(
    AppConstants.shakeChannelName,
  );

  static Future<void> hide() async {
    await Future.wait([
      windowManager.hide(),
      windowManager.setSkipTaskbar(true),
    ]);
    AnalyticsService.instance.trackEvent('window_hidden');
  }

  static Future<void> open() async {
    await Future.wait([
      windowManager.show(),
      windowManager.focus(),
      windowManager.setSkipTaskbar(false),
    ]);
    AnalyticsService.instance.trackEvent('window_shown');
  }

  static Future<void> exit() async {
    await Future.wait([
      TrayService.instance.destroy(),
      windowManager.destroy(),
    ]);
  }

  @override
  Future<void> onWindowClose() async {
    await hide();
  }

  static Future<void> initialize({
    bool isSecondaryWindow = false,
    String? windowId,
  }) async {
    await SettingsService.instance.load();

    if (isSecondaryWindow) {
      await _setupSecondaryWindow(windowId);
      return;
    }

    await _setupMainWindow();
  }

  static Future<void> _setupMainWindow() async {
    windowManager.addListener(_instance);

    await Future.wait([TrayService.instance.configure(), _configureWindow()]);

    _shakeChannel.setMethodCallHandler(_handleShakeEvent);
  }

  static Future<void> _handleShakeEvent(MethodCall call) async {
    if (call.method == 'shake_detected') {
      final args = call.arguments as Map;
      final x = (args['x'] as num).toDouble();
      final y = (args['y'] as num).toDouble();
      await _createNewWindow(x, y);
    }
  }

  static Future<void> _setupSecondaryWindow(String? windowId) async {
    await windowManager.ensureInitialized();
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );

    try {
      final controller = await WindowController.fromCurrentEngine();
      final args = jsonDecode(controller.arguments) as Map<String, dynamic>;

      if (args['x'] != null && args['y'] != null) {
        final double width =
            (args['width'] as num?)?.toDouble() ??
            AppConstants.defaultWindowSize;
        final double height =
            (args['height'] as num?)?.toDouble() ??
            AppConstants.defaultWindowSize;

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
      AnalyticsService.instance.warn('Failed to setup secondary window: $e');
      if (windowId != null) {
        WindowController.fromWindowId(windowId).show();
      }
    }
  }

  static Future<void> _createNewWindow(double x, double y) async {
    const size = AppConstants.defaultWindowSize;
    final left = x - (size / 2);
    final top = y - (size / 2);

    await WindowController.create(
      WindowConfiguration(
        arguments: jsonEncode({
          'args': 'shake_window',
          'x': left,
          'y': top,
          'width': size,
          'height': size,
        }),
      ),
    );
    AnalyticsService.instance.shakeWindowCreated();
  }

  static Future<void> _configureWindow() async {
    await windowManager.ensureInitialized();

    const defaultSize = Size(
      AppConstants.defaultWindowSize,
      AppConstants.defaultWindowSize,
    );

    final options = WindowOptions(
      minimumSize: defaultSize,
      maximumSize: defaultSize,
      size: defaultSize,
      backgroundColor: Colors.transparent,
      alwaysOnTop: true,
      titleBarStyle: TitleBarStyle.hidden,
      title: 'Easier Drop',
      windowButtonVisibility: false,
      skipTaskbar: false,
    );

    await windowManager.waitUntilReadyToShow(options, () async {
      await _restoreWindowPosition();

      await Future.wait([
        windowManager.setPreventClose(true),
        windowManager.setVisibleOnAllWorkspaces(true),
      ]);
    });
  }

  static Future<void> _restoreWindowPosition() async {
    final s = SettingsService.instance;
    if (s.windowX != null && s.windowY != null) {
      try {
        await windowManager.setPosition(
          Offset(s.windowX!.toDouble(), s.windowY!.toDouble()),
          animate: false,
        );
      } catch (e) {
        AnalyticsService.instance.warn('Failed to restore window position: $e');
      }
    }
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
