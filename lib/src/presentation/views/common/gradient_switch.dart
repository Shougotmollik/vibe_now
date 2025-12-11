import 'package:flutter/material.dart';

/// Reusable GradientSwitch
class GradientSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Gradient activeGradient;
  final Color inactiveColor;
  final Gradient? thumbGradient;
  final double width;
  final double height;
  final Duration duration;
  final double padding;
  final bool disabled;

  const GradientSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeGradient,
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.thumbGradient,
    this.width = 38,
    this.height = 20,
    this.duration = const Duration(milliseconds: 200),
    this.padding = 0,
    this.disabled = false,
  });

  @override
  State<GradientSwitch> createState() => _GradientSwitchState();
}

class _GradientSwitchState extends State<GradientSwitch>
    with SingleTickerProviderStateMixin {
  // For subtle thumb scaling animation on tap
  late final AnimationController _tapController;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.disabled) return;
    widget.onChanged(!widget.value);
    // small tap animation
    _tapController.forward().then((_) => _tapController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final thumbSize = widget.height - 2 * widget.padding;
    final trackRadius = widget.height / 2;
    final thumbLeft = widget.padding;
    final thumbRight = widget.width - widget.padding - thumbSize;

    return Semantics(
      container: true,
      toggled: widget.value,
      enabled: !widget.disabled,
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.translucent,
        child: AnimatedContainer(
          duration: widget.duration,
          width: widget.width,
          height: widget.height,
          padding: EdgeInsets.all(widget.padding),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            // Use gradient when on, otherwise flat color
            gradient: widget.value && !widget.disabled
                ? widget.activeGradient
                : null,
            color: (!widget.value || widget.disabled)
                ? widget.inactiveColor
                : null,
            borderRadius: BorderRadius.circular(trackRadius),
            boxShadow: [
              // subtle elevation
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: widget.duration,
                left: widget.value ? thumbRight : thumbLeft,
                top: 0,
                bottom: 0,
                curve: Curves.easeInOut,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 0.96).animate(
                    CurvedAnimation(
                      parent: _tapController,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.thumbGradient,
                      color: widget.thumbGradient == null ? Colors.white : null,
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Optional disabled overlay
              if (widget.disabled)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(trackRadius),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
