import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'logger.dart';

/// Serviço responsável pelo gerenciamento de configurações da aplicação
///
/// Fornece persistência automática de configurações incluindo:
/// - Limite máximo de arquivos
/// - Posição e tamanho da janela
/// - Localização preferida
/// - Auto-clear de arquivos (futuro)
class SettingsService with ChangeNotifier {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  // Constantes de configuração
  static const String _fileName = 'settings.json';
  static const Duration _debounceDuration = Duration(milliseconds: 250);
  static const int _currentSchemaVersion = 1;

  // Chaves do JSON
  static const String _kSchemaVersion = 'schemaVersion';
  static const String _kMaxFiles = 'maxFiles';
  static const String _kWinX = 'windowX';
  static const String _kWinY = 'windowY';
  static const String _kWinW = 'windowW';
  static const String _kWinH = 'windowH';
  static const String _kLocale = 'locale';
  static const String _kAutoClearInbound = 'autoClearInbound';

  // Estado interno
  bool _loaded = false;
  Timer? _debounce;

  // Configurações públicas
  bool get isLoaded => _loaded;
  bool get autoClearInbound => false; // Função futura

  int maxFiles = 100;
  double? windowX;
  double? windowY;
  double? windowW;
  double? windowH;
  String? localeCode;

  /// Carrega as configurações do arquivo
  Future<void> load() async {
    if (_loaded) return;

    try {
      final file = await _getSettingsFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          await _parseSettings(content);
        }
      }
      _loaded = true;
    } catch (e) {
      AppLogger.warn('Falha ao carregar settings: $e');
      _loaded = true; // Marca como carregado mesmo com erro
    }
  }

  /// Faz o parse das configurações do JSON
  Future<void> _parseSettings(String jsonContent) async {
    try {
      final map = jsonDecode(jsonContent) as Map<String, dynamic>;

      // Carrega configurações com valores padrão
      if (map[_kMaxFiles] is int) {
        maxFiles = map[_kMaxFiles] as int;
      }

      windowX = (map[_kWinX] as num?)?.toDouble();
      windowY = (map[_kWinY] as num?)?.toDouble();
      windowW = (map[_kWinW] as num?)?.toDouble();
      windowH = (map[_kWinH] as num?)?.toDouble();

      if (map[_kLocale] is String) {
        localeCode = map[_kLocale] as String;
      }
    } catch (e) {
      AppLogger.warn('Erro ao fazer parse das configurações: $e');
    }
  }

  /// Define o número máximo de arquivos
  void setMaxFiles(int value) {
    if (value <= 0 || maxFiles == value) return;

    maxFiles = value;
    _schedulePersist();
    notifyListeners();
  }

  /// Define os limites da janela
  void setWindowBounds({double? x, double? y, double? w, double? h}) {
    windowX = x ?? windowX;
    windowY = y ?? windowY;
    windowW = w ?? windowW;
    windowH = h ?? windowH;
    _schedulePersist();
  }

  /// Define a localização
  void setLocale(String? code) {
    if (localeCode == code) return;

    localeCode = code;
    _schedulePersist();
    notifyListeners();
  }

  /// Agenda a persistência para evitar writes excessivos
  void _schedulePersist() {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, persist);
  }

  /// Persiste as configurações no arquivo
  Future<void> persist() async {
    try {
      final file = await _getSettingsFile();
      final settings = _buildSettingsMap();
      final jsonContent = const JsonEncoder.withIndent('  ').convert(settings);

      await file.writeAsString(jsonContent);
    } catch (e) {
      AppLogger.warn('Falha ao salvar settings: $e');
    }
  }

  /// Constrói o mapa de configurações para persistência
  Map<String, dynamic> _buildSettingsMap() {
    return {
      _kSchemaVersion: _currentSchemaVersion,
      _kAutoClearInbound: false,
      _kMaxFiles: maxFiles,
      if (localeCode != null) _kLocale: localeCode,
      if (windowX != null) _kWinX: windowX,
      if (windowY != null) _kWinY: windowY,
      if (windowW != null) _kWinW: windowW,
      if (windowH != null) _kWinH: windowH,
    };
  }

  /// Obtém o arquivo de configurações
  Future<File> _getSettingsFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, _fileName));
  }
}
