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

// Textos migraram para AppLocalizations (ver l10n/app_localizations.dart)

/// Flags de comportamento (poderiam futuramente vir de prefs).
// FeatureFlags migrou para SettingsService (ver settings_service.dart)
