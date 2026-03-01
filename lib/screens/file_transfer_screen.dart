import 'package:easier_drop/components/drag_drop.dart';
import 'package:easier_drop/components/tray.dart';
import 'package:easier_drop/helpers/keyboard_shortcuts.dart';
import 'package:flutter/widgets.dart';

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
              if (testMode && testDragDrop != null)
                testDragDrop!
              else
                const DragDrop(),

              if (!testMode) const Tray(),
            ],
          ),
        ),
      ),
    );
  }
}
