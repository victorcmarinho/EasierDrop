import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:text_marquee/text_marquee.dart';

class FileNameBadge extends StatelessWidget {
  const FileNameBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 110,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: MacosTheme.of(
                context,
              ).primaryColor.withValues(alpha: 0.30),
              width: 1,
            ),
            color: MacosTheme.of(context).primaryColor.withValues(alpha: 0.15),
          ),
          child: TextMarquee(
            label,
            style: MacosTheme.of(
              context,
            ).typography.caption1.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
