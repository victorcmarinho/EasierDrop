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
  static const close = 'Fechar';
  static const keptOnCopy = 'Mantido por cópia';
}

/// Flags de comportamento (poderiam futuramente vir de prefs).
// FeatureFlags migrou para SettingsService (ver settings_service.dart)
