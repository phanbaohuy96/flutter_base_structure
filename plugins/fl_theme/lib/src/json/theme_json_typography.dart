import 'theme_json_codec.dart';

/// JSON DTO for typography settings in a theme config.
class ThemeJsonTypography {
  /// Font size for button text roles.
  final double buttonFontSize;

  /// Numeric font weight for button text roles.
  final int buttonFontWeight;

  /// Font size for body and input title text roles.
  final double bodyFontSize;

  /// Creates a typography JSON DTO with default text values.
  const ThemeJsonTypography({
    this.buttonFontSize = 15,
    this.buttonFontWeight = 600,
    this.bodyFontSize = 14,
  });

  /// Creates typography settings from a JSON object.
  factory ThemeJsonTypography.fromJson(Map<String, dynamic> json) {
    return ThemeJsonTypography(
      buttonFontSize: readDouble(json, 'buttonFontSize', 15),
      buttonFontWeight: readInt(json, 'buttonFontWeight', 600),
      bodyFontSize: readDouble(json, 'bodyFontSize', 14),
    );
  }

  /// Converts typography settings to JSON.
  Map<String, dynamic> toJson() {
    return {
      'buttonFontSize': buttonFontSize,
      'buttonFontWeight': buttonFontWeight,
      'bodyFontSize': bodyFontSize,
    };
  }

  /// Creates a copy with selected typography settings replaced.
  ThemeJsonTypography copyWith({
    double? buttonFontSize,
    int? buttonFontWeight,
    double? bodyFontSize,
  }) {
    return ThemeJsonTypography(
      buttonFontSize: buttonFontSize ?? this.buttonFontSize,
      buttonFontWeight: buttonFontWeight ?? this.buttonFontWeight,
      bodyFontSize: bodyFontSize ?? this.bodyFontSize,
    );
  }
}
