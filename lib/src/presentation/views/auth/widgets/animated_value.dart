import 'package:flutter/material.dart';

class AnimateOption {
  final int delay;
  final int duration;
  final double begin;
  final double end;
  final Curve curve;

  const AnimateOption({
    required this.delay,
    required this.duration,
    required this.begin,
    required this.end,
    this.curve = Curves.easeOut,
  });
}

class AnimatedValue extends StatefulWidget {
  final Widget? child;
  final AnimateOption option;
  final Widget Function(BuildContext, double) builder;

  const AnimatedValue({
    super.key,
    this.child,
    required this.option,
    required this.builder,
  });

  @override
  State<AnimatedValue> createState() => _AnimatedValueState();
}

class _AnimatedValueState extends State<AnimatedValue>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.option.duration),
    );

    _animation = Tween<double>(
      begin: widget.option.begin,
      end: widget.option.end,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.option.curve));

    // Auto-start animation after delay
    Future.delayed(
      Duration(milliseconds: widget.option.delay),
      () => _controller.forward(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => widget.builder(context, _animation.value),
      child: widget.child,
    );
  }
}

double remap({
  required double value,
  double fromBegin = 1,
  double fromEnd = -1,
  required double toBegin,
  required double toEnd,
}) {
  final progress = (value - fromBegin) / (fromEnd - fromBegin);
  return toBegin + progress * (toEnd - toBegin);
}
