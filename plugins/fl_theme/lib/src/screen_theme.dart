import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_text_theme.dart';

/// Theme extension for project screen chrome defaults.
///
/// `ScreenTheme` is attached to generated [ThemeData] by [AppTheme] and read
/// through `context.screenTheme`, `context.screenFormTheme`, and
/// `context.mainPageFormTheme`. It keeps the reusable screen wrappers aligned
/// with the same colors and typography as the Material theme.
class ScreenTheme extends ThemeExtension<ScreenTheme> {
  /// Defaults used by standard detail/form screens.
  final ScreenFormTheme screenFormTheme;

  /// Defaults used by main-tab or top-level pages.
  final MainPageFormTheme mainPageFormTheme;

  /// Creates screen chrome defaults for app wrappers.
  const ScreenTheme({
    this.screenFormTheme = const ScreenFormTheme(),
    this.mainPageFormTheme = const MainPageFormTheme(),
  });

  /// Creates matching screen form themes from semantic app text roles.
  ///
  /// This is the preferred factory when building a theme from JSON or app
  /// palette code because it applies the same title style to both screen
  /// wrapper types and maps screen chrome flags into the runtime theme.
  factory ScreenTheme.fromTextTheme(
    AppTextTheme textTheme, {
    bool showHeaderImage = false,
    bool hasBottomBorderRadius = false,
    bool showAppbarDivider = false,
    bool centerTitle = false,
  }) {
    return ScreenTheme(
      screenFormTheme: ScreenFormTheme(
        showHeaderImage: showHeaderImage,
        hasBottomBorderRadius: hasBottomBorderRadius,
        showAppbarDivider: showAppbarDivider,
        centerTitle: centerTitle,
        titleStyle: textTheme.bodyLarge,
      ),
      mainPageFormTheme: MainPageFormTheme(
        showHeaderImage: showHeaderImage,
        hasBottomBorderRadius: hasBottomBorderRadius,
        showAppbarDivider: showAppbarDivider,
        titleStyle: textTheme.bodyLarge,
      ),
    );
  }

  /// Creates a copy with selected screen wrapper themes replaced.
  @override
  ScreenTheme copyWith({
    ScreenFormTheme? screenFormTheme,
    MainPageFormTheme? mainPageFormTheme,
  }) {
    return ScreenTheme(
      screenFormTheme: screenFormTheme ?? this.screenFormTheme,
      mainPageFormTheme: mainPageFormTheme ?? this.mainPageFormTheme,
    );
  }

  /// Interpolates nested screen wrapper themes during theme changes.
  @override
  ScreenTheme lerp(covariant ScreenTheme? other, double t) {
    if (other == null) {
      return this;
    }
    return ScreenTheme(
      screenFormTheme: screenFormTheme.lerp(other.screenFormTheme, t),
      mainPageFormTheme: mainPageFormTheme.lerp(other.mainPageFormTheme, t),
    );
  }
}

const _kDefaultBackButtonSize = 22.0;

/// Visual defaults for standard screen-form wrappers.
///
/// `ScreenFormTheme` configures app bar chrome, header treatment, title layout,
/// and back-button presentation for reusable screen wrappers such as
/// `ScreenForm`.
class ScreenFormTheme {
  /// Whether the wrapper should render its configured header image.
  final bool showHeaderImage;

  /// Whether the wrapper should show a back button when navigation allows it.
  final bool showBackButton;

  /// Whether the wrapper should round the bottom edge of the header/app bar.
  final bool hasBottomBorderRadius;

  /// Whether the app bar title should be centered by default.
  final bool centerTitle;

  /// Whether a divider should be drawn below the app bar.
  final bool showAppbarDivider;

  /// Whether title centering should be enforced even when leading/actions
  /// exist.
  final bool forceCenterTitle;

  /// default is [ThemeColor.appbarBackgroundColor]
  final Color? appbarColor;

  /// default is [ThemeColor.appbarForegroundColor]
  final Color? appbarForegroundColor;

  /// Maximum number of app bar title lines.
  final int? titleMaxLines;

  /// Asset path for the back button icon (e.g. 'assets/icons/back.png').
  /// When null, the default [Icons.chevron_left] is used.
  final String? backButtonAsset;

  /// Size of the back button icon. Defaults to 22 when null.
  final double backButtonSize;

  /// default is [TextTheme.titleLarge]
  final TextStyle? titleStyle;

  /// default is [TextTheme.titleSmall]
  final TextStyle? desStyle;

  /// Optional spacing between the leading widget and the title in the AppBar.
  final double? titleSpacing;

  /// Creates visual defaults for standard screen-form wrappers.
  const ScreenFormTheme({
    this.showHeaderImage = false,
    this.showBackButton = true,
    this.hasBottomBorderRadius = true,
    this.centerTitle = true,
    this.showAppbarDivider = false,
    this.forceCenterTitle = false,
    this.titleMaxLines = 1,
    this.appbarColor,
    this.appbarForegroundColor,
    this.titleStyle,
    this.desStyle,
    this.backButtonAsset,
    this.backButtonSize = _kDefaultBackButtonSize,
    this.titleSpacing,
  });

  /// Creates a copy with selected screen-form values replaced.
  ScreenFormTheme copyWith({
    bool? showHeaderImage,
    bool? showBackButton,
    bool? hasBottomBorderRadius,
    bool? centerTitle,
    bool? showAppbarDivider,
    bool? forceCenterTitle,
    Color? appbarColor,
    Color? appbarForegroundColor,
    int? titleMaxLines,
    TextStyle? titleStyle,
    TextStyle? desStyle,
    String? backButtonAsset,
    double? backButtonSize,
    double? titleSpacing,
  }) {
    return ScreenFormTheme(
      showHeaderImage: showHeaderImage ?? this.showHeaderImage,
      showBackButton: showBackButton ?? this.showBackButton,
      hasBottomBorderRadius:
          hasBottomBorderRadius ?? this.hasBottomBorderRadius,
      centerTitle: centerTitle ?? this.centerTitle,
      showAppbarDivider: showAppbarDivider ?? this.showAppbarDivider,
      forceCenterTitle: forceCenterTitle ?? this.forceCenterTitle,
      appbarColor: appbarColor ?? this.appbarColor,
      appbarForegroundColor:
          appbarForegroundColor ?? this.appbarForegroundColor,
      titleMaxLines: titleMaxLines ?? this.titleMaxLines,
      titleStyle: titleStyle ?? this.titleStyle,
      desStyle: desStyle ?? this.desStyle,
      backButtonAsset: backButtonAsset ?? this.backButtonAsset,
      backButtonSize: backButtonSize ?? this.backButtonSize,
      titleSpacing: titleSpacing ?? this.titleSpacing,
    );
  }

  /// Interpolates colors, text styles, spacing, and animated numeric values.
  ScreenFormTheme lerp(covariant ScreenFormTheme? other, double t) {
    if (other == null) {
      return copyWith();
    }
    return ScreenFormTheme(
      showHeaderImage: other.showHeaderImage,
      showBackButton: other.showBackButton,
      hasBottomBorderRadius: other.hasBottomBorderRadius,
      centerTitle: other.centerTitle,
      showAppbarDivider: other.showAppbarDivider,
      forceCenterTitle: other.forceCenterTitle,
      titleMaxLines: other.titleMaxLines,
      appbarColor: Color.lerp(appbarColor, other.appbarColor, t),
      appbarForegroundColor: Color.lerp(
        appbarForegroundColor,
        other.appbarForegroundColor,
        t,
      ),
      titleStyle: TextStyle.lerp(other.titleStyle, titleStyle, t),
      desStyle: TextStyle.lerp(other.desStyle, desStyle, t),
      backButtonAsset: other.backButtonAsset,
      backButtonSize:
          lerpDouble(backButtonSize, other.backButtonSize, t) ??
          _kDefaultBackButtonSize,
      titleSpacing: lerpDouble(titleSpacing, other.titleSpacing, t),
    );
  }
}

/// Visual defaults for top-level or main-page wrappers.
///
/// `MainPageFormTheme` mirrors the screen-form chrome that main-tab pages need,
/// without back-button or description styling concerns.
class MainPageFormTheme {
  /// Whether the wrapper should render its configured header image.
  final bool showHeaderImage;

  /// Whether the header should draw an elevation/shadow treatment.
  final bool showHeaderShadow;

  /// Whether the header should round its bottom edge.
  final bool hasBottomBorderRadius;

  /// default is [ThemeColor.primary]
  final Color? appbarColor;

  /// default is [ThemeColor.appbarForegroundColor]
  final Color? appbarForegroundColor;

  /// Maximum number of app bar title lines.
  final int? titleMaxLines;

  /// Whether a divider should be drawn below the app bar.
  final bool showAppbarDivider;

  /// default is [TextTheme.titleLarge]
  final TextStyle? titleStyle;

  /// Creates visual defaults for top-level or main-page wrappers.
  const MainPageFormTheme({
    this.showHeaderImage = true,
    this.showHeaderShadow = true,
    this.hasBottomBorderRadius = true,
    this.titleMaxLines = 1,
    this.appbarColor,
    this.appbarForegroundColor,
    this.showAppbarDivider = false,
    this.titleStyle,
  });

  /// Creates a copy with selected main-page values replaced.
  MainPageFormTheme copyWith({
    bool? showHeaderImage,
    bool? showHeaderShadow,
    bool? hasBottomBorderRadius,
    Color? appbarColor,
    Color? appbarForegroundColor,
    int? titleMaxLines,
    bool? showAppbarDivider,
    TextStyle? titleStyle,
  }) {
    return MainPageFormTheme(
      showHeaderImage: showHeaderImage ?? this.showHeaderImage,
      showHeaderShadow: showHeaderShadow ?? this.showHeaderShadow,
      hasBottomBorderRadius:
          hasBottomBorderRadius ?? this.hasBottomBorderRadius,
      appbarColor: appbarColor ?? this.appbarColor,
      appbarForegroundColor:
          appbarForegroundColor ?? this.appbarForegroundColor,
      titleMaxLines: titleMaxLines ?? this.titleMaxLines,
      showAppbarDivider: showAppbarDivider ?? this.showAppbarDivider,
      titleStyle: titleStyle ?? this.titleStyle,
    );
  }

  /// Interpolates colors, text style, and animated numeric values.
  MainPageFormTheme lerp(covariant MainPageFormTheme? other, double t) {
    if (other == null) {
      return copyWith();
    }
    return MainPageFormTheme(
      hasBottomBorderRadius: other.hasBottomBorderRadius,
      showAppbarDivider: other.showAppbarDivider,
      titleMaxLines: other.titleMaxLines,
      appbarColor: Color.lerp(appbarColor, other.appbarColor, t),
      appbarForegroundColor: Color.lerp(
        appbarForegroundColor,
        other.appbarForegroundColor,
        t,
      ),
      titleStyle: TextStyle.lerp(other.titleStyle, titleStyle, t),
    );
  }
}
