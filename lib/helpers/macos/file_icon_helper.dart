// ignore_for_file: avoid_print

import 'dart:collection';
import 'package:flutter/services.dart';
import 'package:easier_drop/services/constants.dart';
import 'package:easier_drop/services/logger.dart';

/// Helper responsável por buscar ícones de arquivos via canal nativo.
/// Agora utiliza um cache LRU (por extensão) para evitar crescimento ilimitado
/// de memória quando muitas extensões diferentes forem arrastadas.
class FileIconHelper {
  static const MethodChannel _channel = MethodChannel(
    PlatformChannels.fileIcon,
  );

  // Capacidade máxima de extensões armazenadas em cache.
  static const int _maxEntries = 128;

  // LinkedHashMap preserva ordem de inserção; ao acessar movemos para o fim.
  static final LinkedHashMap<String, Uint8List> _iconCache = LinkedHashMap();

  static Future<Uint8List?> getFileIcon(String filePath) async {
    try {
      final extension = _extractExtension(filePath);
      if (extension == null) return null;

      // Hit
      final existing = _iconCache.remove(extension);
      if (existing != null) {
        // Reinsere para marcar como mais recentemente usado.
        _iconCache[extension] = existing;
        return existing;
      }

      final Uint8List? iconData = await _channel.invokeMethod(
        'getFileIcon',
        filePath,
      );

      if (iconData != null) {
        _insert(extension, iconData);
      }
      return iconData;
    } catch (e) {
      AppLogger.error('Erro ao obter ícone: $e', tag: 'FileIconHelper');
      return null;
    }
  }

  static void _insert(String key, Uint8List value) {
    _iconCache[key] = value;
    if (_iconCache.length > _maxEntries) {
      // Remove o primeiro (menos recentemente usado).
      final firstKey = _iconCache.keys.first;
      _iconCache.remove(firstKey);
    }
  }

  static String? _extractExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) return null;
    return path.substring(dotIndex + 1).toLowerCase();
  }

  /// Apenas para debug / métricas.
  static int get cacheSize => _iconCache.length;
}
