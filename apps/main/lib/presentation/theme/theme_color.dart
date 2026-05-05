import 'package:core/core.dart';
import 'package:flutter/material.dart';

class AppPalette {
  AppPalette._();

  static const primary = Color(0xFF3B82F6);
  static const secondary = Color(0xFFEFF6FF);
  static const lightScaffold = Color(0xFFF3F4F6);
  static const lightLabel = Color(0xFF8E8E93);
  static const darkSurface = Color(0xFF111827);
  static const darkCard = Color(0xFF1F2937);
  static const darkScaffold = Color(0xFF0F172A);
  static const darkBorder = Color(0xFF374151);
  static const darkLabel = Color(0xFFD1D5DB);
}

class AppThemeColor extends ThemeColor {
  AppThemeColor({
    super.primary = AppPalette.primary,
    super.secondary = AppPalette.secondary,
    super.appbarBackgroundColor = Colors.white,
    super.appbarForegroundColor = Colors.black,
    super.scaffoldBackgroundColor = AppPalette.lightScaffold,
    super.brightness = Brightness.light,
    super.elevatedBtnForegroundColor = Colors.white,
    super.schemeAction = Colors.grey,
    super.outlineButtonColor = AppPalette.primary,
    super.labelText = AppPalette.lightLabel,
  });
}

class AppDarkThemeColor extends ThemeColor {
  AppDarkThemeColor({
    super.primary = AppPalette.primary,
    super.secondary = AppPalette.secondary,
    super.surface = AppPalette.darkSurface,
    super.background = AppPalette.darkScaffold,
    super.cardBackground = AppPalette.darkCard,
    super.canvasColor = AppPalette.darkSurface,
    super.scaffoldBackgroundColor = AppPalette.darkScaffold,
    super.appbarForegroundColor = Colors.white,
    super.appbarBackgroundColor = AppPalette.darkSurface,
    super.borderColor = AppPalette.darkBorder,
    super.dividerColor = AppPalette.darkBorder,
    super.brightness = Brightness.dark,
    super.elevatedBtnForegroundColor = Colors.white,
    super.schemeAction = Colors.grey,
    super.outlineButtonColor = AppPalette.primary,
    super.labelText = AppPalette.darkLabel,
    super.displayText = Colors.white,
    super.headlineText = Colors.white,
    super.titleText = Colors.white,
    super.bodyText = AppPalette.darkLabel,
  });
}
