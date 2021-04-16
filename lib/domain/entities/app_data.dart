import 'package:flutter/material.dart';

import '../../presentation/theme/theme_data.dart';

class AppData {
  ThemeData? themeData;
  SupportedTheme currentTheme;
  Locale locale;

  AppData(this.currentTheme, this.locale) {
    themeData = initialTheme.data;
  }

  AppTheme get initialTheme {
    if (currentTheme == SupportedTheme.light) {
      return buildLightTheme();
    }

    if (currentTheme == SupportedTheme.dark) {
      return buildDarkTheme();
    }

    return buildLightTheme();
  }
}
