import 'dart:io';
import 'package:flutter/foundation.dart';

/// Representa um arquivo no shelf. Imutável.
class FileReference {
  final Uint8List? iconData;
  final String pathname;
  const FileReference({this.iconData, required this.pathname});

  String get fileName => pathname.split(Platform.pathSeparator).last;
  String get extension => pathname.split('.').last.toLowerCase();
  Future<int> get size async => File(pathname).length();

  Future<bool> isValidAsync() async {
    try {
      final exists = await File(pathname).exists();
      if (!exists) return false;
      final type = (await File(pathname).stat()).type;
      return type == FileSystemEntityType.file;
    } catch (e) {
      debugPrint('Erro ao validar arquivo: $e');
      return false;
    }
  }

  bool isValidSync() {
    try {
      final file = File(pathname);
      return file.existsSync() &&
          file.statSync().type == FileSystemEntityType.file;
    } catch (_) {
      return false;
    }
  }

  FileReference withIcon(Uint8List? icon) =>
      FileReference(pathname: pathname, iconData: icon);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileReference && other.pathname == pathname);
  @override
  int get hashCode => pathname.hashCode;
  @override
  String toString() => 'FileReference(pathname: $pathname)';
}
