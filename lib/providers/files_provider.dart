import 'dart:async';
import 'package:easier_drop/helpers/macos/file_icon_helper.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/services/logger.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

/// Provider responsável pelo gerenciamento de arquivos no aplicativo.
///
/// Fornece funcionalidades para:
/// - Adicionar/remover arquivos
/// - Validação automática de arquivos
/// - Compartilhamento de arquivos
/// - Monitoramento de integridade dos arquivos
class FilesProvider with ChangeNotifier {
  static const Duration _notificationDelay = Duration(seconds: 2);
  static const Duration _monitorInterval = Duration(seconds: 5);

  final Map<String, FileReference> _files = {};
  List<FileReference>? _cachedFilesList;
  DateTime? _lastLimitHit;
  Timer? _monitorTimer;
  bool _notifyScheduled = false;
  bool _monitoringEnabled = true;

  // Getters públicos
  int get _maxFiles => SettingsService.instance.maxFiles;
  DateTime? get lastLimitHit => _lastLimitHit;
  bool get isEmpty => _files.isEmpty;
  bool get hasFiles => _files.isNotEmpty;
  int get fileCount => _files.length;

  bool get recentlyAtLimit =>
      _lastLimitHit != null &&
      DateTime.now().difference(_lastLimitHit!) < _notificationDelay;

  List<FileReference> get files =>
      _cachedFilesList ??= List.unmodifiable(_files.values);

  List<XFile> get validXFiles =>
      _files.values
          .where((file) => file.isValidSync())
          .map((file) => XFile(file.pathname))
          .toList();

  /// Agenda uma notificação para evitar múltiplas atualizações
  void _scheduleNotify() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    scheduleMicrotask(() {
      _notifyScheduled = false;
      notifyListeners();
    });
  }

  /// Invalida o cache da lista de arquivos
  void _invalidateCache() => _cachedFilesList = null;

  FilesProvider({bool enableMonitoring = true}) {
    _monitoringEnabled = enableMonitoring;
    if (_monitoringEnabled) {
      _monitorTimer = Timer.periodic(
        _monitorInterval,
        (_) => _rescanInternal(),
      );
    }
  }

  /// Adiciona um arquivo ao provider
  ///
  /// Verifica se o limite não foi atingido e se o arquivo é válido
  /// antes de adicioná-lo. Também carrega o ícone do arquivo assincronamente.
  Future<void> addFile(FileReference file) async {
    try {
      if (_files.length >= _maxFiles) {
        _lastLimitHit = DateTime.now();
        AppLogger.warn('File limit reached ($_maxFiles)', tag: 'FilesProvider');
        _scheduleNotify();
        return;
      }

      if (!await file.isValidAsync()) {
        AppLogger.debug(
          'Invalid file skipped: ${file.pathname}',
          tag: 'FilesProvider',
        );
        return;
      }

      if (_files.containsKey(file.pathname)) {
        AppLogger.debug(
          'Duplicate file ignored: ${file.pathname}',
          tag: 'FilesProvider',
        );
        return;
      }

      _files[file.pathname] = file;
      _invalidateCache();
      _scheduleNotify();

      // Carrega ícone e preview em paralelo
      _loadFileIcon(file);
      _loadFilePreview(file);

      AppLogger.info('File added: ${file.fileName}', tag: 'FilesProvider');
    } catch (e) {
      AppLogger.error('Error adding file: $e', tag: 'FilesProvider');
    }
  }

  /// Carrega o ícone do arquivo de forma assíncrona
  Future<void> _loadFileIcon(FileReference file) async {
    final iconData = await FileIconHelper.getFileIcon(file.pathname);
    if (iconData != null) {
      if (!_files.containsKey(file.pathname)) return;

      final current = _files[file.pathname];
      if (current != null && current.iconData == null) {
        _files[file.pathname] = current.withIcon(iconData);
        _invalidateCache();
        _scheduleNotify();
      }
    }
  }

  /// Carrega o preview do arquivo de forma assíncrona
  Future<void> _loadFilePreview(FileReference file) async {
    final previewData = await FileIconHelper.getFilePreview(file.pathname);
    if (previewData != null) {
      if (!_files.containsKey(file.pathname)) return; // Cleanup check

      final current = _files[file.pathname];
      if (current != null && current.previewData == null) {
        _files[file.pathname] = current.withPreview(previewData);
        _invalidateCache();
        _scheduleNotify();
      }
    }
  }

  /// Adiciona múltiplos arquivos
  Future<void> addFiles(Iterable<FileReference> files) async {
    for (final file in files) {
      await addFile(file);
    }
  }

  /// Remove um arquivo específico
  Future<void> removeFile(FileReference file) async {
    try {
      if (_files.remove(file.pathname) != null) {
        _invalidateCache();
        _scheduleNotify();
        AppLogger.info('File removed: ${file.fileName}', tag: 'FilesProvider');
      }
    } catch (e) {
      AppLogger.error('Error removing file: $e', tag: 'FilesProvider');
    }
  }

  /// Remove um arquivo pelo caminho
  void removeByPath(String pathname) {
    try {
      if (_files.remove(pathname) != null) {
        _invalidateCache();
        _scheduleNotify();
        AppLogger.info('File removed: $pathname', tag: 'FilesProvider');
      }
    } catch (e) {
      AppLogger.error('Error removing file by path: $e', tag: 'FilesProvider');
    }
  }

  /// Remove todos os arquivos
  void clear() {
    if (_files.isEmpty) return;

    final count = _files.length;
    _files.clear();
    _invalidateCache();
    _scheduleNotify();

    AppLogger.info('$count file(s) cleared', tag: 'FilesProvider');
  }

  /// Compartilha os arquivos válidos
  Future<Object> shared({Offset? position}) async {
    try {
      final validFiles = validXFiles;
      if (validFiles.isEmpty) {
        return ShareResult('shareNone', ShareResultStatus.unavailable);
      }

      final params = ShareParams(
        files: validFiles,
        sharePositionOrigin:
            position != null
                ? Rect.fromLTRB(
                  position.dx,
                  position.dy,
                  position.dx + 40,
                  position.dy + 40,
                )
                : null,
      );

      return SharePlus.instance.share(params);
    } catch (e) {
      AppLogger.error('Error sharing files: $e', tag: 'FilesProvider');
      return ShareResult('shareError', ShareResultStatus.unavailable);
    }
  }

  /// Faz um scan interno dos arquivos para remover inválidos
  void _rescanInternal() {
    if (_files.isEmpty) return;

    final toRemove = <String>[];
    for (final entry in _files.entries) {
      if (!entry.value.isValidSync()) {
        toRemove.add(entry.key);
      }
    }

    if (toRemove.isEmpty) return;

    for (final key in toRemove) {
      _files.remove(key);
    }

    _invalidateCache();
    _scheduleNotify();

    AppLogger.info(
      '${toRemove.length} invalid file(s) removed after rescan',
      tag: 'FilesProvider',
    );
  }

  /// Resolve mensagens de compartilhamento para exibição
  static String resolveShareMessage(String rawMessage, AppLocalizations loc) {
    switch (rawMessage) {
      case 'shareNone':
        return loc.shareNone;
      case 'shareError':
        return loc.shareError;
      default:
        return rawMessage;
    }
  }

  /// Força um rescan imediato dos arquivos
  void rescanNow() => _rescanInternal();

  @override
  void dispose() {
    _monitorTimer?.cancel();
    super.dispose();
  }

  @visibleForTesting
  void addFileForTest(FileReference ref) {
    _files[ref.pathname] = ref;
    _invalidateCache();
    _scheduleNotify();
  }
}
