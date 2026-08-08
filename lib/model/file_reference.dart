import 'dart:io';
import 'package:flutter/foundation.dart';

@immutable
class FileReference {
  final String pathname;
  final Uint8List? iconData;
  final Uint8List? previewData;
  final bool isProcessing;
  final bool isFolder;

  const FileReference({
    required this.pathname,
    this.iconData,
    this.previewData,
    this.isProcessing = false,
    this.isFolder = false,
  });

  String get fileName => pathname.split(Platform.pathSeparator).last;

  String get extension {
    final base = fileName;
    final dotIndex = base.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == base.length - 1) {
      return base.toLowerCase();
    }
    return base.substring(dotIndex + 1).toLowerCase();
  }

  FileReference withIcon(Uint8List? icon) => FileReference(
    pathname: pathname,
    iconData: icon,
    previewData: previewData,
    isProcessing: isProcessing,
    isFolder: isFolder,
  );

  FileReference withPreview(Uint8List? preview) => FileReference(
    pathname: pathname,
    iconData: iconData,
    previewData: preview,
    isProcessing: isProcessing,
    isFolder: isFolder,
  );

  FileReference withProcessing(bool processing) => FileReference(
    pathname: pathname,
    iconData: iconData,
    previewData: previewData,
    isProcessing: processing,
    isFolder: isFolder,
  );

  FileReference withIsFolder(bool folder) => FileReference(
    pathname: pathname,
    iconData: iconData,
    previewData: previewData,
    isProcessing: isProcessing,
    isFolder: folder,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileReference && other.pathname == pathname);

  @override
  int get hashCode => pathname.hashCode;

  @override
  String toString() =>
      'FileReference(pathname: $pathname, isFolder: $isFolder, hasIcon: ${iconData != null}, hasPreview: ${previewData != null})';
}
