import 'dart:math';

import 'package:flutter/painting.dart';

class ReceiptShapeBorder extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;

  ReceiptShapeBorder({
    required this.borderColor,
    required this.borderWidth,
  });

  Path _getClip(Size size) {
    var pattern = 9.0;
    var offset = size.width % pattern;
    var count = size.width ~/ pattern;
    if (count % 2 != 0) {
      offset += pattern;
      count--;
    }
    pattern += offset / count;
    final leftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height);
    //add bottom path
    var x = pattern;
    var isDown = false;
    while (true) {
      if (!isDown) {
        leftPath.lineTo(x, size.height - pattern / 1.5);
      } else {
        leftPath.lineTo(x, size.height);
      }
      isDown = !isDown;
      x = min(x + pattern, size.width);
      if (x == size.width) {
        if (!isDown) {
          leftPath.lineTo(x, size.height - pattern / 1.5);
        } else {
          leftPath.lineTo(x, size.height);
        }
        break;
      }
    }

    //add right path
    leftPath.lineTo(size.width, 0);

    //add top path
    isDown = true;

    x = size.width - pattern;
    while (true) {
      if (isDown) {
        leftPath.lineTo(x, pattern / 1.5);
      } else {
        leftPath.lineTo(x, 0);
      }
      isDown = !isDown;
      x = max(x - pattern, 0);
      if (x == 0) {
        if (isDown) {
          leftPath.lineTo(x, pattern / 1.5);
        } else {
          leftPath.lineTo(x, 0);
        }
        break;
      }
    }
    return Path.from(leftPath)..close();
  }

  @override
  EdgeInsetsGeometry get dimensions {
    return const EdgeInsets.all(0);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(
        const BorderRadius.all(Radius.circular(0))
            .resolve(textDirection)
            .toRRect(rect)
            .deflate(borderWidth),
      );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _getClip(Size(rect.right - rect.left, rect.bottom - rect.left));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final strokePaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;
    final path = _getClip(
      Size(rect.right - rect.left, rect.bottom - rect.left),
    );

    canvas.drawPath(
      path,
      strokePaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return ReceiptShapeBorder(
      borderColor: borderColor,
      borderWidth: borderWidth,
    );
  }
}
