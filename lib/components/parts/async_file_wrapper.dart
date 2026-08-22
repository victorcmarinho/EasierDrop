import 'package:material_ui/material_ui.dart';

class AsyncFileWrapper extends StatefulWidget {
  final Widget child;
  final bool isProcessing;
  final bool isSuccess;
  final double size;

  const AsyncFileWrapper({
    super.key,
    required this.child,
    required this.isProcessing,
    this.isSuccess = false,
    required this.size,
  });

  @override
  State<AsyncFileWrapper> createState() => _AsyncFileWrapperState();
}

class _AsyncFileWrapperState extends State<AsyncFileWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: widget.isProcessing ? _buildShimmer() : widget.child,
              ),

              if (!widget.isProcessing) _buildSuccessGlow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return _NativeShimmer(
      child: Container(
        width: widget.size * 0.8,
        height: widget.size * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.size * 0.1),
        ),
      ),
    );
  }

  Widget _buildSuccessGlow() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        if (value >= 1.0) return const SizedBox.shrink();
        return Container(
          width: widget.size * 1.2 * value,
          height: widget.size * 1.2 * value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.blue.withValues(alpha: (1 - value).clamp(0.0, 1.0)),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}

class _NativeShimmer extends StatefulWidget {
  final Widget child;
  const _NativeShimmer({required this.child});

  @override
  State<_NativeShimmer> createState() => _NativeShimmerState();
}

class _NativeShimmerState extends State<_NativeShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              stops: const [0.1, 0.3, 0.4],
              colors: [
                Colors.grey.withValues(alpha: 0.2),
                Colors.grey.withValues(alpha: 0.08),
                Colors.grey.withValues(alpha: 0.2),
              ],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0.0,
      0.0,
    );
  }
}

