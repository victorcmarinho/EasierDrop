import 'package:flutter/cupertino.dart';
import 'package:easier_drop/l10n/app_localizations.dart';

class MacCloseButton extends StatefulWidget {
  const MacCloseButton({
    super.key,
    required this.onPressed,
    this.diameter = 14,
  });

  final VoidCallback onPressed;
  final double diameter;

  @override
  State<MacCloseButton> createState() => _MacCloseButtonState();
}

class _MacCloseButtonState extends State<MacCloseButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final size = widget.diameter;
    const baseColor = Color(0xFFFF5F57);
    const hoverBorder = Color(0xFFCE534B);
    const hoverIcon = Color(0xFF4D0000);

    Widget circle = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: baseColor,
        border: Border.all(
          color: _hover ? hoverBorder : baseColor.withValues(alpha: 0.9),
          width: 1,
        ),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _hover ? 1 : 0,
        child: Center(
          child: SizedBox(
            width: size * 0.55,
            height: size * 0.55,
            child: CustomPaint(
              painter: _CloseCrossPainter(
                color: hoverIcon,
                strokeWidth: (size / 14) * 1.2,
              ),
            ),
          ),
        ),
      ),
    );

    if (_pressed) {
      circle = Transform.scale(scale: 0.9, child: circle);
    }

    return Semantics(
      label: loc.close,
      hint: loc.close,
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit:
            (_) => setState(() {
              _hover = false;
              _pressed = false;
            }),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onPressed,
          child: Padding(padding: const EdgeInsets.all(4), child: circle),
        ),
      ),
    );
  }
}

class _CloseCrossPainter extends CustomPainter {
  _CloseCrossPainter({required this.color, required this.strokeWidth});
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
    final offset = strokeWidth;
    final p1 = Offset(offset, offset);
    final p2 = Offset(size.width - offset, size.height - offset);
    final p3 = Offset(size.width - offset, offset);
    final p4 = Offset(offset, size.height - offset);
    canvas.drawLine(p1, p2, paint);
    canvas.drawLine(p3, p4, paint);
  }

  @override
  bool shouldRepaint(covariant _CloseCrossPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
