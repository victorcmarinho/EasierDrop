import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class FilesStack extends StatelessWidget {
  final List<FileReference> droppedFiles;

  const FilesStack({super.key, required this.droppedFiles});

  @override
  Widget build(BuildContext context) {
    if (droppedFiles.isEmpty) {
      return const Center(
        child: Text(
          'Arraste os arquivos para cá',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final iconSize =
            math.min(constraints.maxWidth, constraints.maxHeight) * 0.8;
        return Stack(
          alignment: Alignment.center,
          children:
              droppedFiles.map((file) {
                return SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child:
                      file.iconData != null
                          ? Image.memory(
                            file.iconData!,
                            gaplessPlayback: true,
                            fit: BoxFit.contain,
                          )
                          : Icon(
                            Icons.insert_drive_file,
                            size: iconSize * 0.6,
                            color: Colors.grey,
                          ),
                );
              }).toList(),
        );
      },
    );
  }
}
