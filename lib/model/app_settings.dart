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

  const AppSettings({
    this.maxFiles = 100,
    this.windowX,
    this.windowY,
    this.windowW,
    this.windowH,
    this.localeCode,
    this.telemetryEnabled = true,
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
  }) {
    return AppSettings(
      maxFiles: maxFiles ?? this.maxFiles,
      windowX: windowX ?? this.windowX,
      windowY: windowY ?? this.windowY,
      windowW: windowW ?? this.windowW,
      windowH: windowH ?? this.windowH,
      localeCode: localeCode ?? this.localeCode,
      telemetryEnabled: telemetryEnabled ?? this.telemetryEnabled,
    );
  }
}
