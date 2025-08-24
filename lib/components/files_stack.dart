import 'dart:math' as math;
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class FilesStack extends StatelessWidget {
  final List<FileReference> droppedFiles;

  const FilesStack({super.key, required this.droppedFiles});

  @override
  Widget build(BuildContext context) {
    if (droppedFiles.isEmpty) {
      final loc = AppLocalizations.of(context)!;
      return Center(
        child: Text(
          loc.dropHere,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final iconSize =
            math.min(constraints.maxWidth, constraints.maxHeight) * 0.8;
        return RepaintBoundary(
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (final file in droppedFiles)
                SizedBox(
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
                ),
            ],
          ),
        );
      },
    );
  }
}
