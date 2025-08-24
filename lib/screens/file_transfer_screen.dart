import 'package:easier_drop/components/drag_drop.dart';
import 'package:easier_drop/components/tray.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ClearFilesIntent extends Intent {
  const ClearFilesIntent();
}

class ShareFilesIntent extends Intent {
  const ShareFilesIntent();
}

class FileTransferScreen extends StatelessWidget {
  const FileTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final filesProvider = context.read<FilesProvider>();

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.backspace):
            const ClearFilesIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.delete):
            const ClearFilesIntent(),
        LogicalKeySet(
              LogicalKeyboardKey.meta,
              LogicalKeyboardKey.shift,
              LogicalKeyboardKey.keyC,
            ):
            const ShareFilesIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.enter):
            const ShareFilesIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ClearFilesIntent: CallbackAction<ClearFilesIntent>(
            onInvoke: (intent) {
              if (filesProvider.files.isEmpty) return null;
              filesProvider.clear();
              return null;
            },
          ),
          ShareFilesIntent: CallbackAction<ShareFilesIntent>(
            onInvoke: (intent) {
              filesProvider.shared();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Stack(
            children: [
              Row(children: const [Expanded(child: DragDrop())]),
              const Tray(),
            ],
          ),
        ),
      ),
    );
  }
}
