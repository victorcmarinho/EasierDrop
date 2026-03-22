import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:easier_drop/helpers/macos/file_icon_helper.dart';
import 'package:easier_drop/services/analytics_service.dart';

class FileRepository {
  const FileRepository();

  Future<bool> validateFile(String pathname) async {
    try {
      final stat = await File(pathname).stat();
      return stat.type == FileSystemEntityType.file;
    } catch (e) {
      AnalyticsService.instance.debug(
        'Error validating file: $pathname ($e)',
        tag: 'FileRepo',
      );
      return false;
    }
  }

  bool validateFileSync(String pathname) {
    try {
      final file = File(pathname);
      if (!file.existsSync()) return false;
      if (file.statSync().type != FileSystemEntityType.file) return false;

      return _testReadabilitySync(file);
    } catch (_) {
      return false;
    }
  }

  Future<Uint8List?> getIcon(String pathname) async {
    return FileIconHelper.getFileIcon(pathname);
  }

  Future<Uint8List?> getPreview(String pathname) async {
    return FileIconHelper.getFilePreview(pathname);
  }




  bool _testReadabilitySync(File file) {
    RandomAccessFile? raf;
    try {
      raf = file.openSync(mode: FileMode.read);
      return true;
    } catch (e) {
      return false;
    } finally {
      try {
        raf?.closeSync();
      } catch (_) {}
    }
  }
}
