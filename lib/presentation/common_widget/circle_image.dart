import 'dart:math';
import 'package:flutter/material.dart';

class CircleImage extends StatelessWidget {
  final Widget child;
  const CircleImage({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(clipper: CircleClip(), child: child);
  }
}

class CircleClip extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: min(size.width, size.height) / 2,
    );
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
