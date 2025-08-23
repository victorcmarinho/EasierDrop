import 'dart:io';

import 'package:flutter/foundation.dart';

class FileReference {
  final Uint8List? iconData;
  final String pathname;

  const FileReference({this.iconData, required this.pathname});

  /// Verifica se o arquivo existe
  bool get exists => File(pathname).existsSync();

  /// Retorna o nome do arquivo sem o caminho
  String get fileName => pathname.split(Platform.pathSeparator).last;

  /// Retorna a extensão do arquivo
  String get extension => pathname.split('.').last.toLowerCase();

  /// Retorna o tamanho do arquivo em bytes
  Future<int> get size async => File(pathname).length();

  /// Verifica se o arquivo é válido
  bool isValid() {
    try {
      return exists &&
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
