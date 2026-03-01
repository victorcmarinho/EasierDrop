import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:easier_drop/services/window_manager_service.dart';

class ClearAllIntent extends Intent {
  const ClearAllIntent();
}

class ShareIntent extends Intent {
  const ShareIntent();
}

class PasteFilesIntent extends Intent {
  const PasteFilesIntent();
}

class PreferencesIntent extends Intent {
  const PreferencesIntent();
}

class KeyboardShortcuts {
  static final Map<LogicalKeySet, Intent> shortcuts = {
    LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.backspace):
        const ClearAllIntent(),
    LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.delete):
        const ClearAllIntent(),

    LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.comma):
        const PreferencesIntent(),

    LogicalKeySet(
      LogicalKeyboardKey.meta,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.keyC,
    ): const ShareIntent(),
    LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.enter):
        const ShareIntent(),

    LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyV):
        const PasteFilesIntent(),
  };

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
      PasteFilesIntent: CallbackAction<PasteFilesIntent>(
        onInvoke: (intent) async {
          final files = await Pasteboard.files();
          if (files.isNotEmpty && context.mounted) {
            final provider = context.read<FilesProvider>();
            final fileRefs = files.map((path) => FileReference(pathname: path));
            await provider.addFiles(fileRefs);
          }
          return null;
        },
      ),
      PreferencesIntent: CallbackAction<PreferencesIntent>(
        onInvoke: (intent) async {
          await WindowManagerService.instance.openSettings();
          return null;
        },
      ),
    };
  }
}
