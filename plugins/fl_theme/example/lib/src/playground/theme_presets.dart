import 'package:fl_theme/fl_theme.dart';
import 'package:flutter/material.dart';

class ThemePreset {
  final String label;
  final ThemeJsonConfig config;

  const ThemePreset({required this.label, required this.config});
}

const themePresets = [
  ThemePreset(
    label: 'Ocean Blue',
    config: ThemeJsonConfig(
      name: 'Ocean Blue',
      colors: ThemeJsonColor(
        primary: Color(0xFF2563EB),
        secondary: Color(0xFFEFF6FF),
        surface: Colors.white,
        background: Color(0xFFF3F4F6),
        error: Color(0xFFB91C1C),
        appBarBackground: Colors.white,
        appBarForeground: Color(0xFF111827),
      ),
      typography: ThemeJsonTypography(
        buttonFontSize: 15,
        buttonFontWeight: 600,
        bodyFontSize: 14,
      ),
      decoration: ThemeJsonDecoration(
        radius: 8,
        buttonRadius: 8,
        inputRadius: 8,
        chipRadius: 16,
        screenPadding: 16,
      ),
      components: ThemeJsonComponent(
        inputFilled: false,
        appBarCenterTitle: true,
        chipShowCheckmark: true,
      ),
      screen: ThemeJsonScreen(
        centerTitle: true,
      ),
    ),
  ),
  ThemePreset(
    label: 'Rose Dark',
    config: ThemeJsonConfig(
      name: 'Rose Dark',
      mode: Brightness.dark,
      colors: ThemeJsonColor(
        primary: Color(0xFFE11D48),
        secondary: Color(0xFF881337),
        surface: Color(0xFF1F1720),
        background: Color(0xFF120A10),
        error: Color(0xFFFB7185),
        appBarBackground: Color(0xFF1F1720),
        appBarForeground: Colors.white,
      ),
      typography: ThemeJsonTypography(
        buttonFontSize: 16,
        buttonFontWeight: 700,
        bodyFontSize: 15,
      ),
      decoration: ThemeJsonDecoration(
        radius: 14,
        buttonRadius: 20,
        inputRadius: 14,
        chipRadius: 28,
        screenPadding: 20,
      ),
      components: ThemeJsonComponent(
        inputFilled: true,
        appBarCenterTitle: false,
        chipShowCheckmark: true,
      ),
      screen: ThemeJsonScreen(
        showHeaderImage: true,
        hasBottomBorderRadius: true,
        showAppbarDivider: true,
      ),
    ),
  ),
  ThemePreset(
    label: 'Forest',
    config: ThemeJsonConfig(
      name: 'Forest',
      colors: ThemeJsonColor(
        primary: Color(0xFF15803D),
        secondary: Color(0xFFDCFCE7),
        surface: Colors.white,
        background: Color(0xFFF0FDF4),
        error: Color(0xFFB91C1C),
        appBarBackground: Color(0xFF14532D),
        appBarForeground: Colors.white,
      ),
      typography: ThemeJsonTypography(
        buttonFontSize: 14,
        buttonFontWeight: 500,
        bodyFontSize: 14,
      ),
      decoration: ThemeJsonDecoration(
        radius: 12,
        buttonRadius: 10,
        inputRadius: 12,
        chipRadius: 12,
        screenPadding: 18,
      ),
      components: ThemeJsonComponent(
        inputFilled: true,
        appBarCenterTitle: true,
        chipShowCheckmark: false,
      ),
      screen: ThemeJsonScreen(
        hasBottomBorderRadius: true,
        centerTitle: true,
      ),
    ),
  ),
  ThemePreset(
    label: 'Minimal Mono',
    config: ThemeJsonConfig(
      name: 'Minimal Mono',
      useMaterial3: false,
      fontFamily: 'monospace',
      colors: ThemeJsonColor(
        primary: Color(0xFF111827),
        secondary: Color(0xFFE5E7EB),
        surface: Color(0xFFFFFFFF),
        background: Color(0xFFFAFAFA),
        error: Color(0xFFDC2626),
        appBarBackground: Color(0xFF111827),
        appBarForeground: Colors.white,
      ),
      typography: ThemeJsonTypography(
        buttonFontSize: 13,
        buttonFontWeight: 800,
        bodyFontSize: 13,
      ),
      decoration: ThemeJsonDecoration(
        radius: 2,
        buttonRadius: 2,
        inputRadius: 2,
        chipRadius: 2,
        screenPadding: 14,
      ),
      components: ThemeJsonComponent(
        appBarCenterTitle: false,
        chipShowCheckmark: false,
      ),
      screen: ThemeJsonScreen(
        showAppbarDivider: true,
      ),
    ),
  ),
];
