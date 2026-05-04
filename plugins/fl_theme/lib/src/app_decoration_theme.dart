import 'dart:ui';

import 'package:flutter/material.dart';

import 'json/theme_json_decoration.dart';

/// Theme extension for shared layout and shape design tokens.
///
/// `AppDecorationTheme` is attached to generated [ThemeData] by [AppTheme] and
/// is available through `context.decorationTheme`. Use it for spacing, radius,
/// padding, borders, and elevation values that should stay consistent across
/// app
/// widgets and plugin widgets.
///
/// The base [radiusMd] and [screenPadding] values define the general scale.
/// [buttonRadius], [inputRadius], and [chipRadius] preserve the component-level
/// values from [ThemeJsonDecoration] so the JSON playground can tune those
/// Material component shapes independently.
class AppDecorationTheme extends ThemeExtension<AppDecorationTheme> {
  /// The smallest corner radius token.
  final double radiusXs;

  /// The small corner radius token.
  final double radiusSm;

  /// The default corner radius token.
  final double radiusMd;

  /// The large corner radius token.
  final double radiusLg;

  /// The extra-large corner radius token.
  final double radiusXl;

  /// The pill-shaped corner radius token.
  final double radiusPill;

  /// The extra-extra-small spacing token.
  final double spaceXxs;

  /// The extra-small spacing token.
  final double spaceXs;

  /// The small spacing token.
  final double spaceSm;

  /// The medium spacing token.
  final double spaceMd;

  /// The large spacing token.
  final double spaceLg;

  /// The extra-large spacing token.
  final double spaceXl;

  /// The extra-extra-large spacing token.
  final double spaceXxl;

  /// The default horizontal and vertical screen padding.
  final double screenPadding;

  /// The corner radius used by generated button themes.
  final double buttonRadius;

  /// The corner radius used by generated input decoration themes.
  final double inputRadius;

  /// The corner radius used by generated chip themes.
  final double chipRadius;

  /// The default minimum size for buttons.
  final Size buttonMinSize;

  /// The default internal padding for buttons.
  final EdgeInsets buttonPadding;

  /// The default internal padding for input fields.
  final EdgeInsets inputPadding;

  /// The default internal padding for chips.
  final EdgeInsets chipPadding;

  /// The thin border width token.
  final double borderThin;

  /// The regular border width token.
  final double borderRegular;

  /// The zero elevation token.
  final double elevationNone;

  /// The small elevation token.
  final double elevationSm;

  /// The medium elevation token.
  final double elevationMd;

  /// Creates a decoration token set for app and plugin widgets.
  ///
  /// Defaults are intentionally small and Material-friendly: an 8px base
  /// radius, a 16px screen padding, compact input padding, and no default
  /// button elevation. Apps can override individual tokens directly or create
  /// them from
  /// a JSON decoration section with [AppDecorationTheme.fromJsonConfig].
  const AppDecorationTheme({
    this.radiusXs = 4,
    this.radiusSm = 6,
    this.radiusMd = 8,
    this.radiusLg = 12,
    this.radiusXl = 16,
    this.radiusPill = 999,
    this.spaceXxs = 2,
    this.spaceXs = 4,
    this.spaceSm = 8,
    this.spaceMd = 12,
    this.spaceLg = 16,
    this.spaceXl = 24,
    this.spaceXxl = 32,
    this.screenPadding = 16,
    this.buttonRadius = 8,
    this.inputRadius = 8,
    this.chipRadius = 16,
    this.buttonMinSize = const Size(88, 40),
    this.buttonPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.inputPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.chipPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.borderThin = 1,
    this.borderRegular = 1,
    this.elevationNone = 0,
    this.elevationSm = 1,
    this.elevationMd = 8,
  });

  /// Creates decoration tokens from a JSON theme decoration section.
  ///
  /// The JSON [ThemeJsonDecoration.radius] value expands into the general
  /// radius scale, while [ThemeJsonDecoration.buttonRadius],
  /// [ThemeJsonDecoration.inputRadius], and
  /// [ThemeJsonDecoration.chipRadius] are preserved as component-specific
  /// tokens. [ThemeJsonDecoration.screenPadding] expands into the spacing scale
  /// and default component padding.
  factory AppDecorationTheme.fromJsonConfig(ThemeJsonDecoration config) {
    return AppDecorationTheme(
      radiusXs: config.radius / 2,
      radiusSm: config.radius * 0.75,
      radiusMd: config.radius,
      radiusLg: config.radius * 1.5,
      radiusXl: config.radius * 2,
      radiusPill: 999,
      spaceXxs: config.screenPadding / 8,
      spaceXs: config.screenPadding / 4,
      spaceSm: config.screenPadding / 2,
      spaceMd: config.screenPadding * 0.75,
      spaceLg: config.screenPadding,
      spaceXl: config.screenPadding * 1.5,
      spaceXxl: config.screenPadding * 2,
      screenPadding: config.screenPadding,
      buttonRadius: config.buttonRadius,
      inputRadius: config.inputRadius,
      chipRadius: config.chipRadius,
      buttonPadding: EdgeInsets.symmetric(horizontal: config.screenPadding),
      inputPadding: EdgeInsets.symmetric(
        horizontal: config.screenPadding * 0.75,
        vertical: config.screenPadding * 0.375,
      ),
      chipPadding: EdgeInsets.symmetric(
        horizontal: config.screenPadding * 0.75,
        vertical: config.screenPadding * 0.5,
      ),
    );
  }

  /// The smallest radius token as a [BorderRadius].
  BorderRadius get radiusXsBorder => BorderRadius.circular(radiusXs);

  /// The small radius token as a [BorderRadius].
  BorderRadius get radiusSmBorder => BorderRadius.circular(radiusSm);

  /// The default radius token as a [BorderRadius].
  BorderRadius get radiusMdBorder => BorderRadius.circular(radiusMd);

  /// The large radius token as a [BorderRadius].
  BorderRadius get radiusLgBorder => BorderRadius.circular(radiusLg);

  /// The extra-large radius token as a [BorderRadius].
  BorderRadius get radiusXlBorder => BorderRadius.circular(radiusXl);

  /// The pill radius token as a [BorderRadius].
  BorderRadius get radiusPillBorder => BorderRadius.circular(radiusPill);

  /// The button radius token as a [BorderRadius].
  BorderRadius get buttonRadiusBorder => BorderRadius.circular(buttonRadius);

  /// The input radius token as a [BorderRadius].
  BorderRadius get inputRadiusBorder => BorderRadius.circular(inputRadius);

  /// The chip radius token as a [BorderRadius].
  BorderRadius get chipRadiusBorder => BorderRadius.circular(chipRadius);

  /// Converts these decoration tokens to their JSON DTO.
  ThemeJsonDecoration toJsonConfig() {
    return ThemeJsonDecoration(
      radius: radiusMd,
      buttonRadius: buttonRadius,
      inputRadius: inputRadius,
      chipRadius: chipRadius,
      screenPadding: screenPadding,
    );
  }

  /// Creates a copy with selected decoration tokens replaced.
  @override
  AppDecorationTheme copyWith({
    double? radiusXs,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? radiusPill,
    double? spaceXxs,
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? spaceXxl,
    double? screenPadding,
    double? buttonRadius,
    double? inputRadius,
    double? chipRadius,
    Size? buttonMinSize,
    EdgeInsets? buttonPadding,
    EdgeInsets? inputPadding,
    EdgeInsets? chipPadding,
    double? borderThin,
    double? borderRegular,
    double? elevationNone,
    double? elevationSm,
    double? elevationMd,
  }) {
    return AppDecorationTheme(
      radiusXs: radiusXs ?? this.radiusXs,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      radiusPill: radiusPill ?? this.radiusPill,
      spaceXxs: spaceXxs ?? this.spaceXxs,
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      spaceXxl: spaceXxl ?? this.spaceXxl,
      screenPadding: screenPadding ?? this.screenPadding,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      inputRadius: inputRadius ?? this.inputRadius,
      chipRadius: chipRadius ?? this.chipRadius,
      buttonMinSize: buttonMinSize ?? this.buttonMinSize,
      buttonPadding: buttonPadding ?? this.buttonPadding,
      inputPadding: inputPadding ?? this.inputPadding,
      chipPadding: chipPadding ?? this.chipPadding,
      borderThin: borderThin ?? this.borderThin,
      borderRegular: borderRegular ?? this.borderRegular,
      elevationNone: elevationNone ?? this.elevationNone,
      elevationSm: elevationSm ?? this.elevationSm,
      elevationMd: elevationMd ?? this.elevationMd,
    );
  }

  /// Interpolates between two decoration token sets.
  @override
  AppDecorationTheme lerp(
    covariant ThemeExtension<AppDecorationTheme>? other,
    double t,
  ) {
    if (other is! AppDecorationTheme) {
      return this;
    }
    return AppDecorationTheme(
      radiusXs: lerpDouble(radiusXs, other.radiusXs, t) ?? other.radiusXs,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t) ?? other.radiusSm,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t) ?? other.radiusMd,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t) ?? other.radiusLg,
      radiusXl: lerpDouble(radiusXl, other.radiusXl, t) ?? other.radiusXl,
      radiusPill:
          lerpDouble(radiusPill, other.radiusPill, t) ?? other.radiusPill,
      spaceXxs: lerpDouble(spaceXxs, other.spaceXxs, t) ?? other.spaceXxs,
      spaceXs: lerpDouble(spaceXs, other.spaceXs, t) ?? other.spaceXs,
      spaceSm: lerpDouble(spaceSm, other.spaceSm, t) ?? other.spaceSm,
      spaceMd: lerpDouble(spaceMd, other.spaceMd, t) ?? other.spaceMd,
      spaceLg: lerpDouble(spaceLg, other.spaceLg, t) ?? other.spaceLg,
      spaceXl: lerpDouble(spaceXl, other.spaceXl, t) ?? other.spaceXl,
      spaceXxl: lerpDouble(spaceXxl, other.spaceXxl, t) ?? other.spaceXxl,
      screenPadding:
          lerpDouble(screenPadding, other.screenPadding, t) ??
          other.screenPadding,
      buttonRadius:
          lerpDouble(buttonRadius, other.buttonRadius, t) ?? other.buttonRadius,
      inputRadius:
          lerpDouble(inputRadius, other.inputRadius, t) ?? other.inputRadius,
      chipRadius:
          lerpDouble(chipRadius, other.chipRadius, t) ?? other.chipRadius,
      buttonMinSize: Size.lerp(buttonMinSize, other.buttonMinSize, t)!,
      buttonPadding: EdgeInsets.lerp(buttonPadding, other.buttonPadding, t)!,
      inputPadding: EdgeInsets.lerp(inputPadding, other.inputPadding, t)!,
      chipPadding: EdgeInsets.lerp(chipPadding, other.chipPadding, t)!,
      borderThin:
          lerpDouble(borderThin, other.borderThin, t) ?? other.borderThin,
      borderRegular:
          lerpDouble(borderRegular, other.borderRegular, t) ??
          other.borderRegular,
      elevationNone:
          lerpDouble(elevationNone, other.elevationNone, t) ??
          other.elevationNone,
      elevationSm:
          lerpDouble(elevationSm, other.elevationSm, t) ?? other.elevationSm,
      elevationMd:
          lerpDouble(elevationMd, other.elevationMd, t) ?? other.elevationMd,
    );
  }
}
