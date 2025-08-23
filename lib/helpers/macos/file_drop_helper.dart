import 'package:flutter/services.dart';

/// Helper para operações de drag and drop de arquivos no macOS
class FileDropHelper {
  /// Canal de método para comunicação com o código nativo
  static const MethodChannel _channel = MethodChannel('file_drop_channel');

  /// Obtém o caminho do último arquivo solto
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
