import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:easier_drop/services/analytics_service.dart';

import 'package:easier_drop/model/app_settings.dart';

class SettingsService with ChangeNotifier {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const String _fileName = 'settings.json';
  static const Duration _debounceDuration = Duration(milliseconds: 250);
  static const int _currentSchemaVersion = 1;

  bool _loaded = false;
  Timer? _debounce;
  AppSettings _settings = const AppSettings();

  bool get isLoaded => _loaded;
  AppSettings get settings => _settings;

  int get maxFiles => _settings.maxFiles;
  double? get windowX => _settings.windowX;
  double? get windowY => _settings.windowY;
  double? get windowW => _settings.windowW;
  double? get windowH => _settings.windowH;
  String? get localeCode => _settings.localeCode;
  bool get telemetryEnabled => _settings.telemetryEnabled;

  Future<void> load() async {
    if (_loaded) return;

    try {
      final file = await _getSettingsFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          final map = jsonDecode(content) as Map<String, dynamic>;
          _settings = AppSettings.fromMap(map);
        }
      }
    } catch (e) {
      AnalyticsService.instance.warn('Falha ao carregar settings: $e');
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  void setMaxFiles(int value) {
    if (value <= 0 || _settings.maxFiles == value) return;
    _updateSettings(_settings.copyWith(maxFiles: value));
  }

  void setWindowBounds({double? x, double? y, double? w, double? h}) {
    _updateSettings(
      _settings.copyWith(windowX: x, windowY: y, windowW: w, windowH: h),
    );
  }

  void setLocale(String? code) {
    if (_settings.localeCode == code) return;
    _updateSettings(_settings.copyWith(localeCode: code));
  }

  void setTelemetryEnabled(bool enabled) {
    if (_settings.telemetryEnabled == enabled) return;
    _updateSettings(_settings.copyWith(telemetryEnabled: enabled));
  }

  void _updateSettings(AppSettings newSettings) {
    _settings = newSettings;
    _schedulePersist();
    notifyListeners();
  }

  void _schedulePersist() {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, persist);
  }

  Future<void> persist() async {
    try {
      final file = await _getSettingsFile();
      final jsonContent = const JsonEncoder.withIndent(
        '  ',
      ).convert(_settings.toMap(_currentSchemaVersion));
      await file.writeAsString(jsonContent);
    } catch (e) {
      AnalyticsService.instance.warn('Falha ao salvar settings: $e');
    }
  }

  Future<File> _getSettingsFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, _fileName));
  }
}
