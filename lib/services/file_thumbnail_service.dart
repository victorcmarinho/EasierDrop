import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/services/file_repository.dart';

class FileThumbnailService {
  final FileRepository _repository;

  FileThumbnailService(this._repository);

  Future<void> loadThumbnails({
    required String pathname,
    required FileReference? Function() getCurrentFile,
    required void Function(FileReference updatedFile) onUpdate,
  }) async {
    try {
      await Future.wait([
        _loadFileIcon(pathname, getCurrentFile, onUpdate),
        _loadFilePreview(pathname, getCurrentFile, onUpdate),
      ]);
    } finally {
      final current = getCurrentFile();
      if (current != null && current.isProcessing) {
        onUpdate(current.withProcessing(false));
      }
    }
  }

  Future<void> _loadFileIcon(
    String pathname,
    FileReference? Function() getCurrentFile,
    void Function(FileReference updatedFile) onUpdate,
  ) async {
    final iconData = await _repository.getIcon(pathname);
    if (iconData != null) {
      final current = getCurrentFile();
      if (current != null && current.iconData == null) {
        onUpdate(current.withIcon(iconData));
      }
    }
  }

  Future<void> _loadFilePreview(
    String pathname,
    FileReference? Function() getCurrentFile,
    void Function(FileReference updatedFile) onUpdate,
  ) async {
    final previewData = await _repository.getPreview(pathname);
    if (previewData != null) {
      final current = getCurrentFile();
      if (current != null && current.previewData == null) {
        onUpdate(current.withPreview(previewData));
      }
    }
  }
}
