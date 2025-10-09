import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:easier_drop/providers/files_provider.dart';

/// Intents para ações globais da aplicação
class ClearAllIntent extends Intent {
  const ClearAllIntent();
}

class ShareIntent extends Intent {
  const ShareIntent();
}

/// Configuração centralizada de atalhos de teclado
class KeyboardShortcuts {
  /// Mapa de atalhos de teclado padrão da aplicação
  static final Map<LogicalKeySet, Intent> shortcuts = {
    // Limpar arquivos: Cmd+Backspace ou Cmd+Delete
    LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.backspace):
        const ClearAllIntent(),
    LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.delete):
        const ClearAllIntent(),

    // Compartilhar: Cmd+Shift+C ou Cmd+Enter
    LogicalKeySet(
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyC,
        ):
        const ShareIntent(),
    LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.enter):
        const ShareIntent(),
  };

  /// Actions para as intents
  static Map<Type, Action<Intent>> createActions(BuildContext context) {
    return {
      ClearAllIntent: CallbackAction<ClearAllIntent>(
        onInvoke: (intent) {
          final provider = context.read<FilesProvider>();
          if (provider.hasFiles) {
            provider.clear();
          }
          return null;
        },
      ),
      ShareIntent: CallbackAction<ShareIntent>(
        onInvoke: (intent) {
          final provider = context.read<FilesProvider>();
          provider.shared();
          return null;
        },
      ),
    };
  }
}
