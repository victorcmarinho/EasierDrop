import 'dart:io';
import 'package:flutter/foundation.dart';

/// Representa uma referência imutável a um arquivo no sistema
@immutable
class FileReference {
  final String pathname;
  final Uint8List? iconData;
  final Uint8List? previewData;

  const FileReference({
    required this.pathname,
    this.iconData,
    this.previewData,
  });

  /// Nome do arquivo (sem o caminho)
  String get fileName => pathname.split(Platform.pathSeparator).last;

  /// Extensão do arquivo em minúsculas
  String get extension {
    final base = fileName;
    final dotIndex = base.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == base.length - 1) {
      return base.toLowerCase();
    }
    return base.substring(dotIndex + 1).toLowerCase();
  }

  /// Cria uma nova instância com ícone atualizado
  FileReference withIcon(Uint8List? icon) => FileReference(
    pathname: pathname,
    iconData: icon,
    previewData: previewData,
  );

  /// Cria uma nova instância com preview atualizado
  FileReference withPreview(Uint8List? preview) => FileReference(
    pathname: pathname,
    iconData: iconData,
    previewData: preview,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileReference && other.pathname == pathname);

  @override
  int get hashCode => pathname.hashCode;

  @override
  String toString() =>
      'FileReference(pathname: $pathname, hasIcon: ${iconData != null}, hasPreview: ${previewData != null})';
}
