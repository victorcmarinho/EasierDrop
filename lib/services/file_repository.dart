import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:easier_drop/helpers/macos/file_icon_helper.dart';
import 'package:easier_drop/services/logger.dart';

class FileRepository {
  const FileRepository();

  Future<bool> validateFile(String pathname) async {
    try {
      final file = File(pathname);
      if (!await file.exists()) return false;

      final stat = await file.stat();
      if (stat.type != FileSystemEntityType.file) return false;

      return await _testReadability(file);
    } catch (e) {
      AppLogger.debug('Error validating file: $pathname ($e)', tag: 'FileRepo');
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

  Future<bool> _testReadability(File file) async {
    RandomAccessFile? raf;
    try {
      raf = await file.open(mode: FileMode.read);
      await raf.readByte();
      return true;
    } on FileSystemException catch (e) {
      AppLogger.warn(
        'No read permission: ${file.path} (${e.osError?.message})',
        tag: 'FileRepo',
      );
      return false;
    } catch (e) {
      AppLogger.warn(
        'Failed readability test: ${file.path} ($e)',
        tag: 'FileRepo',
      );
      return false;
    } finally {
      await raf?.close();
    }
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
