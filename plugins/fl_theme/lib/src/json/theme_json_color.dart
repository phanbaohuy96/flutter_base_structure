import 'package:flutter/material.dart';

import 'theme_json_codec.dart';

/// JSON DTO for the semantic color section of a theme config.
class ThemeJsonColor {
  /// Primary brand color.
  final Color primary;

  /// Secondary brand or accent color.
  final Color secondary;

  /// Surface color for cards, sheets, and elevated content.
  final Color surface;

  /// Background color for scaffolds and scrollable content.
  final Color background;

  /// Error color for validation and destructive states.
  final Color error;

  /// App bar background color.
  final Color appBarBackground;

  /// App bar foreground color.
  final Color appBarForeground;

  /// Creates a JSON color DTO with light-theme defaults.
  const ThemeJsonColor({
    this.primary = const Color(0xFF3B82F6),
    this.secondary = const Color(0xFFEFF6FF),
    this.surface = Colors.white,
    this.background = const Color(0xFFF3F4F6),
    this.error = const Color(0xFFB00020),
    this.appBarBackground = Colors.white,
    this.appBarForeground = const Color(0xFF111827),
  });

  /// Creates colors from a JSON object using brightness-aware fallbacks.
  factory ThemeJsonColor.fromJson(
    Map<String, dynamic> json, {
    Brightness brightness = Brightness.light,
  }) {
    final fallback = brightness == Brightness.light
        ? const ThemeJsonColor()
        : const ThemeJsonColor(
            surface: Color(0xFF121212),
            background: Color(0xFF111827),
            error: Color(0xFFCF6679),
            appBarBackground: Color(0xFF111827),
            appBarForeground: Colors.white,
          );

    return ThemeJsonColor(
      primary: readColor(
        json,
        'primary',
        fallback.primary,
        path: 'colors.primary',
      ),
      secondary: readColor(
        json,
        'secondary',
        fallback.secondary,
        path: 'colors.secondary',
      ),
      surface: readColor(
        json,
        'surface',
        fallback.surface,
        path: 'colors.surface',
      ),
      background: readColor(
        json,
        'background',
        fallback.background,
        path: 'colors.background',
      ),
      error: readColor(json, 'error', fallback.error, path: 'colors.error'),
      appBarBackground: readColor(
        json,
        'appBarBackground',
        fallback.appBarBackground,
        path: 'colors.appBarBackground',
      ),
      appBarForeground: readColor(
        json,
        'appBarForeground',
        fallback.appBarForeground,
        path: 'colors.appBarForeground',
      ),
    );
  }

  /// Converts colors to JSON using uppercase hex strings.
  Map<String, dynamic> toJson() {
    return {
      'primary': themeColorToHex(primary),
      'secondary': themeColorToHex(secondary),
      'surface': themeColorToHex(surface),
      'background': themeColorToHex(background),
      'error': themeColorToHex(error),
      'appBarBackground': themeColorToHex(appBarBackground),
      'appBarForeground': themeColorToHex(appBarForeground),
    };
  }

  /// Creates a copy with selected colors replaced.
  ThemeJsonColor copyWith({
    Color? primary,
    Color? secondary,
    Color? surface,
    Color? background,
    Color? error,
    Color? appBarBackground,
    Color? appBarForeground,
  }) {
    return ThemeJsonColor(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      surface: surface ?? this.surface,
      background: background ?? this.background,
      error: error ?? this.error,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      appBarForeground: appBarForeground ?? this.appBarForeground,
    );
  }
}
