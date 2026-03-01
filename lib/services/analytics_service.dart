import 'dart:developer' as dev;
import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:easier_drop/config/env_config.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter/foundation.dart';

enum LogLevel { trace, debug, info, warn, error }

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();
  @visibleForTesting
  static bool debugTestMode = kDebugMode;
  @visibleForTesting
  static String? testAppKey;
  @visibleForTesting
  static void Function(String, Map<String, dynamic>?)? testTrackEvent;

  @visibleForTesting
  bool get testInitialized => _initialized;
  bool _initialized = false;
  static LogLevel minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  Future<void> initialize() async {
    if (_initialized) return;

    final key = testAppKey ?? Env.aptabaseAppKey;
    if (key.isEmpty) {
      warn('Aptabase App Key não configurada. Telemetria desativada.');
      return;
    }

    try {
      if (!debugTestMode) {
        await Aptabase.init(key);
      }
      _initialized = true;
      info('Aptabase inicializado com sucesso.');
    } catch (e) {
      warn('Falha ao inicializar Aptabase: $e');
    }
  }

  void trackEvent(String name, [Map<String, dynamic>? props]) {
    if (!SettingsService.instance.telemetryEnabled) return;

    if (debugTestMode) {
      debug('Analytics Event: $name | Props: $props', tag: 'Analytics');
      return;
    }

    if (testTrackEvent != null) {
      testTrackEvent!(name, props);
      return;
    }

    if (!_initialized) return;

    try {
      Aptabase.instance.trackEvent(name, props);
    } catch (e) {
      warn('Falha ao enviar evento $name: $e');
    }
  }

  void appStarted() => trackEvent('app_started');

  void fileAdded({String? extension}) => trackEvent(
    'file_added',
    extension != null ? {'extension': extension} : null,
  );

  void fileRemoved({String? extension}) => trackEvent(
    'file_removed',
    extension != null ? {'extension': extension} : null,
  );

  void fileShared({required int count}) =>
      trackEvent('file_shared', {'count': count});

  void fileDroppedOut() => trackEvent('file_dropped_out');

  void shakeWindowCreated() => trackEvent('shake_window_created');

  void shakeDetected(double x, double y) =>
      trackEvent('shake_detected', {'x': x, 'y': y});

  void shakeLimitReached() => trackEvent('shake_limit_reached');

  void fileLimitReached() => trackEvent('file_limit_reached');

  void updateCheckStarted() => trackEvent('update_check_started');

  void updateAvailable(String version) =>
      trackEvent('update_available', {'version': version});

  void settingsOpened() => trackEvent('settings_opened');

  void settingsChanged(String key, dynamic value) =>
      trackEvent('settings_changed', {'key': key, 'value': value});

  static void _log(
    String message, {
    LogLevel level = LogLevel.info,
    String tag = 'App',
  }) {
    if (!debugTestMode) return;

    if (level.index < minLevel.index) return;
    final prefix = _prefix(level);
    final line = '[$prefix][$tag] $message';

    if (level == LogLevel.error) {
      dev.log(line, level: 1000, name: tag);
    } else {
      dev.log(line, name: tag);
    }
  }

  static String _prefix(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return 'TRACE';
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warn:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  void trace(String m, {String tag = 'App'}) =>
      _log(m, level: LogLevel.trace, tag: tag);
  void debug(String m, {String tag = 'App'}) =>
      _log(m, level: LogLevel.debug, tag: tag);
  void info(String m, {String tag = 'App'}) =>
      _log(m, level: LogLevel.info, tag: tag);
  void warn(String m, {String tag = 'App'}) =>
      _log(m, level: LogLevel.warn, tag: tag);
  void error(String m, {String tag = 'App'}) =>
      _log(m, level: LogLevel.error, tag: tag);

  static void sTrace(String m, {String tag = 'App'}) =>
      instance.trace(m, tag: tag);
  static void sDebug(String m, {String tag = 'App'}) =>
      instance.debug(m, tag: tag);
  static void sInfo(String m, {String tag = 'App'}) =>
      instance.info(m, tag: tag);
  static void sWarn(String m, {String tag = 'App'}) =>
      instance.warn(m, tag: tag);
  static void sError(String m, {String tag = 'App'}) =>
      instance.error(m, tag: tag);
}
