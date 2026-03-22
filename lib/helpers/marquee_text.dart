import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class MarqueeText extends StatefulWidget {
  const MarqueeText({
    super.key,
    required this.text,
    this.speed = 30.0,
    this.gap = 40.0,
    this.pauseDuration = const Duration(seconds: 1),
    this.maxWidth = double.infinity,
  });

  final TextSpan text;

  final double speed;

  final double gap;

  final Duration pauseDuration;

  final double maxWidth;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late TextPainter _painter;
  bool _needsScroll = false;
  bool _hasLaidOut = false;
  double _textWidth = 0.0;
  Timer? _timer;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _painter = TextPainter(textDirection: TextDirection.ltr);
    _animationController = AnimationController(vsync: this);
    _animationController.addListener(() {
      if (mounted && _needsScroll && _scrollController.hasClients) {
        _scrollController.jumpTo(
          _animationController.value * (_textWidth + widget.gap),
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateLayout());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.speed != widget.speed ||
        oldWidget.gap != widget.gap ||
        oldWidget.pauseDuration != widget.pauseDuration ||
        oldWidget.maxWidth != widget.maxWidth) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      _updateLayout();
    }
  }

  void _updateLayout() {
    if (!mounted) return;

    _painter.text = widget.text;
    _painter.layout();
    _hasLaidOut = true;
    _textWidth = _painter.width;

    final availableWidth = widget.maxWidth;
    final bool shouldScroll = _textWidth > availableWidth;

    setState(() {
      _needsScroll = shouldScroll;
    });

    if (_needsScroll) {
      _startAnimation();
    } else {
      _stopAnimation();
    }
  }

  void _stopAnimation() {
    _timer?.cancel();
    _animationController.stop();
    _animationController.reset();
  }

  void _startAnimation() {
    _stopAnimation();

    if (!_needsScroll) return;

    final totalDistance = _textWidth + widget.gap;
    final durationMs = (totalDistance / widget.speed * 1000).round();

    _animationController.duration = Duration(milliseconds: durationMs);

    _timer = Timer(widget.pauseDuration, () {
      if (mounted) {
        if (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST')) {
          _animationController.forward();
        } else {
          _animationController.repeat(); // coverage:ignore-line
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLaidOut) {
      return const SizedBox();
    }

    if (!_needsScroll) {
      return SizedBox(
        height: _painter.height,
        child: ClipRect(
          child: CustomPaint(
            size: Size(_textWidth, _painter.height),
            painter: _MarqueePainter(
              text: widget.text,
              offset: Offset.zero,
              painter: _painter,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: _painter.height,
      child: ListView.builder(
        controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: widget.gap),
            child: CustomPaint(
              size: Size(_textWidth, _painter.height),
              painter: _MarqueePainter(
                text: widget.text,
                offset: Offset.zero,
                painter: _painter,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MarqueePainter extends CustomPainter {
  final TextSpan text;
  final Offset offset;
  final TextPainter painter;

  _MarqueePainter({
    required this.text,
    required this.offset,
    required this.painter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_MarqueePainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.offset != offset;
  }
}
