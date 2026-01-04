import 'package:easier_drop/components/parts/async_file_wrapper.dart';
import 'dart:math' as math;
import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter/material.dart';

class AnimatedFileIcon extends StatelessWidget {
  final FileReference file;
  final double size;
  final double rotationDegrees;
  final double dx;
  final double elevation;
  final Duration duration;
  final Curve curve;

  const AnimatedFileIcon({
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
    final image = _buildImage();

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
      child: AsyncFileWrapper(
        isProcessing: file.isProcessing,
        size: size,
        child: image,
      ),
    );
  }

  Widget _buildImage() {
    if (file.previewData != null) {
      return Image.memory(
        file.previewData!,
        gaplessPlayback: true,
        fit: BoxFit.contain,
      );
    }
    if (file.iconData != null) {
      return Image.memory(
        file.iconData!,
        gaplessPlayback: true,
        fit: BoxFit.contain,
      );
    }
    return Icon(
      Icons.insert_drive_file,
      size: size * 0.6,
      color: Colors.grey.shade500,
    );
  }
}
