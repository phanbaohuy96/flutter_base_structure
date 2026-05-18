import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool vibration;
  final bool automaticallyStart;

  const ShakeWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.vibration = true,
    this.automaticallyStart = false,
  }) : super(key: key);

  @override
  ShakeWidgetState createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 0), weight: 1),
    ]).animate(_controller);

    if (widget.automaticallyStart) {
      _controller.forward();
    }
  }

  Future vibrate() async {
    try {
      if ((await Vibration.hasAmplitudeControl()) == true) {
        return Vibration.vibrate(amplitude: 128);
      } else if ((await Vibration.hasVibrator()) == true) {
        return Vibration.vibrate(amplitude: 128);
      }
    } catch (_) {}
  }

  TickerFuture shake() {
    if (widget.vibration) {
      unawaited(vibrate());
    }
    return _controller.forward(from: 0); // Restart the animation
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0), // Apply horizontal shake
          child: widget.child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
