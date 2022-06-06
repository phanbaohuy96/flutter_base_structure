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
  final theme = ThemeData.light();
  return AppTheme(
    'light',
    theme.copyWith(
      brightness: Brightness.light,
      primaryColorLight: AppColor.primaryColorLight,
      primaryColor: Colors.white,
      backgroundColor: Colors.white,
      scaffoldBackgroundColor: AppColor.scaffoldBackgroundColor,
      cardColor: AppColor.cardBackground,
      textTheme: AppTextTheme.getDefaultTextTheme(),
      colorScheme: theme.colorScheme.copyWith(
        secondary: AppColor.primaryColor,
      ),
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: Colors.white,
      ),
    ),
  );
}

AppTheme buildDarkTheme() {
  final theme = ThemeData.dark();
  return AppTheme(
    'dark',
    theme.copyWith(
      brightness: Brightness.dark,
      colorScheme: theme.colorScheme.copyWith(
        secondary: AppColor.primaryColor,
      ),
      primaryColorLight: AppColor.primaryColorLight,
      primaryColor: ThemeData.dark().primaryColor,
      scaffoldBackgroundColor: ThemeData.dark().primaryColor,
      cardColor: const Color(0xFF3e3c43),
      textTheme: AppTextTheme.getDefaultTextThemeDark(),
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: ThemeData.dark().primaryColor,
      ),
    ),
  );
}
