// ignore_for_file: avoid_print

import 'package:flutter/services.dart';

class FileIconHelper {
  static const MethodChannel _channel = MethodChannel('file_icon_helper');

  static Future<Uint8List?> getFileIcon(String filePath) async {
    try {
      final Uint8List? iconData = await _channel.invokeMethod(
        'getFileIcon',
        filePath,
      );
      return iconData;
    } catch (e) {
      print("Erro ao obter ícone: $e");
      return null;
    }
  }
}
