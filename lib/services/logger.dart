import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

enum LogLevel { trace, debug, info, warn, error }

class AppLogger {
  AppLogger._();
  static LogLevel minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  static void log(
    String message, {
    LogLevel level = LogLevel.info,
    String tag = 'App',
  }) {
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

  static void trace(String m, {String tag = 'App'}) =>
      log(m, level: LogLevel.trace, tag: tag);
  static void debug(String m, {String tag = 'App'}) =>
      log(m, level: LogLevel.debug, tag: tag);
  static void info(String m, {String tag = 'App'}) =>
      log(m, level: LogLevel.info, tag: tag);
  static void warn(String m, {String tag = 'App'}) =>
      log(m, level: LogLevel.warn, tag: tag);
  static void error(String m, {String tag = 'App'}) =>
      log(m, level: LogLevel.error, tag: tag);
}
