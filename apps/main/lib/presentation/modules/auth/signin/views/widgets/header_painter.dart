// ignore_for_file: cascade_invocations

import 'package:flutter/material.dart';

class LoginHeaderPainter extends CustomPainter {
  final double height;
  final Color color;
  final double radius;

  LoginHeaderPainter({
    required this.height,
    required this.color,
    this.radius = 24,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    final topOffset = size.height - height;

    // Move to top-left corner with radius
    path.moveTo(0, radius + topOffset);
    path.quadraticBezierTo(0, topOffset, radius, topOffset);

    // Top side with right curve
    path.lineTo(size.width - radius, topOffset);
    path.quadraticBezierTo(
      size.width,
      topOffset,
      size.width,
      radius + topOffset,
    );

    // Right side
    path.lineTo(size.width, size.height);

    // Bottom side
    path.lineTo(0, size.height);

    // Left side
    path.lineTo(0, radius);

    // Draw the path
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant LoginHeaderPainter oldDelegate) {
    return oldDelegate.height != height;
  }
}
