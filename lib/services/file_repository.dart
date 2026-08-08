import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:easier_drop/core/utils/result_handler.dart';
import 'package:easier_drop/helpers/macos/file_icon_helper.dart';
import 'package:easier_drop/services/analytics_service.dart';

class FileRepository {
  const FileRepository();

  Future<(bool?, Object?)> validateFile(String pathname) async {
    final (data, error) = await safeCall(() async {
      final stat = await File(pathname).stat();
      if (stat.type == FileSystemEntityType.directory) return true;
      if (stat.type == FileSystemEntityType.file) return false;
      throw Exception('Invalid entity type');
    });

    if (error != null) {
      AnalyticsService.instance.debug(
        'Error validating file: $pathname ($error)',
        tag: 'FileRepo',
      );
      return (null, error);
    }

    return (data, null);
  }

  bool validateFileSync(String pathname) {
    final (result, error) = safeCallSync<bool>(() {
      final stat = File(pathname).statSync();
      if (stat.type == FileSystemEntityType.directory) return true;
      if (stat.type == FileSystemEntityType.file) {
        return _testReadabilitySync(File(pathname));
      }
      return false;
    });
    
    if (error != null) return false;
    return result ?? false;
  }

  Future<Uint8List?> getIcon(String pathname) async {
    return FileIconHelper.getFileIcon(pathname);
  }

  Future<Uint8List?> getPreview(String pathname) async {
    return FileIconHelper.getFilePreview(pathname);
  }




  bool _testReadabilitySync(File file) {
    RandomAccessFile? raf;
    final (result, error) = safeCallSync<bool>(() {
      raf = file.openSync(mode: FileMode.read);
      return true;
    });

    safeCallSync(() => raf?.closeSync());

    if (error != null) return false;
    return result ?? false;
  }
}
