import 'package:flutter/material.dart';

class TextScaleFixed extends StatelessWidget {
  final double scaleFixedFactor;
  final Widget child;

  TextScaleFixed({this.scaleFixedFactor = 1, this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: scaleFixedFactor ?? 1,
      ),
      child: child,
    );
  }
}
