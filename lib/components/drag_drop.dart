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
// ignore: implementation_imports
import 'package:super_clipboard/src/reader.dart';
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
    Function(List<FileReference>) addAllFiles,
  ) async {
    final uriList = <String>[];
    for (final item in event.session.items) {
      final reader = item.dataReader!;
      if (reader.canProvide(Formats.fileUri)) {
        final uri = (await _getUri(reader));
        if (uri != null) {
          uriList.add(uri);
        }
      }
    }
    _addToDroppedFiles(uriList, addAllFiles);
  }

  Future<String?> _getUri(DataReader reader) {
    final completer = Completer<String?>();
    reader.getValue<Uri>(
      Formats.fileUri,
      (value) {
        completer.complete(value?.toFilePath(windows: false));
      },
      onError: (error) {
        completer.complete(null);
      },
    );
    return completer.future;
  }

  _addToDroppedFiles(
    List<String> uriList,
    Function(List<FileReference>) addAllFiles,
  ) async {
    final newFiles = await Future.wait(
      uriList.map((file) async {
        final icon = await FileIconHelper.getFileIcon(file);
        return FileReference(iconData: icon, pathname: file);
      }),
    );

    addAllFiles(newFiles);
  }

  @override
  Widget build(BuildContext context) {
    final files = context.watch<FilesProvider>().files;
    final hasFiles = files.isNotEmpty;
    final addAllFiles = context.watch<FilesProvider>().addAllFiles;
    final shared = context.watch<FilesProvider>().shared;

    final RenderBox? renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    final Offset? position = renderBox?.localToGlobal(Offset.zero);

    return DropRegion(
      formats: [Formats.fileUri],
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: (event) {
        if (event.session.allowedOperations.contains(DropOperation.link)) {
          return DropOperation.link;
        }
        return DropOperation.none;
      },
      onPerformDrop: (event) => _onPerformDrop(event, addAllFiles),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 0,
            top: 0,

            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: hasFiles ? 1.0 : 0.0,
              child: ShareButton(
                key: _buttonKey,
                onPressed: () {
                  shared(position: position);
                },
              ),
            ),
          ),

          hasFiles ? FilesStack(droppedFiles: files) : DropHit(),
          Positioned(
            right: 0,
            bottom: 0,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: hasFiles ? 1.0 : 0.0,
              child: RemoveButton(
                onPressed: () => context.read<FilesProvider>().clear(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
