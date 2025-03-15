import 'package:flutter/services.dart';

class FileDropHelper {
  static const MethodChannel _channel = MethodChannel('file_drop_channel');

  static Future<String?> getPath() async {
    try {
      final String? path = await _channel.invokeMethod('getDroppedPath');
      return path;
    } catch (e) {
      print("Erro ao obter path: $e");
      return null;
    }
  }
}
