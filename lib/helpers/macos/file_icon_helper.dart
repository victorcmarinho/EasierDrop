import 'dart:collection';
import 'package:flutter/services.dart';
import 'package:easier_drop/services/constants.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/core/utils/result_handler.dart';

class FileIconHelper {
  static const MethodChannel _channel = MethodChannel(
    PlatformChannels.fileIcon,
  );

  static const int _maxEntries = 128;

  static final LinkedHashMap<String, Uint8List> _iconCache = LinkedHashMap();

  static Future<Uint8List?> getFileIcon(String filePath) async {
    final (result, error) = await safeCall<Uint8List?>(() async {
      final extension = _extractExtension(filePath);
      if (extension == null) return null;

      final existing = _iconCache.remove(extension);
      if (existing != null) {
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
    });

    if (error != null) {
      AnalyticsService.instance.error(
        'Erro ao obter ícone: $error',
        tag: 'FileIconHelper',
      );
      return null;
    }

    return result;
  }

  static Future<Uint8List?> getFilePreview(String filePath) async {
    final (result, error) = await safeCall<Uint8List?>(
      () => _channel.invokeMethod('getFilePreview', filePath)
    );

    if (error != null) {
      AnalyticsService.instance.error(
        'Erro ao obter preview: $error',
        tag: 'FileIconHelper',
      );
      return null;
    }
    
    return result;
  }

  static void _insert(String key, Uint8List value) {
    _iconCache[key] = value;
    if (_iconCache.length > _maxEntries) {
      final firstKey = _iconCache.keys.first;
      _iconCache.remove(firstKey);
    }
  }

  static String? _extractExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) return null;
    return path.substring(dotIndex + 1).toLowerCase();
  }

  static void debugClearCache() {
    _iconCache.clear();
  }
}
