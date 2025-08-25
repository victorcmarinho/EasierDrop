import 'dart:async';
import 'package:easier_drop/helpers/macos/file_icon_helper.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/services/logger.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

class FilesProvider with ChangeNotifier {
  final Map<String, FileReference> _files = {};
  List<FileReference>? _cachedList;
  int get _maxFiles => SettingsService.instance.maxFiles;
  DateTime? _lastLimitHit;
  DateTime? get lastLimitHit => _lastLimitHit;
  bool get recentlyAtLimit =>
      _lastLimitHit != null &&
      DateTime.now().difference(_lastLimitHit!) < const Duration(seconds: 2);

  Timer? _monitorTimer;
  static const Duration _monitorInterval = Duration(seconds: 5);
  bool _monitoringEnabled = true;

  List<FileReference> get files =>
      _cachedList ??= _files.values.toList(growable: false);

  List<XFile> get xfiles => _files.values
      .where((f) => f.isValidSync())
      .map((f) => XFile(f.pathname))
      .toList(growable: false);

  bool get isEmpty => _files.isEmpty;

  bool _notifyScheduled = false;
  void _scheduleNotify() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    scheduleMicrotask(() {
      _notifyScheduled = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _monitorTimer?.cancel();
    super.dispose();
  }

  FilesProvider({bool enableMonitoring = true}) {
    _monitoringEnabled = enableMonitoring;
    if (_monitoringEnabled) {
      _monitorTimer = Timer.periodic(
        _monitorInterval,
        (_) => _rescanInternal(),
      );
    }
  }

  Future<void> addFile(FileReference file) async {
    try {
      if (_files.length >= _maxFiles) {
        _lastLimitHit = DateTime.now();
        AppLogger.warn(
          'File limit reached ($_maxFiles)',
          tag: 'FilesProvider',
        ); // coverage:ignore-line
        _scheduleNotify();
        return;
      }
      if (!await file.isValidAsync()) {
        AppLogger.debug(
          // coverage:ignore-line
          'Invalid file skipped: ${file.pathname}',
          tag: 'FilesProvider',
        );
        return;
      }
      if (_files.containsKey(file.pathname)) {
        AppLogger.debug(
          // coverage:ignore-line
          'Duplicate file ignored: ${file.pathname}',
          tag: 'FilesProvider',
        );
        return;
      }

      _files[file.pathname] = file;
      _cachedList = null;
      _scheduleNotify();

      final iconData = await FileIconHelper.getFileIcon(file.pathname);
      if (iconData != null) {
        final current = _files[file.pathname];
        if (current != null && current.iconData == null) {
          _files[file.pathname] = current.withIcon(iconData);
          _cachedList = null;
          _scheduleNotify();
        }
      }
      AppLogger.info(
        'File added: ${file.fileName}',
        tag: 'FilesProvider',
      ); // coverage:ignore-line
    } catch (e) {
      AppLogger.error(
        'Error adding file: $e',
        tag: 'FilesProvider',
      ); // coverage:ignore-line
    }
  }

  Future<void> addFiles(Iterable<FileReference> files) async {
    for (final f in files) {
      await addFile(f);
    }
  }

  Future<void> removeFile(FileReference file) async {
    try {
      if (_files.remove(file.pathname) != null) {
        _cachedList = null;
        _scheduleNotify();
        AppLogger.info(
          'File removed: ${file.fileName}',
          tag: 'FilesProvider',
        ); // coverage:ignore-line
      }
    } catch (e) {
      AppLogger.error(
        'Error removing file: $e',
        tag: 'FilesProvider',
      ); // coverage:ignore-line
    }
  }

  void removeByPath(String pathname) {
    try {
      if (_files.remove(pathname) != null) {
        _cachedList = null;
        _scheduleNotify();
        AppLogger.info(
          'File removed: $pathname',
          tag: 'FilesProvider',
        ); // coverage:ignore-line
      }
    } catch (e) {
      AppLogger.error(
        'Error removing file by path: $e',
        tag: 'FilesProvider',
      ); // coverage:ignore-line
    }
  }

  void clear() {
    if (_files.isEmpty) return;
    final count = _files.length;
    _files.clear();
    _cachedList = null;
    _scheduleNotify();
    AppLogger.info(
      '$count file(s) cleared',
      tag: 'FilesProvider',
    ); // coverage:ignore-line
  }

  Future<Object> shared({Offset? position}) async {
    try {
      final validFiles = xfiles;
      if (validFiles.isEmpty) {
        // Retorna key para ser resolvida na UI
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
      AppLogger.error(
        'Error sharing files: $e',
        tag: 'FilesProvider',
      ); // coverage:ignore-line
      return ShareResult('shareError', ShareResultStatus.unavailable);
    }
  }

  void _rescanInternal() {
    if (_files.isEmpty) return;
    final toRemove = <String>[];
    for (final entry in _files.entries) {
      if (!entry.value.isValidSync()) {
        toRemove.add(entry.key);
      }
    }
    if (toRemove.isEmpty) return;
    for (final k in toRemove) {
      _files.remove(k);
    }
    _cachedList = null;
    _scheduleNotify();
    AppLogger.info(
      // coverage:ignore-line
      '${toRemove.length} invalid file(s) removed after rescan',
      tag: 'FilesProvider',
    );
  }

  /// Utilitário para resolver mensagem de `ShareResult` retornada pelo provider.
  /// Se `rawMessage` corresponder a uma key interna ('shareNone' / 'shareError')
  /// retorna a string localizada; caso contrário devolve o próprio texto.
  static String resolveShareMessage(String rawMessage, AppLocalizations loc) {
    switch (rawMessage) {
      case 'shareNone':
        return loc.shareNone;
      case 'shareError':
        return loc.shareError;
      default:
        return rawMessage; // já é texto amigável ou desconhecido.
    }
  }

  void rescanNow() => _rescanInternal();

  // ---------------------------------------------------------------------------
  // Test helpers (não expostos em produção; anotados para visibilidade em tests)
  // ---------------------------------------------------------------------------
  @visibleForTesting
  void addFileForTest(FileReference ref) {
    _files[ref.pathname] = ref;
    _cachedList = null;
    _scheduleNotify();
  }
}
