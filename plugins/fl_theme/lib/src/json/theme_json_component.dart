import 'theme_json_codec.dart';

/// JSON DTO for component behavior in a theme config.
class ThemeJsonComponent {
  /// Whether input decorations should render with a filled background.
  final bool inputFilled;

  /// Whether app bar titles should be centered by default.
  final bool appBarCenterTitle;

  /// Whether selectable chips should show Material checkmarks.
  final bool chipShowCheckmark;

  /// Creates a component JSON DTO with default Material behavior.
  const ThemeJsonComponent({
    this.inputFilled = false,
    this.appBarCenterTitle = true,
    this.chipShowCheckmark = true,
  });

  /// Creates component settings from a JSON object.
  factory ThemeJsonComponent.fromJson(Map<String, dynamic> json) {
    return ThemeJsonComponent(
      inputFilled: readBool(json, 'inputFilled', false),
      appBarCenterTitle: readBool(json, 'appBarCenterTitle', true),
      chipShowCheckmark: readBool(json, 'chipShowCheckmark', true),
    );
  }

  /// Converts component settings to JSON.
  Map<String, dynamic> toJson() {
    return {
      'inputFilled': inputFilled,
      'appBarCenterTitle': appBarCenterTitle,
      'chipShowCheckmark': chipShowCheckmark,
    };
  }

  /// Creates a copy with selected component settings replaced.
  ThemeJsonComponent copyWith({
    bool? inputFilled,
    bool? appBarCenterTitle,
    bool? chipShowCheckmark,
  }) {
    return ThemeJsonComponent(
      inputFilled: inputFilled ?? this.inputFilled,
      appBarCenterTitle: appBarCenterTitle ?? this.appBarCenterTitle,
      chipShowCheckmark: chipShowCheckmark ?? this.chipShowCheckmark,
    );
  }
}
