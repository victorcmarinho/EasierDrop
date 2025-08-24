import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'logger.dart';

class SettingsService with ChangeNotifier {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const _fileName = 'settings.json';
  static const _kSchemaVersion = 'schemaVersion';
  static const _kMaxFiles = 'maxFiles';
  static const _kWinX = 'windowX';
  static const _kWinY = 'windowY';
  static const _kWinW = 'windowW';
  static const _kWinH = 'windowH';
  static const int _currentSchemaVersion = 1;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  // Preferences
  // autoClearInbound removido (fixado como false) – mantemos leitura para compat forwards.
  static const _kAutoClearInbound = 'autoClearInbound';
  bool get autoClearInbound => false;
  int maxFiles = 100;
  double? windowX;
  double? windowY;
  double? windowW;
  double? windowH;

  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 250);

  Future<void> load() async {
    if (_loaded) return;
    try {
      final file = await _file();
      if (await file.exists()) {
        final raw = await file.readAsString();
        if (raw.trim().isNotEmpty) {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          // ignorado: autoClearInbound sempre false agora.
          if (map[_kMaxFiles] is int) maxFiles = map[_kMaxFiles] as int;
          windowX = (map[_kWinX] as num?)?.toDouble();
          windowY = (map[_kWinY] as num?)?.toDouble();
          windowW = (map[_kWinW] as num?)?.toDouble();
          windowH = (map[_kWinH] as num?)?.toDouble();
        }
      }
      _loaded = true;
    } catch (e) {
      AppLogger.warn('Falha ao carregar settings: $e');
    }
  }

  void setAutoClearInbound(bool value) {
    // opção desativada permanentemente; noop
  }

  void setMaxFiles(int value) {
    if (value <= 0) return;
    if (maxFiles == value) return;
    maxFiles = value;
    _schedulePersist();
    notifyListeners();
  }

  void setWindowBounds({double? x, double? y, double? w, double? h}) {
    windowX = x ?? windowX;
    windowY = y ?? windowY;
    windowW = w ?? windowW;
    windowH = h ?? windowH;
    _schedulePersist();
  }

  void _schedulePersist() {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () => persist());
  }

  Future<void> persist() async {
    try {
      final file = await _file();
      final map = <String, dynamic>{
        _kSchemaVersion: _currentSchemaVersion,
        // Persistimos como false para manter compatibilidade de arquivo
        _kAutoClearInbound: false,
        _kMaxFiles: maxFiles,
        if (windowX != null) _kWinX: windowX,
        if (windowY != null) _kWinY: windowY,
        if (windowW != null) _kWinW: windowW,
        if (windowH != null) _kWinH: windowH,
      };
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(map));
    } catch (e) {
      AppLogger.warn('Falha ao salvar settings: $e');
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, _fileName));
  }
}
