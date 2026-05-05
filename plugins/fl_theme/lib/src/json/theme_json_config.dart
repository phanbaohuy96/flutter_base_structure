import 'package:flutter/material.dart';

import 'theme_json_codec.dart';
import 'theme_json_color.dart';
import 'theme_json_component.dart';
import 'theme_json_decoration.dart';
import 'theme_json_screen.dart';
import 'theme_json_typography.dart';

/// Root JSON DTO for importing and exporting app theme configuration.
class ThemeJsonConfig {
  /// Version of the JSON schema used by this config.
  final int schemaVersion;

  /// Human-readable theme name.
  final String name;

  /// Theme brightness mode.
  final Brightness mode;

  /// Whether generated themes should use Material 3 defaults.
  final bool useMaterial3;

  /// Optional font family for generated themes.
  final String? fontFamily;

  /// Semantic color configuration.
  final ThemeJsonColor colors;

  /// Typography role configuration.
  final ThemeJsonTypography typography;

  /// Decoration token configuration.
  final ThemeJsonDecoration decoration;

  /// Material component behavior configuration.
  final ThemeJsonComponent components;

  /// Project screen chrome configuration.
  final ThemeJsonScreen screen;

  /// Creates a complete JSON theme configuration.
  const ThemeJsonConfig({
    this.schemaVersion = 1,
    this.name = 'Ocean Blue',
    this.mode = Brightness.light,
    this.useMaterial3 = true,
    this.fontFamily,
    this.colors = const ThemeJsonColor(),
    this.typography = const ThemeJsonTypography(),
    this.decoration = const ThemeJsonDecoration(),
    this.components = const ThemeJsonComponent(),
    this.screen = const ThemeJsonScreen(),
  });

  /// Creates a theme configuration from a decoded JSON object.
  factory ThemeJsonConfig.fromJson(Map<String, dynamic> json) {
    final mode = brightnessFromJson(readString(json, 'mode'));
    return ThemeJsonConfig(
      schemaVersion: readInt(json, 'schemaVersion', 1),
      name: readString(json, 'name') ?? 'Custom Theme',
      mode: mode,
      useMaterial3: readBool(json, 'useMaterial3', true),
      fontFamily: readString(json, 'fontFamily'),
      colors: ThemeJsonColor.fromJson(
        readObject(json, 'colors'),
        brightness: mode,
      ),
      typography: ThemeJsonTypography.fromJson(readObject(json, 'typography')),
      decoration: ThemeJsonDecoration.fromJson(readObject(json, 'decoration')),
      components: ThemeJsonComponent.fromJson(readObject(json, 'components')),
      screen: ThemeJsonScreen.fromJson(readObject(json, 'screen')),
    );
  }

  /// Decodes a JSON string into a theme configuration.
  factory ThemeJsonConfig.decode(String source) {
    return ThemeJsonConfig.fromJson(decodeThemeJson(source));
  }

  /// Converts this theme configuration to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'name': name,
      'mode': brightnessToJson(mode),
      'useMaterial3': useMaterial3,
      'fontFamily': fontFamily,
      'colors': colors.toJson(),
      'typography': typography.toJson(),
      'decoration': decoration.toJson(),
      'components': components.toJson(),
      'screen': screen.toJson(),
    };
  }

  /// Encodes this theme configuration as formatted JSON.
  String encode() {
    return encodeThemeJson(toJson());
  }

  /// Creates a copy with selected theme configuration values replaced.
  ThemeJsonConfig copyWith({
    int? schemaVersion,
    String? name,
    Brightness? mode,
    bool? useMaterial3,
    String? fontFamily,
    bool includeFontFamily = false,
    ThemeJsonColor? colors,
    ThemeJsonTypography? typography,
    ThemeJsonDecoration? decoration,
    ThemeJsonComponent? components,
    ThemeJsonScreen? screen,
  }) {
    return ThemeJsonConfig(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      fontFamily: includeFontFamily
          ? fontFamily
          : fontFamily ?? this.fontFamily,
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      decoration: decoration ?? this.decoration,
      components: components ?? this.components,
      screen: screen ?? this.screen,
    );
  }
}
