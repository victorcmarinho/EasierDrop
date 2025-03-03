import 'dart:async';
import 'dart:io';

import 'package:easier_drop/components/drop_hit.dart';
import 'package:easier_drop/components/files_stack.dart';
import 'package:easier_drop/components/remove_button.dart';
import 'package:easier_drop/helpers/macos/file_icon_macos.dart';
import 'package:easier_drop/model/x_file.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:super_clipboard/src/reader.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class DragDrop extends StatefulWidget {
  const DragDrop({super.key});

  @override
  State<DragDrop> createState() => _DragDropState();
}

class _DragDropState extends State<DragDrop> {
  final Set<XFile> _droppedFiles = {};

  Future<void> _onPerformDrop(PerformDropEvent event) async {
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
    _addToDroppedFiles(uriList);
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

  _addToDroppedFiles(List<String> uriList) async {
    final newFiles = await Future.wait(
      uriList
          .where((item) {
            if (_droppedFiles.isEmpty) return true;
            return !_droppedFiles.any((file) => file.pathname == item);
          })
          .map((file) async {
            final icon = await FileIconHelper.getFileIcon(file);
            return XFile(iconData: icon, pathname: file, file: File(file));
          }),
    );

    setState(() {
      _droppedFiles.addAll(newFiles);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasFiles = _droppedFiles.isNotEmpty;

    return DropRegion(
      formats: [Formats.fileUri],
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: (event) {
        if (event.session.allowedOperations.contains(DropOperation.link)) {
          return DropOperation.link;
        }
        return DropOperation.none;
      },
      onPerformDrop: (event) => _onPerformDrop(event),
      child: Stack(
        alignment: Alignment.center,
        children: [
          hasFiles
              ? FilesStack(droppedFiles: _droppedFiles.toList())
              : DropHit(),
          if (hasFiles)
            RemoveButton(
              onPressed:
                  () => setState(() {
                    _droppedFiles.clear();
                  }),
            ),
        ],
      ),
    );
  }
}
