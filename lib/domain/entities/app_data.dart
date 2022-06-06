import 'package:flutter/material.dart';

import '../../presentation/theme/theme_data.dart';

class AppData {
  final ThemeData themeData;
  final SupportedTheme currentTheme;
  final Locale locale;

  AppData(this.currentTheme, this.locale)
      : themeData = getTheme(currentTheme).data;

  static AppTheme getTheme(SupportedTheme supportedTheme) {
    if (supportedTheme == SupportedTheme.light) {
      return buildLightTheme();
    }

    if (supportedTheme == SupportedTheme.dark) {
      return buildDarkTheme();
    }

    return buildLightTheme();
  }

  AppData copyWith({
    SupportedTheme? currentTheme,
    Locale? locale,
  }) {
    return AppData(
      currentTheme ?? this.currentTheme,
      locale ?? this.locale,
    );
  }
}
