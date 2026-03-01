import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
    return Shimmer.fromColors(
      baseColor: Colors.grey.withAlpha(50),
      highlightColor: Colors.grey.withAlpha(20),
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
              color: Colors.blue.withAlpha((255 * (1 - value)).toInt()),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}
