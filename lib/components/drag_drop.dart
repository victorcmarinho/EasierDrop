import 'dart:async';
import 'package:easier_drop/components/drop_hit.dart';
import 'package:easier_drop/components/files_stack.dart';
import 'package:easier_drop/components/remove_button.dart';
import 'package:easier_drop/components/share_button.dart';
import 'package:easier_drop/helpers/macos/file_icon_macos.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_clipboard/super_clipboard.dart' show DataReader;
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class DragDrop extends StatefulWidget {
  const DragDrop({super.key});

  @override
  State<DragDrop> createState() => _DragDropState();
}

class _DragDropState extends State<DragDrop> {
  final GlobalKey _buttonKey = GlobalKey();

  Future<void> _onPerformDrop(
    PerformDropEvent event,
    void Function(List<FileReference>) addAllFiles,
  ) async {
    final uriList = await Future.wait(
      event.session.items.map((item) async {
        final reader = item.dataReader;
        if (reader != null && reader.canProvide(Formats.fileUri)) {
          return _getUri(reader);
        }
        return null;
      }),
    );

    final validUris = uriList.whereType<String>().toList();
    if (validUris.isNotEmpty) {
      _addToDroppedFiles(validUris, addAllFiles);
    }
  }

  Future<String?> _getUri(DataReader reader) {
    final completer = Completer<String?>();
    reader.getValue<Uri>(
      Formats.fileUri,
      (value) => completer.complete(value?.toFilePath(windows: false)),
      onError: (_) => completer.complete(null),
    );
    return completer.future;
  }

  Future<void> _addToDroppedFiles(
    List<String> uriList,
    void Function(List<FileReference>) addAllFiles,
  ) async {
    final newFiles = await Future.wait(
      uriList.map((file) async {
        final icon = await FileIconHelper.getFileIcon(file);
        return FileReference(iconData: icon, pathname: file);
      }),
    );

    addAllFiles(newFiles);
  }

  Offset? _getButtonPosition() {
    final RenderBox? renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero);
  }

  Widget _buildAnimatedButton({required bool visible, required Widget child}) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: visible ? 1.0 : 0.0,
      child: visible ? child : const SizedBox(width: 40, height: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filesProvider = context.watch<FilesProvider>();
    final hasFiles = filesProvider.files.isNotEmpty;

    return DropRegion(
      formats: [Formats.fileUri],
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver:
          (event) =>
              event.session.allowedOperations.contains(DropOperation.link)
                  ? DropOperation.link
                  : DropOperation.none,
      onPerformDrop:
          (event) => _onPerformDrop(event, filesProvider.addAllFiles),
      child: Stack(
        alignment: Alignment.center,
        children: [
          hasFiles
              ? FilesStack(droppedFiles: filesProvider.files)
              : const DropHit(),

          Positioned(
            right: 0,
            top: 0,
            child: _buildAnimatedButton(
              visible: hasFiles,
              child: ShareButton(
                key: _buttonKey,
                onPressed:
                    () => filesProvider.shared(position: _getButtonPosition()),
              ),
            ),
          ),

          Positioned(
            right: 0,
            bottom: 0,
            child: _buildAnimatedButton(
              visible: hasFiles,
              child: RemoveButton(onPressed: filesProvider.clear),
            ),
          ),
        ],
      ),
    );
  }
}
