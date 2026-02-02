import 'package:flutter/material.dart';

class AnimationConfig {
  static bool _enabled = true;
  static double _speedMultiplier = 1.0;

  static bool get enabled => _enabled;
  static set enabled(bool value) => _enabled = value;

  static double get speedMultiplier => _speedMultiplier;
  static set speedMultiplier(double value) {
    assert(value > 0, 'Speed multiplier must be greater than 0');
    _speedMultiplier = value;
  }

  static void reset() {
    _enabled = true;
    _speedMultiplier = 1.0;
  }
}

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

  int get adjustedDuration =>
      (duration / AnimationConfig.speedMultiplier).round();

  int get adjustedDelay => (delay / AnimationConfig.speedMultiplier).round();
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
      duration: Duration(milliseconds: widget.option.adjustedDuration),
    );

    _animation = Tween<double>(
      begin: widget.option.begin,
      end: widget.option.end,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.option.curve));

    if (AnimationConfig.enabled) {
      Future.delayed(Duration(milliseconds: widget.option.adjustedDelay), () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.value = 1.0;
    }
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
