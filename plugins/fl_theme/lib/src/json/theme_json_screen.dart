import 'theme_json_codec.dart';

/// JSON DTO for project screen chrome settings in a theme config.
class ThemeJsonScreen {
  /// Whether screen forms should display their header image.
  final bool showHeaderImage;

  /// Whether screen forms should round their bottom edge.
  final bool hasBottomBorderRadius;

  /// Whether app bars should show a bottom divider.
  final bool showAppbarDivider;

  /// Whether screen titles should be centered.
  final bool centerTitle;

  /// Creates a screen JSON DTO with default screen chrome values.
  const ThemeJsonScreen({
    this.showHeaderImage = false,
    this.hasBottomBorderRadius = false,
    this.showAppbarDivider = false,
    this.centerTitle = false,
  });

  /// Creates screen chrome settings from a JSON object.
  factory ThemeJsonScreen.fromJson(Map<String, dynamic> json) {
    return ThemeJsonScreen(
      showHeaderImage: readBool(json, 'showHeaderImage', false),
      hasBottomBorderRadius: readBool(json, 'hasBottomBorderRadius', false),
      showAppbarDivider: readBool(json, 'showAppbarDivider', false),
      centerTitle: readBool(json, 'centerTitle', false),
    );
  }

  /// Converts screen chrome settings to JSON.
  Map<String, dynamic> toJson() {
    return {
      'showHeaderImage': showHeaderImage,
      'hasBottomBorderRadius': hasBottomBorderRadius,
      'showAppbarDivider': showAppbarDivider,
      'centerTitle': centerTitle,
    };
  }

  /// Creates a copy with selected screen chrome settings replaced.
  ThemeJsonScreen copyWith({
    bool? showHeaderImage,
    bool? hasBottomBorderRadius,
    bool? showAppbarDivider,
    bool? centerTitle,
  }) {
    return ThemeJsonScreen(
      showHeaderImage: showHeaderImage ?? this.showHeaderImage,
      hasBottomBorderRadius:
          hasBottomBorderRadius ?? this.hasBottomBorderRadius,
      showAppbarDivider: showAppbarDivider ?? this.showAppbarDivider,
      centerTitle: centerTitle ?? this.centerTitle,
    );
  }
}
