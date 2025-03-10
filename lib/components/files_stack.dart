import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class FilesStack extends StatelessWidget {
  final List<FileReference> droppedFiles;

  const FilesStack({super.key, required this.droppedFiles});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DragItemWidget(
        canAddItemToExistingSession: true,
        allowedOperations: () => [...DropOperation.values],
        dragBuilder: (context, child) => Opacity(opacity: 0.8, child: child),
        dragItemProvider: (request) {
          final item = DragItem();
          return item;
        },
        child: DraggableWidget(
          child: Stack(
            children:
                droppedFiles.take(5).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  final angle = (index * 0.1).clamp(0.0, 0.3);

                  return Transform.rotate(
                    angle: angle,
                    child: Image.memory(file.iconData!),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
