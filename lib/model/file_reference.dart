import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:easier_drop/helpers/macos/file_icon_helper.dart';

class FileReference {
  final Uint8List? iconData;
  final String pathname;
  bool? _exists;
  FileSystemEntityType? _type;

  FileReference({this.iconData, required this.pathname});

  static final Map<String, Uint8List> _iconCache = {};

  /// Verifica se o arquivo existe de forma assíncrona
  Future<bool> get existsAsync async {
    _exists ??= await File(pathname).exists();
    return _exists!;
  }

  /// Retorna o nome do arquivo sem o caminho
  String get fileName => pathname.split(Platform.pathSeparator).last;

  /// Retorna a extensão do arquivo
  String get extension => pathname.split('.').last.toLowerCase();

  /// Retorna o tamanho do arquivo em bytes
  Future<int> get size async => File(pathname).length();

  /// Cache do ícone do arquivo por extensão
  static Future<Uint8List?> getCachedIcon(
    String extension,
    String pathname,
  ) async {
    if (!_iconCache.containsKey(extension)) {
      final icon = await FileIconHelper.getFileIcon(pathname);
      if (icon != null) {
        _iconCache[extension] = icon;
      }
    }
    return _iconCache[extension];
  }

  /// Verifica se o arquivo é válido de forma assíncrona
  Future<bool> isValidAsync() async {
    try {
      if (!await existsAsync) return false;

      _type ??= (await File(pathname).stat()).type;
      return _type == FileSystemEntityType.file;
    } catch (e) {
      debugPrint('Erro ao validar arquivo: $e');
      return false;
    }
  }

  /// Mantido por compatibilidade, mas preferir usar isValidAsync
  bool isValid() {
    try {
      _exists = File(pathname).existsSync();
      return _exists! &&
          File(pathname).statSync().type == FileSystemEntityType.file;
    } catch (e) {
      debugPrint('Erro ao validar arquivo: $e');
      return false;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileReference && other.pathname == pathname;
  }

  @override
  int get hashCode => pathname.hashCode;

  @override
  String toString() => 'FileReference(pathname: $pathname)';
}
