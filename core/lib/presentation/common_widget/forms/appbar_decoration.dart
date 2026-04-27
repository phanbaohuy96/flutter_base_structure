import 'package:flutter/material.dart';

class BottomBorderDecoration extends Decoration {
  final bool showBottomBorder;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;

  const BottomBorderDecoration({
    required this.showBottomBorder,
    required this.borderColor,
    required this.borderWidth,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _BottomBorderPainter(
      showBottomBorder: showBottomBorder,
      borderColor: borderColor,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
    );
  }
}

class _BottomBorderPainter extends BoxPainter {
  final bool showBottomBorder;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;

  _BottomBorderPainter({
    required this.showBottomBorder,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    if (!showBottomBorder) {
      return;
    }

    final rect = offset & configuration.size!;

    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path();

    // Start from bottom-left corner (accounting for radius)
    if (borderRadius.bottomLeft.x > 0) {
      path
        ..moveTo(rect.left, rect.bottom - borderRadius.bottomLeft.y)
        ..arcToPoint(
          Offset(rect.left + borderRadius.bottomLeft.x, rect.bottom),
          radius: borderRadius.bottomLeft,
          clockwise: false,
        );
    } else {
      path.moveTo(rect.left, rect.bottom);
    }

    // Draw straight line across the bottom
    if (borderRadius.bottomRight.x > 0) {
      path
        ..lineTo(rect.right - borderRadius.bottomRight.x, rect.bottom)
        // Add bottom-right corner arc
        ..arcToPoint(
          Offset(rect.right, rect.bottom - borderRadius.bottomRight.y),
          radius: borderRadius.bottomRight,
          clockwise: false,
        );
    } else {
      path.lineTo(rect.right, rect.bottom);
    }

    canvas.drawPath(path, paint);
  }
}
