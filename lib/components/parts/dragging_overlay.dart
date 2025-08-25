import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

class DraggingOverlay extends StatelessWidget {
  const DraggingOverlay({super.key, required this.visible});
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final theme = MacosTheme.of(context);
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: 0.9,
          duration: const Duration(milliseconds: 120),
          child: Container(
            decoration: BoxDecoration(
              color: theme.canvasColor.withValues(alpha: 0.85),
              border: Border.all(color: theme.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
