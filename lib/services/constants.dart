import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:easier_drop/services/logger.dart';

/// Constantes centrais de canais de plataforma e métodos usados.
class PlatformChannels {
  static const String fileDrop = 'file_drop_channel';
  static const String fileDropEvents = 'file_drop_channel/events';
  static const String fileIcon = 'file_icon_channel';
  static const String fileDragOut = 'file_drag_out_channel';

  // Métodos canal file_drop
  static const String startMonitor = 'startDropMonitor';
  static const String stopMonitor = 'stopDropMonitor';
  static const String beginDrag = 'beginDrag';
  static const String fileDroppedCallback = 'fileDropped';
}

/// Textos (temporário, até i18n). Centralizar evita literais espalhados.
class AppTexts {
  static const dropHere = 'Jogue os arquivos aqui';
  static const dragOutNone = 'Nenhum arquivo para arrastar.';
  static const share = 'Compartilhar';
  static const removeAll = 'Remover arquivos';
  static const undo = 'Desfazer';
  static const close = 'Fechar';
  static const keptOnCopy = 'Mantido por cópia';
}

/// Flags de comportamento (poderiam futuramente vir de prefs).
class FeatureFlags {
  /// Limpa automaticamente após drag IN (entrada). Padrão true mantendo legado.
  static bool autoClearInbound = true;

  static bool _loaded = false;
  static const _fileName = 'settings.json';
  static const _kAutoClearInbound = 'autoClearInbound';

  static Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      final file = await _file();
      if (await file.exists()) {
        final data =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        if (data.containsKey(_kAutoClearInbound)) {
          autoClearInbound = data[_kAutoClearInbound] == true;
        }
      }
      _loaded = true;
    } catch (e) {
      AppLogger.warn('Falha ao carregar settings: $e');
    }
  }

  static Future<void> persist() async {
    try {
      final file = await _file();
      final map = <String, dynamic>{_kAutoClearInbound: autoClearInbound};
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(map));
    } catch (e) {
      AppLogger.warn('Falha ao salvar settings: $e');
    }
  }

  static Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, _fileName));
  }
}
