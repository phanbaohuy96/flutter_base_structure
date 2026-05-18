import 'package:flutter/material.dart';

class AnimatedDropdownIcon extends StatefulWidget {
  final bool isExpanded;
  final Duration duration;
  final double size;
  final Color? color;

  const AnimatedDropdownIcon({
    super.key,
    this.isExpanded = false,
    this.duration = const Duration(milliseconds: 200),
    this.size = 24,
    this.color,
  });

  @override
  _AnimatedDropdownIconState createState() => _AnimatedDropdownIconState();
}

class _AnimatedDropdownIconState extends State<AnimatedDropdownIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.isExpanded ? 1 : 0,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1,
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedDropdownIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
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
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 3.14,
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: widget.size,
            color: widget.color,
          ),
        );
      },
    );
  }
}
