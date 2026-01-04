import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
  static const MethodChannel _launchAtLoginChannel = MethodChannel(
    'com.easierdrop/launch_at_login',
  );

  bool _loaded = false;
  Timer? _debounce;
  AppSettings _settings = const AppSettings();

  @override
  void dispose() {
    _subscription?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

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
      } else {
        // First run configuration
        String defaultLocale = 'en';
        try {
          final sysLocale = Platform.localeName.toLowerCase();
          if (sysLocale.startsWith('pt')) {
            defaultLocale = 'pt_BR';
          } else if (sysLocale.startsWith('es')) {
            defaultLocale = 'es';
          }
        } catch (_) {}

        _settings = _settings.copyWith(
          isAlwaysOnTop: true,
          localeCode: defaultLocale,
        );
        // Persist default settings
        await persist();
      }
    } catch (e) {
      AnalyticsService.instance.warn('Falha ao carregar settings: $e');
    } finally {
      _loaded = true;
      _startWatching();
      notifyListeners();
    }
  }

  @visibleForTesting
  void resetForTesting() {
    _loaded = false;
    _settings = const AppSettings();
    _subscription?.cancel();
    _subscription = null;
    _debounce?.cancel();
    _debounce = null;
  }

  StreamSubscription<FileSystemEvent>? _subscription;

  Future<void> _startWatching() async {
    _subscription?.cancel();
    final file = await _getSettingsFile();
    _subscription = file.parent.watch(events: FileSystemEvent.modify).listen((
      event,
    ) async {
      if (p.basename(event.path) == _fileName) {
        await _reloadSettings();
      }
    });
  }

  Future<void> _reloadSettings() async {
    try {
      final file = await _getSettingsFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          final map = jsonDecode(content) as Map<String, dynamic>;
          final newSettings = AppSettings.fromMap(map);
          if (_settings != newSettings) {
            _settings = newSettings;
            notifyListeners();
          }
        }
      }
    } catch (e) {
      AnalyticsService.instance.warn('Failed to reload settings: $e');
    }
  }

  void setMaxFiles(int value) {
    if (value <= 0 || _settings.maxFiles == value) return;
    _updateSettings(_settings.copyWith(maxFiles: value));
    AnalyticsService.instance.settingsChanged('maxFiles', value);
  }

  void setWindowBounds({double? x, double? y, double? w, double? h}) {
    _updateSettings(
      _settings.copyWith(windowX: x, windowY: y, windowW: w, windowH: h),
    );
  }

  void setLocale(String? code) {
    if (_settings.localeCode == code) return;
    _updateSettings(_settings.copyWith(localeCode: code));
    AnalyticsService.instance.settingsChanged('locale', code);
  }

  void setTelemetryEnabled(bool enabled) {
    if (_settings.telemetryEnabled == enabled) return;
    _updateSettings(_settings.copyWith(telemetryEnabled: enabled));
    AnalyticsService.instance.settingsChanged('telemetryEnabled', enabled);
  }

  void setAlwaysOnTop(bool enabled) {
    if (_settings.isAlwaysOnTop == enabled) return;
    _updateSettings(_settings.copyWith(isAlwaysOnTop: enabled));
    AnalyticsService.instance.settingsChanged('alwaysOnTop', enabled);
  }

  Future<void> setLaunchAtLogin(bool enabled) async {
    if (_settings.launchAtLogin == enabled) return;

    try {
      await _launchAtLoginChannel.invokeMethod('setEnabled', {
        'enabled': enabled,
      });
      _updateSettings(_settings.copyWith(launchAtLogin: enabled));
      AnalyticsService.instance.settingsChanged('launchAtLogin', enabled);
    } catch (e) {
      AnalyticsService.instance.error('Failed to change launch at login: $e');
    }
  }

  Future<bool> checkLaunchAtLoginPermission() async {
    try {
      final hasPermission = await _launchAtLoginChannel.invokeMethod<bool>(
        'checkPermission',
      );
      return hasPermission ?? false;
    } catch (e) {
      AnalyticsService.instance.warn(
        'Failed to check launch at login permission: $e',
      );
      return false;
    }
  }

  Future<bool> getLaunchAtLoginStatus() async {
    try {
      final isEnabled = await _launchAtLoginChannel.invokeMethod<bool>(
        'isEnabled',
      );
      return isEnabled ?? false;
    } catch (e) {
      AnalyticsService.instance.warn(
        'Failed to get launch at login status: $e',
      );
      return false;
    }
  }

  void setWindowOpacity(double opacity) {
    if (_settings.windowOpacity == opacity) return;
    _updateSettings(_settings.copyWith(windowOpacity: opacity));
    AnalyticsService.instance.settingsChanged('windowOpacity', opacity);
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
