// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ScreenTheme extends ThemeExtension<ScreenTheme> {
  final ScreenFormTheme screenFormTheme;
  final MainPageFormTheme mainPageFormTheme;

  const ScreenTheme({
    this.screenFormTheme = const ScreenFormTheme(),
    this.mainPageFormTheme = const MainPageFormTheme(),
  });

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

  @override
  ScreenTheme lerp(
    covariant ScreenTheme? other,
    double t,
  ) {
    if (other == null) {
      return this;
    }
    return ScreenTheme(
      screenFormTheme: screenFormTheme.lerp(
        other.screenFormTheme,
        t,
      ),
      mainPageFormTheme: mainPageFormTheme.lerp(
        other.mainPageFormTheme,
        t,
      ),
    );
  }
}

class ScreenFormTheme {
  final bool showHeaderImage;
  final bool showBackButton;
  final bool hasBottomBorderRadius;
  final bool centerTitle;
  final bool showAppbarDivider;
  final bool forceCenterTitle;

  /// default is [ThemeColor.appbarBackgroundColor]
  final Color? appbarColor;

  /// default is [ThemeColor.appbarForegroundColor]
  final Color? appbarForegroundColor;
  final int? titleMaxLines;

  /// default is [TextTheme.titleLarge]
  final TextStyle? titleStyle;

  /// default is [TextTheme.titleSmall]
  final TextStyle? desStyle;

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
  });

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
    );
  }

  ScreenFormTheme lerp(
    covariant ScreenFormTheme? other,
    double t,
  ) {
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
      appbarForegroundColor:
          Color.lerp(appbarForegroundColor, other.appbarForegroundColor, t),
      titleStyle: TextStyle.lerp(other.titleStyle, titleStyle, t),
      desStyle: TextStyle.lerp(other.desStyle, desStyle, t),
    );
  }
}

class MainPageFormTheme {
  final bool showHeaderImage;
  final bool showHeaderShadow;
  final bool hasBottomBorderRadius;

  /// default is [ThemeColor.primary]
  final Color? appbarColor;

  /// default is [ThemeColor.appbarForegroundColor]
  final Color? appbarForegroundColor;
  final int? titleMaxLines;
  final bool showAppbarDivider;

  /// default is [TextTheme.titleLarge]
  final TextStyle? titleStyle;

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

  MainPageFormTheme lerp(
    covariant MainPageFormTheme? other,
    double t,
  ) {
    if (other == null) {
      return copyWith();
    }
    return MainPageFormTheme(
      hasBottomBorderRadius: other.hasBottomBorderRadius,
      showAppbarDivider: other.showAppbarDivider,
      titleMaxLines: other.titleMaxLines,
      appbarColor: Color.lerp(appbarColor, other.appbarColor, t),
      appbarForegroundColor:
          Color.lerp(appbarForegroundColor, other.appbarForegroundColor, t),
      titleStyle: TextStyle.lerp(other.titleStyle, titleStyle, t),
    );
  }
}
