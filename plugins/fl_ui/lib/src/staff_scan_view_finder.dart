import 'dart:math';

import 'package:flutter/material.dart';

class StaffScanViewFinder extends StatelessWidget {
  final double sizeWithParent;
  final Color? backgroundColor;
  final Color? borderColor;
  final Colors? crosshairColor;
  final double? strokeWidth;

  const StaffScanViewFinder({
    Key? key,
    this.sizeWithParent = 0.6,
    this.backgroundColor,
    this.borderColor,
    this.crosshairColor,
    this.strokeWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScanViewFinderPaint(
        sizeWithParent,
        backgroundColor,
        borderColor,
        crosshairColor,
        strokeWidth,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _ScanViewFinderPaint extends CustomPainter {
  final double sizeWithParent;
  final Color? backgroundColor;
  final Color? borderColor;
  final Colors? crosshairColor;
  final double? strokeWidth;

  _ScanViewFinderPaint(
    this.sizeWithParent,
    this.backgroundColor,
    this.borderColor,
    this.crosshairColor,
    this.strokeWidth,
  );

  // double get _strokeWidth => strokeWidth ?? 3;

  @override
  void paint(Canvas canvas, Size size) {
    final vfSize = min(size.width, size.height) * sizeWithParent;
    final horizontalPad = (size.width - vfSize) / 2;
    final verticalPad = (size.height - vfSize) / 2;

    /// p1---------p2
    /// |           |
    /// |     +     |
    /// |           |
    /// p3---------p4
    // view finder position

    final p1 = Offset(horizontalPad, verticalPad);
    final p2 = Offset(vfSize + horizontalPad, verticalPad);
    final p3 = Offset(horizontalPad, vfSize + verticalPad);
    final p4 = Offset(vfSize + horizontalPad, vfSize + verticalPad);
    _drawBackground(canvas, size, p1, p2, p3, p4);
    // _drawBoder(canvas, size, p1, p2, p3, p4);
    // _drawCrosshair(canvas, size);
  }

  void _drawBackground(
    Canvas canvas,
    Size size,
    Offset p1,
    Offset p2,
    Offset p3,
    Offset p4,
  ) {
    final overlayPaint = Paint()..color = backgroundColor ?? Colors.black54;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()
          ..moveTo(0, 0)
          ..lineTo(0, size.height)
          ..lineTo(size.width, size.height)
          ..lineTo(size.width, 0)
          ..close(),
        Path()
          ..moveTo(p1.dx, p1.dy + 16)
          ..quadraticBezierTo(p1.dx, p1.dy, p1.dx + 16, p1.dy)
          ..lineTo(p2.dx - 16, p2.dy)
          ..quadraticBezierTo(p2.dx, p2.dy, p2.dx, p2.dy + 16)
          ..lineTo(p4.dx, p4.dy - 16)
          ..quadraticBezierTo(p4.dx, p4.dy, p4.dx - 16, p4.dy)
          ..lineTo(p3.dx + 16, p3.dy)
          ..quadraticBezierTo(p3.dx, p3.dy, p3.dx, p3.dy - 16)
          ..close(),
      ),
      overlayPaint,
    );
  }

  // void _drawBoder(
  //   Canvas canvas,
  //   Size size,
  //   Offset p1,
  //   Offset p2,
  //   Offset p3,
  //   Offset p4,
  // ) {
  //   final cornerPaint = Paint()
  //     ..color = borderColor ?? Colors.white
  //     ..strokeWidth = _strokeWidth
  //     ..strokeCap = StrokeCap.square
  //     ..style = PaintingStyle.stroke;

  //   ///     p5- p5.1 p6.2 -p6
  //   ///     | |-----------| |
  //   ///  p5.2 |           | p6.1
  //   ///       |     +     |
  //   ///  p7.1 |           | p8.2
  //   ///     | '-----------' |
  //   ///     p7- p7.2 p8.1 -p8
  //   // border position

  //   final length = _strokeWidth * 4;
  //   final p5 = Offset(p1.dx - _strokeWidth, p1.dy - _strokeWidth);
  //   final p51 = Offset(p5.dx + length, p5.dy);
  //   final p52 = Offset(p5.dx, p5.dy + length);

  //   final p6 = Offset(p2.dx + _strokeWidth, p2.dy - _strokeWidth);
  //   final p61 = Offset(p6.dx - length, p6.dy);
  //   final p62 = Offset(p6.dx, p6.dy + length);

  //   final p7 = Offset(p3.dx - _strokeWidth, p3.dy + _strokeWidth);
  //   final p71 = Offset(p7.dx, p7.dy - length);
  //   final p72 = Offset(p7.dx + length, p7.dy);

  //   final p8 = Offset(p4.dx + _strokeWidth, p4.dy + _strokeWidth);
  //   final p81 = Offset(p8.dx - length, p8.dy);
  //   final p82 = Offset(p8.dx, p8.dy - length);

  //   canvas.drawPath(
  //     Path()
  //       ..moveTo(p51.dx, p51.dy)
  //       ..lineTo(p5.dx, p5.dy)
  //       ..lineTo(p52.dx, p52.dy)
  //       ..moveTo(p61.dx, p61.dy)
  //       ..lineTo(p6.dx, p6.dy)
  //       ..lineTo(p62.dx, p62.dy)
  //       ..moveTo(p71.dx, p71.dy)
  //       ..lineTo(p7.dx, p7.dy)
  //       ..lineTo(p72.dx, p72.dy)
  //       ..moveTo(p81.dx, p81.dy)
  //       ..lineTo(p8.dx, p8.dy)
  //       ..lineTo(p82.dx, p82.dy),
  //     cornerPaint,
  //   );
  // }

  // void _drawCrosshair(Canvas canvas, Size size) {
  //   final crosshairPaint = Paint()
  //     ..color = crosshairColor as Color? ?? Colors.white
  //     ..strokeWidth = _strokeWidth
  //     ..strokeCap = StrokeCap.square
  //     ..style = PaintingStyle.stroke;

  //   /// |----------------|
  //   /// |                |
  //   /// |       p1       |
  //   /// |  p2 center p4  |
  //   /// |       p3       |
  //   /// |                |
  //   /// '----------------'
  //   // crosshair position
  //   final center = Offset(size.width / 2, size.height / 2);
  //   final length = _strokeWidth * 2;
  //   final p1 = Offset(center.dx, center.dy - length);
  //   final p2 = Offset(center.dx - length - _strokeWidth / 2, center.dy);
  //   final p3 = Offset(center.dx, center.dy + length);
  //   final p4 = Offset(center.dx + length + _strokeWidth / 2, center.dy);
  //   canvas.drawPath(
  //     Path()
  //       ..moveTo(p1.dx, p1.dy)
  //       ..lineTo(p3.dx, p3.dy)
  //       ..moveTo(p2.dx, p2.dy)
  //       ..lineTo(p4.dx, p4.dy)
  //       ..close(),
  //     crosshairPaint,
  //   );
  // }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
