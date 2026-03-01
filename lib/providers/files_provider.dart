import 'dart:async';
import 'package:easier_drop/services/analytics_service.dart';

import 'package:easier_drop/helpers/app_constants.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/services/file_repository.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easier_drop/services/file_thumbnail_service.dart';

class FilesProvider with ChangeNotifier {
  final int? _maxFilesOverride;
  final FileRepository _repository;
  final FileThumbnailService _thumbnailService;
  final Map<String, FileReference> _files = {};

  List<FileReference>? _cachedFilesList;
  List<XFile>? _cachedXFiles;
  DateTime? _lastLimitHit;
  Timer? _monitorTimer;
  bool _notifyScheduled = false;

  FilesProvider({
    FileRepository repository = const FileRepository(),
    FileThumbnailService? thumbnailService,
    bool enableMonitoring = true,
    int? maxFiles,
  }) : _repository = repository,
       _thumbnailService = thumbnailService ?? FileThumbnailService(repository),
       _maxFilesOverride = maxFiles {
    if (enableMonitoring) {
      _monitorTimer = Timer.periodic(
        AppConstants.monitorInterval,
        (_) => _rescanInternal(),
      );
    }
  }

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
    AnalyticsService.instance.debug(
      'files getter called. Map size: ${_files.length}, List size: ${list.length}',
      tag: 'FilesProvider',
    );
    return list;
  }

  List<XFile> get validXFiles {
    if (_cachedXFiles != null) return _cachedXFiles!;

    _cachedXFiles = _files.values
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

  Future<void> addFile(FileReference file) async {
    await addFiles([file]);
  }

  Future<void> addFiles(Iterable<FileReference> files) async {
    if (files.isEmpty) return;

    try {
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
        _thumbnailService.loadThumbnails(
          pathname: file.pathname,
          getCurrentFile: () => _files[file.pathname],
          onUpdate: (updated) {
            if (_files.containsKey(updated.pathname)) {
              _files[updated.pathname] = updated;
              _invalidateCache();
              _scheduleNotify();
            }
          },
        );
        AnalyticsService.instance.fileAdded(
          extension: file.fileName.split('.').lastOrNull,
        );
      }

      if (filesToAdd.isNotEmpty) {
        AnalyticsService.instance.info(
          'Batch added: ${filesToAdd.length} files',
          tag: 'FilesProvider',
        );
        _invalidateCache();
        notifyListeners();
      }
    } catch (e) {
      AnalyticsService.instance.error(
        'Error adding files: $e',
        tag: 'FilesProvider',
      );
    }
  }

  void _handleLimitReached() {
    _lastLimitHit = DateTime.now();
    AnalyticsService.instance.warn(
      'File limit reached ($_maxFiles)',
      tag: 'FilesProvider',
    );
    AnalyticsService.instance.fileLimitReached();
    _scheduleNotify();
  }

  Future<void> removeFile(FileReference file) async {
    if (_files.remove(file.pathname) != null) {
      _invalidateCache();
      _scheduleNotify();
      AnalyticsService.instance.fileRemoved(
        extension: file.fileName.split('.').lastOrNull,
      );
      AnalyticsService.instance.info(
        'File removed: ${file.fileName}',
        tag: 'FilesProvider',
      );
    }
  }

  void removeByPath(String pathname) {
    if (_files.remove(pathname) != null) {
      _invalidateCache();
      _scheduleNotify();
      AnalyticsService.instance.fileRemoved(
        extension: pathname.split('.').lastOrNull,
      );
      AnalyticsService.instance.fileDroppedOut();
      AnalyticsService.instance.info(
        'File removed: $pathname',
        tag: 'FilesProvider',
      );
    }
  }

  void clear() {
    if (_files.isEmpty) return;
    final count = _files.length;
    _files.clear();
    _invalidateCache();
    _scheduleNotify();
    AnalyticsService.instance.fileDroppedOut();
    AnalyticsService.instance.info(
      '$count file(s) cleared',
      tag: 'FilesProvider',
    );
  }

  Future<Object> shared({Offset? position}) async {
    try {
      final validFilesList = validXFiles;
      if (validFilesList.isEmpty) {
        return ShareResult('shareNone', ShareResultStatus.unavailable);
      }

      final params = ShareParams(
        files: validFilesList,
        sharePositionOrigin: position != null
            ? Rect.fromLTWH(
                position.dx,
                position.dy,
                AppConstants.shareOriginSize,
                AppConstants.shareOriginSize,
              )
            : null,
      );

      final result = await SharePlus.instance.share(params);
      AnalyticsService.instance.fileShared(count: validFilesList.length);
      return result;
    } catch (e) {
      AnalyticsService.instance.error(
        'Error sharing files: $e',
        tag: 'FilesProvider',
      );
      return ShareResult('shareError', ShareResultStatus.unavailable);
    }
  }

  void _rescanInternal() {
    if (_files.isEmpty) return;

    final toRemove = _files.entries
        .where((entry) => !_repository.validateFileSync(entry.value.pathname))
        .map((entry) => entry.key)
        .toList();

    if (toRemove.isEmpty) return;

    for (final key in toRemove) {
      _files.remove(key);
    }

    _invalidateCache();
    _scheduleNotify();
    AnalyticsService.instance.info(
      '${toRemove.length} invalid file(s) removed after rescan',
      tag: 'FilesProvider',
    );
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
