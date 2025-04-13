import 'package:flutter/material.dart';

class SwipeDetector extends StatelessWidget {
  final Widget child;
  final Function? onSwipeLeft;
  final Function? onSwipeRight;
  final double velocity;

  SwipeDetector({
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.velocity = 100,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      onHorizontalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) < 0 - velocity) {
          //swipe left
          onSwipeLeft?.call();
        } else if ((details.primaryVelocity ?? 0) > velocity) {
          // swipe right
          onSwipeRight?.call();
        }
      },
    );
  }
}
