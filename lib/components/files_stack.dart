import 'dart:math' as math;
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/helpers/app_constants.dart';
import 'package:flutter/material.dart';
import 'parts/animated_file_icon.dart';

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
    return AnimatedSwitcher(
      duration: animationDuration,
      child:
          droppedFiles.isEmpty
              ? _buildEmptyState(context)
              : _buildStack(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      key: const ValueKey('empty_state'),
      child: Text(
        loc.dropHere,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildStack(BuildContext context) {
    return LayoutBuilder(
      key: const ValueKey('files_stack'),
      builder: (context, constraints) {
        final maxSide = math.min(constraints.maxWidth, constraints.maxHeight);
        final iconSize = maxSide * AppConstants.stackSizeMultiplier;
        final visible =
            droppedFiles.take(AppConstants.stackMaxVisible).toList();
        final count = visible.length;
        final spread = math.min(AppConstants.stackSpreadBase, maxSide * 0.12);

        return RepaintBoundary(
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 0; i < count; i++)
                AnimatedFileIcon(
                  key: ValueKey(visible[i].pathname),
                  file: visible[i],
                  size: iconSize,
                  rotationDegrees: count == 1 ? 0 : _rotationForIndex(i),
                  dx: count == 1 ? 0 : _offsetForIndex(i, count, spread),
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
    return (i - 2) * AppConstants.stackRotationBase;
  }

  double _offsetForIndex(int i, int len, double spread) {
    if (len == 1) return 0;
    final norm = (i / (len - 1)) - 0.5;
    return norm * spread;
  }
}
