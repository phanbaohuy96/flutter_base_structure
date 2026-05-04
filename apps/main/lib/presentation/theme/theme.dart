import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'screen_theme.dart';
import 'theme_color.dart';

class MainAppTheme {
  final AppTheme light;
  final AppTheme dark;

  const MainAppTheme({required this.light, required this.dark});

  factory MainAppTheme.normal() {
    return MainAppTheme(
      light: _buildTheme(AppThemeColor()),
      dark: _buildTheme(AppDarkThemeColor()),
    );
  }

  static AppTheme _buildTheme(ThemeColor themeColor) {
    final typography = _createTypographyTheme();
    final textTheme = typography.create(themeColor);

    return AppTheme.create(
      AppThemeConfig(
        designSystem: AppDesignSystem(
          name: themeColor.brightness.name,
          colors: themeColor,
          screenTheme: AppScreenThemes.create(textTheme),
          typography: typography,
          textTheme: textTheme,
        ),
      ),
    );
  }

  static AppTypographyTheme _createTypographyTheme() {
    return AppTypographyTheme(
      override: (textTheme) => textTheme.copyWithTypography(
        inputTitle: textTheme.bodyMedium,
        buttonText: textTheme.bodyMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
