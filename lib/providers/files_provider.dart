import 'dart:async';
import 'package:easier_drop/helpers/macos/file_icon_helper.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/services/logger.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

class FilesProvider with ChangeNotifier {
  final Map<String, FileReference> _files = {};
  int get _maxFiles => SettingsService.instance.maxFiles;
  DateTime? _lastLimitHit;
  DateTime? get lastLimitHit => _lastLimitHit;
  bool get recentlyAtLimit =>
      _lastLimitHit != null &&
      DateTime.now().difference(_lastLimitHit!) < const Duration(seconds: 2);

  Timer? _monitorTimer;
  static const Duration _monitorInterval = Duration(seconds: 5);
  bool _monitoringEnabled = true;

  List<FileReference> get files => _files.values.toList(growable: false);

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
          'Limite de arquivos atingido ($_maxFiles)',
          tag: 'FilesProvider',
        );
        _scheduleNotify();
        return;
      }
      if (!await file.isValidAsync()) {
        AppLogger.debug(
          'Arquivo inválido: ${file.pathname}',
          tag: 'FilesProvider',
        );
        return;
      }
      if (_files.containsKey(file.pathname)) {
        AppLogger.debug(
          'Arquivo já existe: ${file.pathname}',
          tag: 'FilesProvider',
        );
        return;
      }

      _files[file.pathname] = file;
      _scheduleNotify();

      final iconData = await FileIconHelper.getFileIcon(file.pathname);
      if (iconData != null) {
        final current = _files[file.pathname];
        if (current != null && current.iconData == null) {
          _files[file.pathname] = current.withIcon(iconData);
          _scheduleNotify();
        }
      }
      AppLogger.info(
        'Arquivo adicionado: ${file.fileName}',
        tag: 'FilesProvider',
      );
    } catch (e) {
      AppLogger.error('Erro ao adicionar arquivo: $e', tag: 'FilesProvider');
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
        _scheduleNotify();
        AppLogger.info(
          'Arquivo removido: ${file.fileName}',
          tag: 'FilesProvider',
        );
      }
    } catch (e) {
      AppLogger.error('Erro ao remover arquivo: $e', tag: 'FilesProvider');
    }
  }

  void removeByPath(String pathname) {
    try {
      if (_files.remove(pathname) != null) {
        _scheduleNotify();
        AppLogger.info('Arquivo removido: $pathname', tag: 'FilesProvider');
      }
    } catch (e) {
      AppLogger.error(
        'Erro ao remover arquivo por path: $e',
        tag: 'FilesProvider',
      );
    }
  }

  void clear() {
    if (_files.isEmpty) return;
    final count = _files.length;
    _files.clear();
    _scheduleNotify();
    AppLogger.info('$count arquivos removidos', tag: 'FilesProvider');
  }

  Future<Object> shared({Offset? position}) async {
    try {
      final validFiles = xfiles;
      if (validFiles.isEmpty) {
        return ShareResult(
          'Sem arquivos para compartilhar',
          ShareResultStatus.unavailable,
        );
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
        'Erro ao compartilhar arquivos: $e',
        tag: 'FilesProvider',
      );
      return ShareResult(
        'Erro ao compartilhar arquivos',
        ShareResultStatus.unavailable,
      );
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
    _scheduleNotify();
    AppLogger.info(
      '${toRemove.length} arquivo(s) removidos após rescan',
      tag: 'FilesProvider',
    );
  }

  void rescanNow() => _rescanInternal();
}
