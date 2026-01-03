import 'package:flutter/foundation.dart';

@immutable
class AppSettings {
  final int maxFiles;
  final double? windowX;
  final double? windowY;
  final double? windowW;
  final double? windowH;
  final String? localeCode;
  final bool telemetryEnabled;
  final bool isAlwaysOnTop;
  final bool launchAtLogin;
  final double windowOpacity;

  const AppSettings({
    this.maxFiles = 100,
    this.windowX,
    this.windowY,
    this.windowW,
    this.windowH,
    this.localeCode,
    this.telemetryEnabled = true,
    this.isAlwaysOnTop = false,
    this.launchAtLogin = false,
    this.windowOpacity = 1.0,
  });

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      maxFiles: (map['maxFiles'] as int?) ?? 100,
      windowX: (map['windowX'] as num?)?.toDouble(),
      windowY: (map['windowY'] as num?)?.toDouble(),
      windowW: (map['windowW'] as num?)?.toDouble(),
      windowH: (map['windowH'] as num?)?.toDouble(),
      localeCode: map['locale'] as String?,
      telemetryEnabled: (map['telemetryEnabled'] as bool?) ?? true,
      isAlwaysOnTop: (map['isAlwaysOnTop'] as bool?) ?? false,
      launchAtLogin: (map['launchAtLogin'] as bool?) ?? false,
      windowOpacity: (map['windowOpacity'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toMap(int schemaVersion) {
    return {
      'schemaVersion': schemaVersion,
      'autoClearInbound': false,
      'maxFiles': maxFiles,
      if (localeCode != null) 'locale': localeCode,
      if (windowX != null) 'windowX': windowX,
      if (windowY != null) 'windowY': windowY,
      if (windowW != null) 'windowW': windowW,
      if (windowH != null) 'windowH': windowH,
      'telemetryEnabled': telemetryEnabled,
      'isAlwaysOnTop': isAlwaysOnTop,
      'launchAtLogin': launchAtLogin,
      'windowOpacity': windowOpacity,
    };
  }

  AppSettings copyWith({
    int? maxFiles,
    double? windowX,
    double? windowY,
    double? windowW,
    double? windowH,
    String? localeCode,
    bool? telemetryEnabled,
    bool? isAlwaysOnTop,
    bool? launchAtLogin,
    double? windowOpacity,
  }) {
    return AppSettings(
      maxFiles: maxFiles ?? this.maxFiles,
      windowX: windowX ?? this.windowX,
      windowY: windowY ?? this.windowY,
      windowW: windowW ?? this.windowW,
      windowH: windowH ?? this.windowH,
      localeCode: localeCode ?? this.localeCode,
      telemetryEnabled: telemetryEnabled ?? this.telemetryEnabled,
      isAlwaysOnTop: isAlwaysOnTop ?? this.isAlwaysOnTop,
      launchAtLogin: launchAtLogin ?? this.launchAtLogin,
      windowOpacity: windowOpacity ?? this.windowOpacity,
    );
  }
}
