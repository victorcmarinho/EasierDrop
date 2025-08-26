import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

/// Anima texto horizontalmente (marquee) quando excede o espaço disponível.
class MarqueeText extends StatefulWidget {
  const MarqueeText({super.key, required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double? _textWidth;
  double? _availableWidth;
  static const double _gap = 32.0;
  static const double _pps = 22.0;

  bool get _shouldScroll =>
      _textWidth != null &&
      _availableWidth != null &&
      _textWidth! > _availableWidth!;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
  }

  void _measure() {
    final renderBox = context.findRenderObject();
    if (renderBox is RenderBox) {
      _availableWidth = renderBox.size.width;
    }
    final tp = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    _textWidth = tp.width;

    if (_shouldScroll) {
      final distance = _textWidth! + _gap;
      final seconds = distance / _pps;
      _controller.duration = Duration(milliseconds: (seconds * 1000).round());
      if (!_controller.isAnimating) {
        _controller.repeat();
      } else {
        _controller.reset();
        _controller.repeat();
      }
    } else {
      _controller.stop();
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldScroll) {
      return Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
        overflow: TextOverflow.clip,
        textAlign: TextAlign.center,
      );
    }

    final text = Text(widget.text, style: widget.style, maxLines: 1);

    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final dx = _controller.value * (_textWidth! + _gap);

          final moving = Transform.translate(
            offset: Offset(-dx, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [text, const SizedBox(width: _gap), text],
              ),
            ),
          );

          return ShaderMask(
            shaderCallback: (rect) {
              const fadePortion = 0.12;
              return const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  MacosColors.transparent,
                  MacosColors.white,
                  MacosColors.white,
                  MacosColors.transparent,
                ],
                stops: [0.0, fadePortion, 1 - fadePortion, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: moving,
          );
        },
      ),
    );
  }
}
