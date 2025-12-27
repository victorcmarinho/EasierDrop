import 'dart:math' as math;
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class FilesStack extends StatelessWidget {
  final List<FileReference> droppedFiles;
  final Duration animationDuration;
  final Curve curve;

  const FilesStack({
    super.key,
    required this.droppedFiles,
    this.animationDuration = const Duration(milliseconds: 260),
    this.curve = Curves.easeOutCubic,
  });

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
        final maxSide = math.min(constraints.maxWidth, constraints.maxHeight);
        final iconSize = maxSide * 0.78;
        final count = droppedFiles.length;
        final visible = droppedFiles.take(6).toList();
        final spread = math.min(14.0, maxSide * 0.12);

        return RepaintBoundary(
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 0; i < visible.length; i++)
                _AnimatedFileIcon(
                  key: ValueKey(visible[i].pathname),
                  file: visible[i],
                  size: iconSize,
                  rotationDegrees: count == 1 ? 0 : _rotationForIndex(i),
                  dx:
                      count == 1
                          ? 0
                          : _offsetForIndex(i, visible.length, spread),
                  elevation: i.toDouble(),
                  duration: animationDuration,
                  curve: curve,
                ),
            ],
          ),
        );
      },
    );
  }

  double _rotationForIndex(int i) {
    const base = 3.0;
    return (i - 2) * base;
  }

  double _offsetForIndex(int i, int len, double spread) {
    if (len == 1) return 0;
    final norm = (i / (len - 1)) - 0.5;
    return norm * spread;
  }
}

class _AnimatedFileIcon extends StatelessWidget {
  final FileReference file;
  final double size;
  final double rotationDegrees;
  final double dx;
  final double elevation;
  final Duration duration;
  final Curve curve;

  const _AnimatedFileIcon({
    super.key,
    required this.file,
    required this.size,
    required this.rotationDegrees,
    required this.dx,
    required this.elevation,
    required this.duration,
    required this.curve,
  });

  @override
  Widget build(BuildContext context) {
    final radians = rotationDegrees * math.pi / 180;
    final image =
        file.previewData != null
            ? Image.memory(
              file.previewData!,
              gaplessPlayback: true,
              fit: BoxFit.contain,
            )
            : file.iconData != null
            ? Image.memory(
              file.iconData!,
              gaplessPlayback: true,
              fit: BoxFit.contain,
            )
            : Icon(
              Icons.insert_drive_file,
              size: size * 0.6,
              color: Colors.grey.shade500,
            );

    return AnimatedContainer(
      duration: duration,
      curve: curve,
      transform:
          (Matrix4.identity()
            ..setTranslationRaw(dx, -elevation * 2.0, 0)
            ..rotateZ(radians)),
      transformAlignment: Alignment.center,
      width: size,
      height: size,
      child: AnimatedOpacity(
        duration: duration,
        curve: curve,
        opacity: 1,
        child: image,
      ),
    );
  }
}
