import 'package:flutter/material.dart';

import 'app_text_theme.dart';
import 'theme_color.dart';

enum SupportedTheme { light, dark }

class AppTheme {
  final String name;
  final ThemeData data;

  const AppTheme(this.name, this.data);
}

AppTheme buildLightTheme() {
  return AppTheme(
    'light',
    ThemeData(
      brightness: Brightness.light,
      fontFamily: 'SFProText',
      accentColor: AppColor.primaryColor,
      primaryColorLight: AppColor.primaryColorLight,
      primaryColor: Colors.white,
      backgroundColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      cardColor: const Color(0xFFf4f5f8),
      textTheme: AppTextTheme.getDefaultTextTheme(),
    ),
  );
}

AppTheme buildDarkTheme() {
  return AppTheme(
    'dark',
    ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'SFProText',
      accentColor: AppColor.primaryColor,
      primaryColorLight: AppColor.primaryColorLight,
      primaryColor: ThemeData.dark().primaryColor,
      scaffoldBackgroundColor: ThemeData.dark().primaryColor,
      cardColor: const Color(0xFF3e3c43),
      textTheme: AppTextTheme.getDefaultTextThemeDark(),
    ),
  );
}
