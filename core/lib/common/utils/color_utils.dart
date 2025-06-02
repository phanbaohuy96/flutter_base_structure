import 'package:flutter/painting.dart';

class ColorHelper {
  static Color interpolateColor(
    Color initialColor,
    int index, {
    double angle = 30,
  }) {
    if (index == 0) {
      return initialColor;
    }
    final hue = HSVColor.fromColor(initialColor).hue;
    final newHue = (hue + (index * angle)) % 360;
    return HSVColor.fromAHSV(1, newHue, 1, 1).toColor();
  }
}
