// ignore_for_file: avoid_print

import 'package:flutter/services.dart';

class FileIconHelper {
  static const MethodChannel _channel = MethodChannel('file_icon_channel');
  static final Map<String, Uint8List> _iconCache = {};

  static Future<Uint8List?> getFileIcon(String filePath) async {
    try {
      final extension = filePath.split('.').last.toLowerCase();

      if (_iconCache.containsKey(extension)) {
        return _iconCache[extension];
      }

      final Uint8List? iconData = await _channel.invokeMethod(
        'getFileIcon',
        filePath,
      );

      if (iconData != null) {
        _iconCache[extension] = iconData;
      }

      return iconData;
    } catch (e) {
      print("Erro ao obter ícone: $e");
      return null;
    }
  }
}
