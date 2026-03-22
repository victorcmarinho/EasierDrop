import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:io' as io;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/services/tray_service.dart';
import 'package:easier_drop/helpers/app_constants.dart';

class WindowManagerService with WindowListener {
  static final WindowManagerService _instance = WindowManagerService._();
  WindowManagerService._();

  static WindowManagerService get instance => _instance; // coverage:ignore-line
  
  bool _initialized = false;
  @visibleForTesting
  Future<void> Function()? mockExitApp;

  // Last-known values to avoid redundant native bridge calls
  double? _lastOpacity;
  bool? _lastAlwaysOnTop;

  // Debounce timers for window geometry callbacks
  Timer? _resizeDebounce;
  Timer? _moveDebounce;
  static const Duration _geometryDebounce = Duration(milliseconds: 150);

  @visibleForTesting
  void resetForTesting() {
    _initialized = false;
    _lastOpacity = null;
    _lastAlwaysOnTop = null;
    _resizeDebounce?.cancel();
    _moveDebounce?.cancel();
    _resizeDebounce = null;
    _moveDebounce = null;
  }

  Future<void> initialize({
    bool isSecondaryWindow = false,
    String? windowId,
  }) async {
    if (!_initialized) { // coverage:ignore-line
      SettingsService.instance.addListener(_onSettingsChanged);
      _initialized = true; // coverage:ignore-line
    }

    // coverage:ignore-start
    if (isSecondaryWindow) {
      await _setupSecondaryWindow(windowId);
      return;
    }
    // coverage:ignore-end

    await _setupMainWindow();
  }

  // coverage:ignore-start
  Future<void> _setupMainWindow() async {
    windowManager.addListener(this);
    await Future.wait([TrayService.instance.configure(), _configureWindow()]);
  }
  // coverage:ignore-end

  // coverage:ignore-start
  Future<void> _setupSecondaryWindow(String? windowId) async {
    await windowManager.ensureInitialized();
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: true,
    );
    await windowManager.setResizable(false);
    await windowManager.setMaximizable(false);
    await windowManager.setAlwaysOnTop(
      SettingsService.instance.settings.isAlwaysOnTop,
    );

    try {
      final controller = await WindowController.fromCurrentEngine();
      final args = jsonDecode(controller.arguments) as Map<String, dynamic>;

      if (args['title'] != null) {
        await windowManager.setTitle(args['title'] as String);
      }

      final double width =
          (args['width'] as num?)?.toDouble() ?? AppConstants.defaultWindowSize;
      final double height =
          (args['height'] as num?)?.toDouble() ??
          AppConstants.defaultWindowSize;

      if (args['x'] != null && args['y'] != null) {
        await windowManager.setBounds(
          Rect.fromLTWH(
            (args['x'] as num).toDouble(),
            (args['y'] as num).toDouble(),
            width,
            height,
          ),
        );
      } else {
        await windowManager.setSize(Size(width, height));
      }

      if (args['center'] == true) {
        await windowManager.center();
      }

      await controller.show();
    } catch (e) {
      AnalyticsService.instance.warn('Failed to setup secondary window: $e');
      if (windowId != null) {
        WindowController.fromWindowId(windowId).show();
      }
    }
  }
  // coverage:ignore-end

  // coverage:ignore-start
  Future<void> _configureWindow() async {
    await windowManager.ensureInitialized();
    await windowManager.setResizable(false);
    await windowManager.setMaximizable(false);

    const defaultSize = Size(
      AppConstants.defaultWindowSize,
      AppConstants.defaultWindowSize,
    );

    final options = const WindowOptions(
      minimumSize: defaultSize,
      maximumSize: defaultSize,
      size: defaultSize,
      backgroundColor: Colors.transparent,
      alwaysOnTop: true,
      titleBarStyle: TitleBarStyle.hidden,
      title: 'Easier Drop',
      windowButtonVisibility: true,
      fullScreen: false,
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
  // coverage:ignore-end

  // coverage:ignore-start
  Future<void> _restoreWindowPosition() async {
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
  // coverage:ignore-end

  Future<void> _onSettingsChanged() async {
    final s = SettingsService.instance.settings;
    final futures = <Future<void>>[];

    if (_lastOpacity != s.windowOpacity) {
      _lastOpacity = s.windowOpacity;
      futures.add(windowManager.setOpacity(s.windowOpacity));
    }
    if (_lastAlwaysOnTop != s.isAlwaysOnTop) {
      _lastAlwaysOnTop = s.isAlwaysOnTop;
      futures.add(windowManager.setAlwaysOnTop(s.isAlwaysOnTop));
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  // coverage:ignore-start
  Future<void> createNewWindow(double x, double y) async {
    final windowIds = await WindowController.getAll();
    if (windowIds.length >= AppConstants.maxWindows) {
      AnalyticsService.instance.debug(
        'Max windows reached (${windowIds.length}), ignoring shake',
        tag: 'WindowManagerService',
      );
      AnalyticsService.instance.shakeLimitReached();
      return;
    }

    AnalyticsService.instance.debug(
      'Creating shake window at $x, $y',
      tag: 'WindowManagerService',
    );
    const size = AppConstants.defaultWindowSize;
    final left = x - (size / 2);
    final top = y - (size / 2);

    await WindowController.create(
      WindowConfiguration(
        arguments: jsonEncode(
          _createWindowArgs(
            args: AppConstants.routeShare,
            x: left,
            y: top,
            width: size,
            height: size,
          ),
        ),
      ),
    );
    AnalyticsService.instance.shakeWindowCreated();
  }
  // coverage:ignore-end

  Future<void> hide() async {
    await Future.wait([
      windowManager.hide(),
      windowManager.setSkipTaskbar(true),
    ]);
    AnalyticsService.instance.trackEvent('window_hidden');
  }

  Future<void> open() async {
    await Future.wait([
      windowManager.show(),
      windowManager.focus(),
      windowManager.setSkipTaskbar(false),
    ]);
    AnalyticsService.instance.trackEvent('window_shown');
  }

  // coverage:ignore-start
  Map<String, dynamic> _createWindowArgs({
    required String args,
    String? title,
    double width = AppConstants.defaultWindowSize,
    double height = AppConstants.defaultWindowSize,
    bool center = true,
    bool resizable = false,
    bool maximizable = false,
    double? x,
    double? y,
  }) {
    return {
      'args': args,
      'title': title,
      'width': width,
      'height': height,
      'center': center,
      'resizable': resizable,
      'maximizable': maximizable,
      'x': x,
      'y': y,
    };
  }
  // coverage:ignore-end

  // coverage:ignore-start
  Future<void> openSettings() async {
    final window = await WindowController.create(
      WindowConfiguration(
        arguments: jsonEncode(
          _createWindowArgs(
            args: AppConstants.routeSettings,
            title: 'Preferences',
            width: 600.0,
            height: 500.0,
          ),
        ),
      ),
    );
    await window.show();
    AnalyticsService.instance.settingsOpened();
  }
  // coverage:ignore-end

  // coverage:ignore-start
  Future<void> openUpdateWindow() async {
    final window = await WindowController.create(
      WindowConfiguration(
        arguments: jsonEncode(
          _createWindowArgs(
            args: AppConstants.routeUpdate,
            title: 'Software Update',
            width: 400.0,
            height: 300.0,
          ),
        ),
      ),
    );
    await window.show();
  }
  // coverage:ignore-end

  Future<void> exitApp() async {
    await Future.wait([
      TrayService.instance.destroy(),
      windowManager.destroy(),
    ]);
    if (mockExitApp != null) {
      await mockExitApp!();
    } else {
      io.exit(0); // coverage:ignore-line
    }
  }

  @override
  void onWindowClose() async {
    await hide();
  }

  // coverage:ignore-start
  @override
  void onWindowResize() {
    _resizeDebounce?.cancel();
    _resizeDebounce = Timer(_geometryDebounce, () async {
      final size = await windowManager.getSize();
      SettingsService.instance.setWindowBounds(w: size.width, h: size.height);
    });
  }
  // coverage:ignore-end

  // coverage:ignore-start
  @override
  void onWindowMove() {
    _moveDebounce?.cancel();
    _moveDebounce = Timer(_geometryDebounce, () async {
      final pos = await windowManager.getPosition();
      SettingsService.instance.setWindowBounds(x: pos.dx, y: pos.dy);
    });
  }
  // coverage:ignore-end
}
