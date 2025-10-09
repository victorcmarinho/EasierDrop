import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

class HoverIconButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final String? semanticsLabel;
  final String? semanticsHint;
  final double size;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final bool enabled;
  final bool addSemantics;
  final Color? baseColor;
  final Duration duration;

  const HoverIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.semanticsLabel,
    this.semanticsHint,
    this.size = 28,
    this.padding = const EdgeInsets.all(4),
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.enabled = true,
    this.addSemantics = true,
    this.baseColor,
    this.duration = const Duration(milliseconds: 110),
  });

  @override
  State<HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<HoverIconButton> {
  bool _hover = false;
  bool _pressed = false;

  void _setHover(bool v) => setState(() => _hover = v);
  void _setPressed(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final base = (widget.baseColor ?? theme.primaryColor).withValues(alpha: 1);
    final opacity =
        !widget.enabled
            ? 0.0
            : _pressed
            ? 0.24
            : _hover
            ? 0.14
            : 0.0;

    final content = AnimatedContainer(
      duration: widget.duration,
      curve: Curves.easeOut,
      height: widget.size,
      width: widget.size,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: base.withValues(alpha: opacity),
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: IconTheme(
          data: IconThemeData(
            size: (widget.size - widget.padding.horizontal) * 0.75,
          ),
          child: widget.icon,
        ),
      ),
    );

    Widget interactive = MouseRegion(
      cursor:
          widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => widget.enabled ? _setHover(true) : null,
      onExit: (_) {
        if (!widget.enabled) return;
        _setHover(false);
        _setPressed(false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
        onTapCancel: widget.enabled ? () => _setPressed(false) : null,
        onTapUp: widget.enabled ? (_) => _setPressed(false) : null,
        onTap: widget.enabled ? widget.onPressed : null,
        child: FocusableActionDetector(
          enabled: widget.enabled,
          mouseCursor:
              widget.enabled
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
          onShowHoverHighlight: (v) => widget.enabled ? _setHover(v) : null,
          child: content,
        ),
      ),
    );

    if (widget.addSemantics) {
      interactive = Semantics(
        label: widget.semanticsLabel,
        hint: widget.semanticsHint,
        button: true,
        enabled: widget.enabled,
        child: interactive,
      );
    }
    return interactive;
  }
}
