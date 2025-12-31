import 'dart:async';
import 'package:easier_drop/helpers/app_constants.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/services/file_repository.dart';
import 'package:easier_drop/services/logger.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

/// Provider responsável pelo gerenciamento de arquivos no aplicativo.
class FilesProvider with ChangeNotifier {
  final int? _maxFilesOverride;
  final FileRepository _repository;
  final Map<String, FileReference> _files = {};

  List<FileReference>? _cachedFilesList;
  List<XFile>? _cachedXFiles;
  DateTime? _lastLimitHit;
  Timer? _monitorTimer;
  bool _notifyScheduled = false;

  FilesProvider({
    FileRepository repository = const FileRepository(),
    bool enableMonitoring = true,
    int? maxFiles,
  }) : _repository = repository,
       _maxFilesOverride = maxFiles {
    if (enableMonitoring) {
      _monitorTimer = Timer.periodic(
        AppConstants.monitorInterval,
        (_) => _rescanInternal(),
      );
    }
  }

  // Getters públicos
  int get _maxFiles => _maxFilesOverride ?? SettingsService.instance.maxFiles;
  DateTime? get lastLimitHit => _lastLimitHit;
  bool get isEmpty => _files.isEmpty;
  bool get hasFiles => _files.isNotEmpty;
  int get fileCount => _files.length;

  bool get recentlyAtLimit =>
      _lastLimitHit != null &&
      DateTime.now().difference(_lastLimitHit!) <
          AppConstants.limitNotificationDuration;

  List<FileReference> get files {
    final list = _cachedFilesList ??= List.unmodifiable(_files.values);
    AppLogger.debug(
      'files getter called. Map size: ${_files.length}, List size: ${list.length}',
      tag: 'FilesProvider',
    );
    return list;
  }

  List<XFile> get validXFiles {
    if (_cachedXFiles != null) return _cachedXFiles!;

    _cachedXFiles =
        _files.values
            .where((file) => _repository.validateFileSync(file.pathname))
            .map((file) => XFile(file.pathname))
            .toList();
    return _cachedXFiles!;
  }

  void _scheduleNotify() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    scheduleMicrotask(() {
      _notifyScheduled = false;
      notifyListeners();
    });
  }

  void _invalidateCache() {
    _cachedFilesList = null;
    _cachedXFiles = null;
  }

  /// Adiciona um arquivo ao provider
  Future<void> addFile(FileReference file) async {
    try {
      if (_files.length >= _maxFiles) {
        _handleLimitReached();
        return;
      }

      if (!await _repository.validateFile(file.pathname)) {
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

      _files[file.pathname] = file.withProcessing(true);
      _invalidateCache();
      _scheduleNotify();

      // Carrega thumbnails em background
      _loadFileThumbnails(file.pathname);

      AppLogger.info('File added: ${file.fileName}', tag: 'FilesProvider');
    } catch (e) {
      AppLogger.error('Error adding file: $e', tag: 'FilesProvider');
    }
  }

  Future<void> _loadFileThumbnails(String pathname) async {
    try {
      await Future.wait([_loadFileIcon(pathname), _loadFilePreview(pathname)]);
    } finally {
      if (_files.containsKey(pathname)) {
        _files[pathname] = _files[pathname]!.withProcessing(false);
        _invalidateCache();
        _scheduleNotify();
      }
    }
  }

  Future<void> _loadFileIcon(String pathname) async {
    final iconData = await _repository.getIcon(pathname);
    if (iconData != null && _files.containsKey(pathname)) {
      final current = _files[pathname]!;
      if (current.iconData == null) {
        _files[pathname] = current.withIcon(iconData);
        _invalidateCache();
        _scheduleNotify();
      }
    }
  }

  Future<void> _loadFilePreview(String pathname) async {
    final previewData = await _repository.getPreview(pathname);
    if (previewData != null && _files.containsKey(pathname)) {
      final current = _files[pathname]!;
      if (current.previewData == null) {
        _files[pathname] = current.withPreview(previewData);
        _invalidateCache();
        _scheduleNotify();
      }
    }
  }

  Future<void> addFiles(Iterable<FileReference> files) async {
    if (files.isEmpty) return;

    final validated = await Future.wait(
      files.map((f) async {
        if (_files.containsKey(f.pathname)) return null;
        return await _repository.validateFile(f.pathname) ? f : null;
      }),
    );

    final validFiles = validated.whereType<FileReference>().toList();
    if (validFiles.isEmpty) return;

    final availableSlots = _maxFiles - _files.length;
    if (availableSlots <= 0) {
      _handleLimitReached();
      return;
    }

    final filesToAdd = validFiles.take(availableSlots).toList();
    if (validFiles.length > availableSlots) _handleLimitReached();

    for (final file in filesToAdd) {
      _files[file.pathname] = file.withProcessing(true);
      _loadFileThumbnails(file.pathname);
    }

    if (filesToAdd.isNotEmpty) {
      AppLogger.info(
        'Batch added: ${filesToAdd.length} files',
        tag: 'FilesProvider',
      );
      _invalidateCache();
      notifyListeners();
    }
  }

  void _handleLimitReached() {
    _lastLimitHit = DateTime.now();
    AppLogger.warn('File limit reached ($_maxFiles)', tag: 'FilesProvider');
    _scheduleNotify();
  }

  Future<void> removeFile(FileReference file) async {
    if (_files.remove(file.pathname) != null) {
      _invalidateCache();
      _scheduleNotify();
      AppLogger.info('File removed: ${file.fileName}', tag: 'FilesProvider');
    }
  }

  void removeByPath(String pathname) {
    if (_files.remove(pathname) != null) {
      _invalidateCache();
      _scheduleNotify();
      AppLogger.info('File removed: $pathname', tag: 'FilesProvider');
    }
  }

  void clear() {
    if (_files.isEmpty) return;
    final count = _files.length;
    _files.clear();
    _invalidateCache();
    _scheduleNotify();
    AppLogger.info('$count file(s) cleared', tag: 'FilesProvider');
  }

  Future<Object> shared({Offset? position}) async {
    try {
      final validFilesList = validXFiles;
      if (validFilesList.isEmpty) {
        return ShareResult('shareNone', ShareResultStatus.unavailable);
      }

      final params = ShareParams(
        files: validFilesList,
        sharePositionOrigin:
            position != null
                ? Rect.fromLTWH(
                  position.dx,
                  position.dy,
                  AppConstants.shareOriginSize,
                  AppConstants.shareOriginSize,
                )
                : null,
      );

      return SharePlus.instance.share(params);
    } catch (e) {
      AppLogger.error('Error sharing files: $e', tag: 'FilesProvider');
      return ShareResult('shareError', ShareResultStatus.unavailable);
    }
  }

  void _rescanInternal() {
    if (_files.isEmpty) return;

    final toRemove =
        _files.entries
            .where(
              (entry) => !_repository.validateFileSync(entry.value.pathname),
            )
            .map((entry) => entry.key)
            .toList();

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
