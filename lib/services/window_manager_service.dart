import 'dart:async';

import 'dart:io' as io;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:easier_drop/services/tray_service.dart';
import 'package:easier_drop/helpers/app_constants.dart';
import 'package:easier_drop/core/utils/result_handler.dart';

class WindowManagerService with WindowListener {
  static WindowManagerService _instance = WindowManagerService._();
  WindowManagerService._();

  static WindowManagerService get instance => _instance;
  @visibleForTesting
  static set instance(WindowManagerService value) => _instance = value;

  @visibleForTesting
  WindowManager? mockWindowManager;

  WindowManager get _wm => mockWindowManager ?? windowManager;
  
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
    if (!_initialized) {
      SettingsService.instance.addListener(_onSettingsChanged);
      _initialized = true;
    }

    if (isSecondaryWindow) {
      await _setupSecondaryWindow(windowId);
      return;
    }

    await _setupMainWindow();
  }

  Future<void> _setupMainWindow() async {
    _wm.addListener(this);
    await Future.wait([TrayService.instance.configure(), _configureWindow()]);
  }

  Future<void> _setupSecondaryWindow(String? windowId) async {
    await _wm.ensureInitialized();
    await _wm.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: true,
    );
    await _wm.setResizable(false);
    await _wm.setMaximizable(false);
    await _wm.setAlwaysOnTop(
      SettingsService.instance.settings.isAlwaysOnTop,
    );

    final (_, error) = await safeCall(() async {
      final controller = await WindowController.fromCurrentEngine();
      final args = jsonDecode(controller.arguments) as Map<String, dynamic>;

      if (args['title'] != null) {
        await _wm.setTitle(args['title'] as String);
      }

      final double width =
          (args['width'] as num?)?.toDouble() ?? AppConstants.defaultWindowSize;
      final double height =
          (args['height'] as num?)?.toDouble() ??
          AppConstants.defaultWindowSize;

      if (args['x'] != null && args['y'] != null) {
        await _wm.setBounds(
          Rect.fromLTWH(
            (args['x'] as num).toDouble(),
            (args['y'] as num).toDouble(),
            width,
            height,
          ),
        );
      } else {
        await _wm.setSize(Size(width, height));
      }

      if (args['center'] == true) {
        await _wm.center();
      }

      await controller.show();
    });

    if (error != null) {
      AnalyticsService.instance.warn('Failed to setup secondary window: $error');
      if (windowId != null) {
        WindowController.fromWindowId(windowId).show();
      }
    }
  }

  Future<void> _configureWindow() async {
    await _wm.ensureInitialized();
    await _wm.setResizable(false);
    await _wm.setMaximizable(false);

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

    await _wm.waitUntilReadyToShow(options, () async {
      await _restoreWindowPosition();

      await Future.wait([
        _wm.setPreventClose(true),
        _wm.setVisibleOnAllWorkspaces(true),
      ]);
    });
  }

  Future<void> _restoreWindowPosition() async {
    final s = SettingsService.instance;
    if (s.windowX != null && s.windowY != null) {
      final (_, error) = await safeCall(() => _wm.setPosition(
        Offset(s.windowX!.toDouble(), s.windowY!.toDouble()),
        animate: false,
      ));
      if (error != null) {
        AnalyticsService.instance.warn('Failed to restore window position: $error');
      }
    }
  }

  Future<void> _onSettingsChanged() async {
    final s = SettingsService.instance.settings;
    final futures = <Future<void>>[];

    if (_lastOpacity != s.windowOpacity) {
      _lastOpacity = s.windowOpacity;
      futures.add(_wm.setOpacity(s.windowOpacity));
    }
    if (_lastAlwaysOnTop != s.isAlwaysOnTop) {
      _lastAlwaysOnTop = s.isAlwaysOnTop;
      futures.add(_wm.setAlwaysOnTop(s.isAlwaysOnTop));
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

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

  Future<void> hide() async {
    await Future.wait([
      _wm.hide(),
      _wm.setSkipTaskbar(true),
    ]);
    AnalyticsService.instance.windowHidden();
  }

  Future<void> open() async {
    await Future.wait([
      _wm.show(),
      _wm.focus(),
      _wm.setSkipTaskbar(false),
    ]);
    AnalyticsService.instance.windowShown();
  }

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

  Future<void> exitApp() async {
    await Future.wait([
      TrayService.instance.destroy(),
      _wm.destroy(),
    ]);
    if (mockExitApp != null) {
      await mockExitApp!();
    } else {
      io.exit(0);
    }
  }

  @override
  void onWindowClose() async {
    await hide();
  }

  @override
  void onWindowResize() {
    _resizeDebounce?.cancel();
    _resizeDebounce = Timer(_geometryDebounce, () async {
      final size = await _wm.getSize();
      SettingsService.instance.setWindowBounds(w: size.width, h: size.height);
    });
  }

  @override
  void onWindowMove() {
    _moveDebounce?.cancel();
    _moveDebounce = Timer(_geometryDebounce, () async {
      final pos = await _wm.getPosition();
      SettingsService.instance.setWindowBounds(x: pos.dx, y: pos.dy);
    });
  }
}
