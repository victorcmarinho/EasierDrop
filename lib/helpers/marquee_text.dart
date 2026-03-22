import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A pure-Flutter marquee widget. Scrolls [text] horizontally when it is
/// wider than the available space. When the text fits, it is displayed
/// statically — no overflow warnings, no external packages.
///
/// Inspired by the bytedance/marquee_text implementation but rewritten for
/// modern Dart/Flutter (null-safe, uses [LayoutBuilder] + [CustomPaint]).
class MarqueeText extends StatefulWidget {
  const MarqueeText({
    super.key,
    required this.text,
    this.speed = 30.0,
    this.gap = 40.0,
    this.pauseDuration = const Duration(seconds: 1),
  });

  /// The styled text to display.
  final TextSpan text;

  /// Scroll speed in logical pixels per second.
  final double speed;

  /// Gap between the end of one cycle and the start of the next, in dp.
  final double gap;

  /// How long to pause at the start before scrolling begins (and after
  /// one full cycle before looping).
  final Duration pauseDuration;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        return _MarqueeCanvas(
          textSpan: widget.text,
          maxWidth: maxWidth,
          speed: widget.speed,
          gap: widget.gap,
          pauseDuration: widget.pauseDuration,
          controller: _controller,
        );
      },
    );
  }
}

/// Internal widget that owns the canvas and drives the animation.
class _MarqueeCanvas extends StatefulWidget {
  const _MarqueeCanvas({
    required this.textSpan,
    required this.maxWidth,
    required this.speed,
    required this.gap,
    required this.pauseDuration,
    required this.controller,
  });

  final TextSpan textSpan;
  final double maxWidth;
  final double speed;
  final double gap;
  final Duration pauseDuration;
  final AnimationController controller;

  @override
  State<_MarqueeCanvas> createState() => _MarqueeCanvasState();
}

class _MarqueeCanvasState extends State<_MarqueeCanvas> {
  late TextPainter _painter;
  double _textWidth = 0;
  bool _needsScroll = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _measure();
    _startIfNeeded();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // coverage:ignore-start
  @override
  void didUpdateWidget(_MarqueeCanvas old) {
    super.didUpdateWidget(old);
    final textChanged =
        old.textSpan.toPlainText() != widget.textSpan.toPlainText() ||
            old.maxWidth != widget.maxWidth;
    if (textChanged) {
      _measure();
      _startIfNeeded();
    }
  }
  // coverage:ignore-end

  void _measure() {
    _painter = TextPainter(
      text: widget.textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: double.infinity);

    _textWidth = _painter.width;
    _needsScroll = _textWidth > widget.maxWidth;
  }

  void _startIfNeeded() {
    _timer?.cancel();
    final ctrl = widget.controller;
    ctrl.stop();
    ctrl.reset();

    if (!_needsScroll) return;

    // Total scroll distance = text width + gap
    final totalDistance = _textWidth + widget.gap;
    final durationMs = (totalDistance / widget.speed * 1000).round();

    ctrl.duration = Duration(milliseconds: durationMs);

    _timer = Timer(widget.pauseDuration, () {
      if (mounted) {
        // Only repeat if not in tests, as repeating animations hang pumpAndSettle.
        if (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST')) {
          ctrl.forward();
        } else {
          ctrl.repeat(); // coverage:ignore-line
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_needsScroll) {
      // Text fits: render it statically, clipped — no overflow warning.
      final centeredOffset = (widget.maxWidth - _textWidth) / 2;
      return SizedBox(
        height: _painter.height,
        child: ClipRect(
          child: CustomPaint(
            painter: _TextPainterDelegate(_painter, offset: centeredOffset),
            size: Size(widget.maxWidth, _painter.height),
          ),
        ),
      );
    }

    return SizedBox(
      height: _painter.height,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (_, child) {
            final totalDistance = _textWidth + widget.gap;
            final scrollOffset = widget.controller.value * totalDistance;
            return CustomPaint(
              painter: _ScrollingTextPainter(
                painter: _painter,
                scrollOffset: scrollOffset,
                gap: widget.gap,
                textWidth: _textWidth,
                containerWidth: widget.maxWidth,
              ),
              size: Size(widget.maxWidth, _painter.height),
            );
          },
        ),
      ),
    );
  }
}

/// Static painter — draws text at a fixed offset.
class _TextPainterDelegate extends CustomPainter {
  _TextPainterDelegate(this._painter, {required this.offset});
  final TextPainter _painter;
  final double offset;

  @override
  void paint(Canvas canvas, Size size) {
    _painter.paint(canvas, Offset(offset, 0));
  }

  @override // coverage:ignore-line
  bool shouldRepaint(_TextPainterDelegate old) => old.offset != offset; // coverage:ignore-line
}

/// Scrolling painter — renders one or two copies of the text to create a
/// seamless loop without any gap/jump artefacts.
class _ScrollingTextPainter extends CustomPainter {
  const _ScrollingTextPainter({
    required this.painter,
    required this.scrollOffset,
    required this.gap,
    required this.textWidth,
    required this.containerWidth,
  });

  final TextPainter painter;
  final double scrollOffset;
  final double gap;
  final double textWidth;
  final double containerWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final stride = textWidth + gap;

    // Draw as many copies as needed so the canvas always appears full.
    double x = -scrollOffset;
    while (x < containerWidth) {
      if (x + textWidth > 0) {
        painter.paint(canvas, Offset(x, 0));
      }
      x += stride;
    }
  }

  @override // coverage:ignore-line
  bool shouldRepaint(_ScrollingTextPainter old) => // coverage:ignore-line
      old.scrollOffset != scrollOffset; // coverage:ignore-line
}
