import 'theme_json_codec.dart';

/// JSON DTO for decoration tokens in a theme config.
class ThemeJsonDecoration {
  /// Base corner radius used to derive the runtime radius scale.
  final double radius;

  /// Corner radius intended for buttons.
  final double buttonRadius;

  /// Corner radius intended for input fields.
  final double inputRadius;

  /// Corner radius intended for chips.
  final double chipRadius;

  /// Base screen padding used to derive the runtime spacing scale.
  final double screenPadding;

  /// Creates a decoration JSON DTO with default spacing and radius values.
  const ThemeJsonDecoration({
    this.radius = 8,
    this.buttonRadius = 8,
    this.inputRadius = 8,
    this.chipRadius = 16,
    this.screenPadding = 16,
  });

  /// Creates decoration tokens from a JSON object.
  factory ThemeJsonDecoration.fromJson(Map<String, dynamic> json) {
    return ThemeJsonDecoration(
      radius: readDouble(json, 'radius', 8),
      buttonRadius: readDouble(json, 'buttonRadius', 8),
      inputRadius: readDouble(json, 'inputRadius', 8),
      chipRadius: readDouble(json, 'chipRadius', 16),
      screenPadding: readDouble(json, 'screenPadding', 16),
    );
  }

  /// Converts decoration tokens to JSON.
  Map<String, dynamic> toJson() {
    return {
      'radius': radius,
      'buttonRadius': buttonRadius,
      'inputRadius': inputRadius,
      'chipRadius': chipRadius,
      'screenPadding': screenPadding,
    };
  }

  /// Creates a copy with selected decoration tokens replaced.
  ThemeJsonDecoration copyWith({
    double? radius,
    double? buttonRadius,
    double? inputRadius,
    double? chipRadius,
    double? screenPadding,
  }) {
    return ThemeJsonDecoration(
      radius: radius ?? this.radius,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      inputRadius: inputRadius ?? this.inputRadius,
      chipRadius: chipRadius ?? this.chipRadius,
      screenPadding: screenPadding ?? this.screenPadding,
    );
  }
}
