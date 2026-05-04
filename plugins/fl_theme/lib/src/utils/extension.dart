import 'package:flutter/material.dart';

/// HSL-based color adjustments used by theme token defaults.
extension FlThemeColorExt on Color {
  /// Returns this color with its HSL lightness reduced by [amount].
  ///
  /// [amount] must be between `0` and `1`. Hue, saturation, and alpha are
  /// preserved by the HSL conversion.
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1, 'amount >= 0 && amount <= 1');

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  /// Returns this color with its HSL lightness increased by [amount].
  ///
  /// [amount] must be between `0` and `1`. Hue, saturation, and alpha are
  /// preserved by the HSL conversion.
  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1, 'amount >= 0 && amount <= 1');

    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );

    return hslLight.toColor();
  }
}
