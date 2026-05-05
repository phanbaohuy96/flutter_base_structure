import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'app_component_theme.dart';
import 'app_decoration_theme.dart';
import 'app_text_theme.dart';
import 'app_typography_theme.dart';
import 'json/theme_json_color.dart';
import 'json/theme_json_config.dart';
import 'json/theme_json_screen.dart';
import 'screen_theme.dart';
import 'theme_color.dart';

/// Groups the semantic theme pieces used to build an app [ThemeData].
///
/// `AppDesignSystem` is the preferred runtime configuration surface for
/// `fl_theme`. It keeps semantic colors, screen chrome, typography, decoration
/// tokens, component behavior, FlexColorScheme overrides, platform, Material 3,
/// and font-family settings together so an app can create consistent light/dark
/// themes from one object.
///
/// JSON import/export flows should use [AppDesignSystem.fromJsonConfig] and
/// [toJsonConfig]. Direct app code can construct this class by hand when it
/// needs callbacks, precomputed text themes, or FlexColorScheme-specific
/// overrides that are intentionally not part of the portable JSON schema.
class AppDesignSystem {
  /// Human-readable name for this design system.
  final String name;

  /// Semantic colors exposed through [ThemeColorExtension].
  final ThemeColor colors;

  /// Screen chrome settings exposed through [ScreenTheme].
  final ScreenTheme screenTheme;

  /// Typography factory and text role overrides.
  final AppTypographyTheme typography;

  /// Optional precomputed app text theme for screen and Material text roles.
  ///
  /// Pass this when caller code has already created a text theme that should be
  /// reused by both screen chrome and Material theme generation. When null,
  /// [AppTheme.create] calls [typography.create] with [colors].
  final AppTextTheme? textTheme;

  /// Shared spacing, radius, elevation, and density tokens.
  final AppDecorationTheme decoration;

  /// Material component settings derived from design tokens.
  final AppComponentTheme components;

  /// Optional FlexColorScheme color data used instead of semantic colors.
  ///
  /// Use this for advanced FlexColorScheme palettes that cannot be represented
  /// by the portable JSON color fields.
  final FlexSchemeData? flexSchemeData;

  /// Optional FlexColorScheme sub-theme data used instead of component tokens.
  ///
  /// Use this for advanced Material component tuning. When null, [components]
  /// derives sub-theme data from [decoration] and [textTheme].
  final FlexSubThemesData? flexSubThemesData;

  /// Optional platform override for generated [ThemeData].
  final TargetPlatform? targetPlatform;

  /// Whether generated themes should use Material 3 defaults.
  final bool useMaterial3;

  /// Optional font family passed to FlexColorScheme.
  final String? fontFamily;

  /// Creates a complete design-system configuration.
  ///
  /// Only [colors] is required. Other parts default to conservative plugin
  /// tokens, which lets apps start from a small semantic palette and then opt
  /// into custom screen, typography, decoration, component, or Flex behavior.
  const AppDesignSystem({
    this.name = 'custom',
    required this.colors,
    this.screenTheme = const ScreenTheme(),
    this.typography = const AppTypographyTheme(),
    this.textTheme,
    this.decoration = const AppDecorationTheme(),
    this.components = const AppComponentTheme(),
    this.flexSchemeData,
    this.flexSubThemesData,
    this.targetPlatform,
    this.useMaterial3 = true,
    this.fontFamily,
  });

  /// Creates a design system from a JSON theme configuration.
  ///
  /// This maps portable JSON DTO fields into runtime Flutter classes:
  /// [ThemeJsonColor] becomes [ThemeColor], typography creates an
  /// [AppTextTheme], decoration and component sections become their runtime
  /// screen settings become [ScreenTheme].
  factory AppDesignSystem.fromJsonConfig(ThemeJsonConfig config) {
    final colors = ThemeColor(
      primary: config.colors.primary,
      secondary: config.colors.secondary,
      surface: config.colors.surface,
      background: config.colors.background,
      error: config.colors.error,
      brightness: config.mode,
      appbarBackgroundColor: config.colors.appBarBackground,
      appbarForegroundColor: config.colors.appBarForeground,
      scaffoldBackgroundColor: config.colors.background,
      cardBackground: config.colors.surface,
      canvasColor: config.colors.surface,
      elevatedBtnForegroundColor: config.mode == Brightness.light
          ? Colors.white
          : Colors.black,
      outlineButtonColor: config.colors.primary,
      labelText: config.mode == Brightness.light
          ? const Color(0xFF6B7280)
          : const Color(0xFFD1D5DB),
    );
    final typography = AppTypographyTheme.fromJsonConfig(config.typography);
    final textTheme = typography.create(colors);

    return AppDesignSystem(
      name: config.name,
      colors: colors,
      screenTheme: ScreenTheme.fromTextTheme(
        textTheme,
        showHeaderImage: config.screen.showHeaderImage,
        hasBottomBorderRadius: config.screen.hasBottomBorderRadius,
        showAppbarDivider: config.screen.showAppbarDivider,
        centerTitle: config.screen.centerTitle,
      ),
      typography: typography,
      textTheme: textTheme,
      decoration: AppDecorationTheme.fromJsonConfig(config.decoration),
      components: AppComponentTheme.fromJsonConfig(config.components),
      useMaterial3: config.useMaterial3,
      fontFamily: config.fontFamily,
    );
  }

  /// Converts this design system back to its JSON theme representation.
  ///
  /// Only portable values are included. Runtime-only callbacks, precomputed
  /// [textTheme], platform overrides, and FlexColorScheme-specific overrides
  /// are intentionally not serialized.
  ThemeJsonConfig toJsonConfig() {
    return ThemeJsonConfig(
      name: name,
      mode: colors.brightness,
      useMaterial3: useMaterial3,
      fontFamily: fontFamily,
      colors: ThemeJsonColor(
        primary: colors.primary,
        secondary: colors.secondary,
        surface: colors.surface,
        background: colors.scaffoldBackgroundColor,
        error: colors.error,
        appBarBackground:
            colors.appbarBackgroundColor ?? colors.scaffoldBackgroundColor,
        appBarForeground: colors.appbarForegroundColor,
      ),
      typography: typography.toJsonConfig(),
      decoration: decoration.toJsonConfig(),
      components: components.toJsonConfig(),
      screen: ThemeJsonScreen(
        showHeaderImage: screenTheme.screenFormTheme.showHeaderImage,
        hasBottomBorderRadius:
            screenTheme.screenFormTheme.hasBottomBorderRadius,
        showAppbarDivider: screenTheme.screenFormTheme.showAppbarDivider,
        centerTitle: screenTheme.screenFormTheme.centerTitle,
      ),
    );
  }

  /// Creates a copy with selected design-system parts replaced.
  AppDesignSystem copyWith({
    String? name,
    ThemeColor? colors,
    ScreenTheme? screenTheme,
    AppTypographyTheme? typography,
    AppTextTheme? textTheme,
    AppDecorationTheme? decoration,
    AppComponentTheme? components,
    FlexSchemeData? flexSchemeData,
    FlexSubThemesData? flexSubThemesData,
    TargetPlatform? targetPlatform,
    bool? useMaterial3,
    String? fontFamily,
  }) {
    return AppDesignSystem(
      name: name ?? this.name,
      colors: colors ?? this.colors,
      screenTheme: screenTheme ?? this.screenTheme,
      typography: typography ?? this.typography,
      textTheme: textTheme ?? this.textTheme,
      decoration: decoration ?? this.decoration,
      components: components ?? this.components,
      flexSchemeData: flexSchemeData ?? this.flexSchemeData,
      flexSubThemesData: flexSubThemesData ?? this.flexSubThemesData,
      targetPlatform: targetPlatform ?? this.targetPlatform,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}
