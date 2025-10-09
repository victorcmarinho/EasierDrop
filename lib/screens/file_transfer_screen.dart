import 'package:easier_drop/components/drag_drop.dart';
import 'package:easier_drop/components/tray.dart';
import 'package:easier_drop/helpers/keyboard_shortcuts.dart';
import 'package:flutter/widgets.dart';

/// Tela principal de transferência de arquivos
///
/// Combina os componentes de drag & drop e tray do sistema,
/// com suporte a atalhos de teclado e modo de teste.
class FileTransferScreen extends StatelessWidget {
  final bool testMode;
  final Widget? testDragDrop;

  const FileTransferScreen({
    super.key,
    this.testMode = false,
    this.testDragDrop,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: KeyboardShortcuts.shortcuts,
      child: Actions(
        actions: KeyboardShortcuts.createActions(context),
        child: Focus(
          autofocus: true,
          child: Stack(
            children: [
              // Componente principal de drag & drop
              if (testMode && testDragDrop != null)
                testDragDrop!
              else
                const DragDrop(),

              // Tray do sistema (apenas em modo normal)
              if (!testMode) const Tray(),
            ],
          ),
        ),
      ),
    );
  }
}
