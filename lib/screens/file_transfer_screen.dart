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
  /// Flag para habilitar o modo de teste, que não renderiza componentes que podem
  /// causar problemas em testes, como o Tray
  final bool testMode;

  // Componentes alternativos para o modo de teste
  final Widget? testDragDrop;

  const FileTransferScreen({
    super.key,
    this.testMode = false,
    this.testDragDrop,
  });

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
              // Usar o DragDrop de teste se estiver em modo de teste e fornecido
              if (testMode && testDragDrop != null)
                testDragDrop!
              else
                const DragDrop(),

              // Só renderiza o Tray quando não estiver em modo de teste
              if (!testMode) const Tray(),
            ],
          ),
        ),
      ),
    );
  }
}
