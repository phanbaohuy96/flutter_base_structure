import 'package:flutter/material.dart';

import 'app_text_theme.dart';
import 'json/theme_json_typography.dart';
import 'theme_color.dart';

/// Overrides an app text theme after token-based typography is applied.
///
/// Use this callback when an app needs to remap semantic roles, such as making
/// `buttonText` use a different base slot, after the standard text styles and
/// JSON typography fields have already been applied.
typedef AppTextThemeOverride = AppTextTheme Function(AppTextTheme textTheme);

/// Configures how semantic app text roles are created.
///
/// `AppTypographyTheme` is a factory configuration, not a [ThemeExtension]. It
/// creates the [AppTextTheme] that is attached to [ThemeData] through
/// [AppTextThemeExtension]. The [wrapper] is applied to every base style first,
/// then JSON-style size/weight fields are applied, and finally [override] can
/// replace any semantic role.
class AppTypographyTheme {
  /// Optional wrapper applied to every base text style.
  ///
  /// This is the right hook for font-family package adapters or global text
  /// transforms because it runs before semantic roles are copied or overridden.
  final TextStyle Function(TextStyle style)? wrapper;

  /// Optional final override for the generated app text theme.
  ///
  /// This runs after [buttonFontSize], [buttonFontWeight], and [bodyFontSize]
  /// have been applied.
  final AppTextThemeOverride? override;

  /// Optional font size for button text roles.
  final double? buttonFontSize;

  /// Optional font weight for button text roles.
  final FontWeight? buttonFontWeight;

  /// Optional font size for body and input title text roles.
  final double? bodyFontSize;

  /// Creates typography settings for generated app text themes.
  const AppTypographyTheme({
    this.wrapper,
    this.override,
    this.buttonFontSize,
    this.buttonFontWeight,
    this.bodyFontSize,
  });

  /// Creates typography settings from a JSON theme typography section.
  factory AppTypographyTheme.fromJsonConfig(ThemeJsonTypography config) {
    return AppTypographyTheme(
      buttonFontSize: config.buttonFontSize,
      buttonFontWeight: _fontWeightFromValue(config.buttonFontWeight),
      bodyFontSize: config.bodyFontSize,
    );
  }

  /// Creates semantic app text roles for the provided [colors].
  AppTextTheme create(ThemeColor colors) {
    final base = AppTextTheme.create(colors, wrapper: wrapper);
    final configured = base.copyWithTypography(
      bodyMedium: base.bodyMedium?.copyWith(fontSize: bodyFontSize),
      inputTitle: base.bodyMedium?.copyWith(fontSize: bodyFontSize),
      buttonText: base.buttonText?.copyWith(
        fontSize: buttonFontSize,
        fontWeight: buttonFontWeight,
      ),
    );
    return override?.call(configured) ?? configured;
  }

  /// Converts these typography settings to their JSON DTO.
  ThemeJsonTypography toJsonConfig() {
    return ThemeJsonTypography(
      buttonFontSize: buttonFontSize ?? 15,
      buttonFontWeight: buttonFontWeight?.value ?? 600,
      bodyFontSize: bodyFontSize ?? 14,
    );
  }

  /// Creates a copy with selected typography settings replaced.
  AppTypographyTheme copyWith({
    TextStyle Function(TextStyle style)? wrapper,
    AppTextThemeOverride? override,
    double? buttonFontSize,
    FontWeight? buttonFontWeight,
    double? bodyFontSize,
  }) {
    return AppTypographyTheme(
      wrapper: wrapper ?? this.wrapper,
      override: override ?? this.override,
      buttonFontSize: buttonFontSize ?? this.buttonFontSize,
      buttonFontWeight: buttonFontWeight ?? this.buttonFontWeight,
      bodyFontSize: bodyFontSize ?? this.bodyFontSize,
    );
  }

  static FontWeight _fontWeightFromValue(int value) {
    switch (value.clamp(100, 900)) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      case 600:
      default:
        return FontWeight.w600;
    }
  }
}
