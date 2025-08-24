import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:window_manager/window_manager.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

class WindowHandle extends StatefulWidget {
  const WindowHandle({
    super.key,
    this.height = 8,
    this.gestureHeight = 28,
    this.idleWidth = 35,
    this.activeWidth = 65,
  });

  final double height;
  final double gestureHeight;
  final double idleWidth;
  final double activeWidth;

  @override
  State<WindowHandle> createState() => _WindowHandleState();
}

class _WindowHandleState extends State<WindowHandle> {
  bool _pressed = false;
  bool _hover = false;

  void _reset() => mounted ? setState(() => _pressed = false) : null;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: widget.gestureHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (_) async {
          setState(() => _pressed = true);
          await windowManager.startDragging();
        },
        onPanEnd: (_) => _reset(),
        onPanCancel: _reset,
        child: Center(
          child: MouseRegion(
            cursor:
                _pressed
                    ? SystemMouseCursors.grabbing
                    : SystemMouseCursors.grab,
            onEnter: (_) => setState(() => _hover = true),
            onExit: (_) => setState(() => _hover = false),
            child: Semantics(
              label: AppLocalizations.of(context)?.semHandleLabel ?? 'Window handle',
              hint: AppLocalizations.of(context)?.semHandleHint ?? 'Drag to move the window',
              button: true,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOutQuad,
                width: _pressed ? widget.activeWidth : widget.idleWidth,
                height: widget.height,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(
                    alpha: _hover ? 0.55 : 0,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
