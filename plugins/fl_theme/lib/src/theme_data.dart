import 'package:flutter/material.dart';

import 'app_text_theme.dart';
import 'screen_theme.dart';
import 'theme_color.dart';

/// Type definitions for theme component builders
typedef InputDecorationThemeBuilder = InputDecorationTheme Function({
  required ThemeColor themeColor,
  required AppTextTheme appTextTheme,
});

typedef TextButtonThemeBuilder = TextButtonThemeData Function({
  required AppTextTheme textTheme,
  required ThemeColor themeColor,
});

typedef ElevatedButtonThemeBuilder = ElevatedButtonThemeData Function({
  required ThemeColor themeColor,
  required AppTextTheme textTheme,
});

typedef OutlinedButtonThemeBuilder = OutlinedButtonThemeData Function({
  required ThemeColor themeColor,
  required AppTextTheme textTheme,
});

typedef TabBarThemeBuilder = TabBarThemeData Function({
  required AppTextTheme textTheme,
  required ThemeColor themeColor,
});

typedef CheckboxThemeBuilder = CheckboxThemeData Function({
  required ThemeColor themeColor,
  required AppTextTheme textTheme,
});

typedef MenuThemeBuilder = MenuThemeData Function({
  required ThemeColor themeColor,
  required AppTextTheme textTheme,
});

typedef ChipThemeBuilder = ChipThemeData Function({
  required ThemeColor themeColor,
  required AppTextTheme textTheme,
});

/// Configuration class for creating AppTheme instances
///
/// This class encapsulates all the configuration options needed to create
/// a consistent theme across the application. It provides a cleaner API
/// by grouping related parameters and setting sensible defaults.
///
/// Example usage:
/// ```dart
/// final config = AppThemeConfig(
///   screenTheme: myScreenTheme,
///   themeColor: myThemeColor,
///   fontFamily: 'Poppins',
/// );
/// final appTheme = AppTheme.create(config);
/// ```
class AppThemeConfig {
  /// Screen-specific theme configuration for different device sizes
  final ScreenTheme screenTheme;

  /// Color palette and theme colors for the application
  final ThemeColor themeColor;

  /// Whether to use Material 3 design system
  final bool useMaterial3;

  /// Default font family for the application
  final String? fontFamily;

  /// Pre-configured text theme, if null will be created from themeColor
  final AppTextTheme? appTextTheme;

  /// Custom input decoration theme builder
  final InputDecorationThemeBuilder inputDecorationThemeBuilder;

  /// Custom text button theme builder
  final TextButtonThemeBuilder textButtonThemeBuilder;

  /// Custom elevated button theme builder
  final ElevatedButtonThemeBuilder elevatedButtonThemeBuilder;

  /// Custom outlined button theme builder
  final OutlinedButtonThemeBuilder outlinedButtonThemeBuilder;

  /// Custom tab bar theme builder
  final TabBarThemeBuilder tabBarThemeBuilder;

  /// Custom checkbox theme builder
  final CheckboxThemeBuilder checkboxThemeBuilder;

  /// Custom menu theme builder
  final MenuThemeBuilder menuThemeBuilder;

  /// Custom chip theme builder
  final ChipThemeBuilder chipThemeBuilder;

  /// Target platform for platform-specific theming
  final TargetPlatform? targetPlatform;

  const AppThemeConfig({
    required this.screenTheme,
    required this.themeColor,
    this.useMaterial3 = true,
    this.fontFamily,
    this.appTextTheme,
    this.inputDecorationThemeBuilder = AppTheme.buildInputDecorationTheme,
    this.textButtonThemeBuilder = AppTheme.buildTextButtonTheme,
    this.elevatedButtonThemeBuilder = AppTheme.buildElevatedButtonTheme,
    this.outlinedButtonThemeBuilder = AppTheme.buildOutlinedButtonTheme,
    this.tabBarThemeBuilder = AppTheme.buildTabBarTheme,
    this.checkboxThemeBuilder = AppTheme.buildCheckboxTheme,
    this.menuThemeBuilder = AppTheme.buildMenuTheme,
    this.chipThemeBuilder = AppTheme.buildChipTheme,
    this.targetPlatform,
  });
}

/// A comprehensive theme wrapper that provides a complete Flutter ThemeData
/// with consistent styling for all UI components.
///
/// This class serves as the main entry point for theme creation in the
/// application. It combines various theme components
/// (colors, text styles, component themes) into a cohesive design system.
///
/// Features:
/// - Consistent color palette across all components
/// - Standardized text styles and typography
/// - Material Design 3 support
/// - Platform-specific adaptations
/// - Customizable component themes
/// - Extension-based theme data for custom components
///
/// Usage:
/// ```dart
/// // Using the simplified factory
/// final theme = AppTheme.create(AppThemeConfig(
///   screenTheme: screenTheme,
///   themeColor: themeColor,
/// ));
///
/// // Using the legacy factory for backward compatibility
/// final theme = AppTheme.factory(
///   screenTheme: screenTheme,
///   themeColor: themeColor,
///   useMaterial3: true,
/// );
/// ```
class AppTheme {
  // Design constants for consistent UI elements
  static const double _defaultBorderRadius = 8.0;
  static const Size _minimumButtonSize = Size(88, 40);
  static const EdgeInsets _buttonPadding = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets _inputPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );

  /// Human-readable name for the theme (e.g., "light", "dark")
  final String name;

  /// The complete Flutter theme data
  final ThemeData theme;

  const AppTheme({
    required this.name,
    required this.theme,
  });

  /// Primary factory method for creating AppTheme instances
  ///
  /// This method uses the configuration pattern to create themes with
  /// sensible defaults while allowing full customization when needed.
  ///
  /// [config] - Configuration object containing all theme parameters
  ///
  /// Returns an [AppTheme] instance with the specified configuration
  factory AppTheme.create(AppThemeConfig config) {
    final appTextTheme =
        config.appTextTheme ?? AppTextTheme.create(config.themeColor);
    final brightness = config.themeColor.brightness;

    return AppTheme(
      name: brightness.name,
      theme: _buildThemeData(config, appTextTheme),
    );
  }

  /// Legacy factory method for backward compatibility
  ///
  /// This method maintains the original API while internally using
  /// the new configuration-based approach. Use [AppTheme.create] for new code.
  ///
  /// @deprecated Use [AppTheme.create] with [AppThemeConfig] instead
  factory AppTheme.factory({
    required ScreenTheme screenTheme,
    required ThemeColor themeColor,
    bool useMaterial3 = true,
    String? fontFamily,
    AppTextTheme? appTextTheme,
    InputDecorationThemeBuilder inputDecorationThemeBuilder =
        AppTheme.buildInputDecorationTheme,
    TextButtonThemeBuilder textButtonThemeBuilder =
        AppTheme.buildTextButtonTheme,
    ElevatedButtonThemeBuilder elevatedButtonThemeBuilder =
        AppTheme.buildElevatedButtonTheme,
    OutlinedButtonThemeBuilder outlinedButtonThemeBuilder =
        AppTheme.buildOutlinedButtonTheme,
    TabBarThemeBuilder tabBarThemeBuilder = AppTheme.buildTabBarTheme,
    CheckboxThemeBuilder checkboxThemeBuilder = AppTheme.buildCheckboxTheme,
    MenuThemeBuilder menuThemeBuilder = AppTheme.buildMenuTheme,
    ChipThemeBuilder chipThemeBuilder = AppTheme.buildChipTheme,
    TargetPlatform? targetPlatform,
  }) {
    return AppTheme.create(
      AppThemeConfig(
        screenTheme: screenTheme,
        themeColor: themeColor,
        useMaterial3: useMaterial3,
        fontFamily: fontFamily,
        appTextTheme: appTextTheme,
        inputDecorationThemeBuilder: inputDecorationThemeBuilder,
        textButtonThemeBuilder: textButtonThemeBuilder,
        elevatedButtonThemeBuilder: elevatedButtonThemeBuilder,
        outlinedButtonThemeBuilder: outlinedButtonThemeBuilder,
        tabBarThemeBuilder: tabBarThemeBuilder,
        checkboxThemeBuilder: checkboxThemeBuilder,
        menuThemeBuilder: menuThemeBuilder,
        chipThemeBuilder: chipThemeBuilder,
        targetPlatform: targetPlatform,
      ),
    );
  }

  /// Builds the complete ThemeData from configuration and text theme
  ///
  /// This method orchestrates the creation of all theme components:
  /// - Basic theme properties (colors, fonts, platform)
  /// - Component-specific themes (buttons, inputs, app bar, etc.)
  /// - Theme extensions for custom components
  ///
  /// [config] - Theme configuration containing all settings
  /// [appTextTheme] - Text theme to be used throughout the app
  ///
  /// Returns a complete [ThemeData] instance
  static ThemeData _buildThemeData(
    AppThemeConfig config,
    AppTextTheme appTextTheme,
  ) {
    return ThemeData(
      // Core theme properties
      brightness: config.themeColor.brightness,
      fontFamily: config.fontFamily,
      textTheme: appTextTheme,
      useMaterial3: config.useMaterial3,
      platform: config.targetPlatform,

      // Color properties
      primaryColor: config.themeColor.themePrimary,
      primaryColorLight: config.themeColor.themePrimaryLight,
      primaryColorDark: config.themeColor.themePrimaryDark,
      cardColor: config.themeColor.cardBackground,
      canvasColor: config.themeColor.canvasColor,
      scaffoldBackgroundColor: config.themeColor.scaffoldBackgroundColor,
      unselectedWidgetColor: config.themeColor.disableColor,
      splashColor: config.themeColor.splashColor,
      shadowColor: config.themeColor.shadowColor,
      disabledColor: config.themeColor.disableColor,
      dividerColor: config.themeColor.dividerColor,

      // Component themes - using builder pattern for customization
      inputDecorationTheme: config.inputDecorationThemeBuilder(
        themeColor: config.themeColor,
        appTextTheme: appTextTheme,
      ),
      textSelectionTheme: _buildTextSelectionTheme(config.themeColor),
      buttonTheme: _buildButtonTheme(),
      textButtonTheme: config.textButtonThemeBuilder(
        textTheme: appTextTheme,
        themeColor: config.themeColor,
      ),
      elevatedButtonTheme: config.elevatedButtonThemeBuilder(
        textTheme: appTextTheme,
        themeColor: config.themeColor,
      ),
      outlinedButtonTheme: config.outlinedButtonThemeBuilder(
        textTheme: appTextTheme,
        themeColor: config.themeColor,
      ),
      appBarTheme: _buildAppBarTheme(config.themeColor),
      tabBarTheme: config.tabBarThemeBuilder(
        textTheme: appTextTheme,
        themeColor: config.themeColor,
      ),
      checkboxTheme: config.checkboxThemeBuilder(
        themeColor: config.themeColor,
        textTheme: appTextTheme,
      ),
      chipTheme: config.chipThemeBuilder(
        themeColor: config.themeColor,
        textTheme: appTextTheme,
      ),
      menuTheme: config.menuThemeBuilder(
        themeColor: config.themeColor,
        textTheme: appTextTheme,
      ),
      popupMenuTheme: _buildPopupMenuTheme(config.themeColor, appTextTheme),
      menuButtonTheme: _buildMenuButtonTheme(config.themeColor, appTextTheme),
      dividerTheme: _buildDividerTheme(config.themeColor),
      colorScheme: _buildColorScheme(config.themeColor),

      // Theme extensions for custom components
      extensions: [
        config.screenTheme,
        ThemeColorExtension(colors: config.themeColor),
        AppTextThemeExtension(textTheme: appTextTheme),
      ],
    );
  }

  /// Creates text selection theme for consistent cursor and selection colors
  static TextSelectionThemeData _buildTextSelectionTheme(
    ThemeColor themeColor,
  ) {
    return TextSelectionThemeData(
      cursorColor: themeColor.primary,
      selectionColor: themeColor.primary,
      selectionHandleColor: themeColor.primary,
    );
  }

  /// Creates basic button theme with standard height
  static ButtonThemeData _buildButtonTheme() {
    return const ButtonThemeData(height: 38);
  }

  /// Creates app bar theme with background and foreground colors
  static AppBarTheme _buildAppBarTheme(ThemeColor themeColor) {
    return AppBarTheme(
      backgroundColor: themeColor.appbarBackgroundColor ?? themeColor.primary,
      foregroundColor: themeColor.appbarForegroundColor,
      centerTitle: true,
    );
  }

  /// Creates divider theme with consistent styling
  static DividerThemeData _buildDividerTheme(ThemeColor themeColor) {
    return DividerThemeData(
      color: themeColor.dividerColor,
      thickness: 1,
      space: 1,
    );
  }

  /// Creates Material 3 color scheme from theme colors
  static ColorScheme _buildColorScheme(ThemeColor themeColor) {
    return ColorScheme(
      primary: themeColor.primary,
      primaryContainer: themeColor.primaryVariant,
      secondary: themeColor.secondary,
      secondaryContainer: themeColor.secondaryVariant,
      surface: themeColor.surface,
      error: themeColor.error,
      onPrimary: themeColor.onPrimary,
      onSecondary: themeColor.onSecondary,
      onSurface: themeColor.onSurface,
      onError: themeColor.onError,
      brightness: themeColor.brightness,
    );
  }

  /// Standard border radius for consistent UI elements
  static BorderRadius get _borderRadius =>
      BorderRadius.circular(_defaultBorderRadius);

  /// Creates text button theme with proper state management
  ///
  /// Configures text buttons with:
  /// - Consistent text styling
  /// - State-based color resolution
  /// - Standard sizing and padding
  /// - Rounded corners
  static TextButtonThemeData buildTextButtonTheme({
    required AppTextTheme textTheme,
    required ThemeColor themeColor,
  }) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: textTheme.buttonText,
        minimumSize: _minimumButtonSize,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
      ).copyWith(
        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.disabled)
              ? themeColor.textButtonDisableColor
              : themeColor.textButtonColor,
        ),
      ),
    );
  }

  /// Creates elevated button theme with background and foreground colors
  ///
  /// Configures elevated buttons with:
  /// - Disabled state handling
  /// - Consistent elevation and shadows
  /// - State-based color resolution
  /// - Standard sizing and padding
  static ElevatedButtonThemeData buildElevatedButtonTheme({
    required ThemeColor themeColor,
    required AppTextTheme textTheme,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        disabledForegroundColor: themeColor.disableColor,
        textStyle: textTheme.buttonText,
        minimumSize: _minimumButtonSize,
        padding: _buttonPadding,
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        elevation: 0,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ).copyWith(
        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.disabled)
              ? themeColor.elevatedBtnForegroundDisableColor
              : themeColor.elevatedBtnForegroundColor,
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.disabled)
              ? themeColor.elevatedBtnBackgroundDisableColor
              : themeColor.elevatedBtnBackgroundColor,
        ),
      ),
    );
  }

  /// Creates outlined button theme with borders and state management
  ///
  /// Configures outlined buttons with:
  /// - State-dependent border colors
  /// - Background color handling
  /// - Consistent styling with other buttons
  static OutlinedButtonThemeData buildOutlinedButtonTheme({
    required ThemeColor themeColor,
    required AppTextTheme textTheme,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: _minimumButtonSize,
        padding: _buttonPadding,
        textStyle: textTheme.buttonText,
        shadowColor: themeColor.splashColor,
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ).copyWith(
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.disabled)
              ? themeColor.outlineButtonDisableColor
              : themeColor.outlineButtonColor,
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) => themeColor.outlineButtonBackgroundColor,
        ),
        side: WidgetStateProperty.resolveWith<BorderSide>(
          (states) {
            final color = states.contains(WidgetState.disabled)
                ? themeColor.outlineButtonDisableColor
                : themeColor.outlineButtonColor;
            return BorderSide(color: color, width: 1);
          },
        ),
      ),
    );
  }

  /// Creates input decoration theme for form fields
  ///
  /// Configures text fields with:
  /// - Consistent border styles for all states
  /// - Proper label behavior
  /// - Error state styling
  /// - Standard padding
  static InputDecorationTheme buildInputDecorationTheme({
    required ThemeColor themeColor,
    required AppTextTheme appTextTheme,
    BorderRadius? borderRadius,
  }) {
    final bdRadius = borderRadius ?? _borderRadius;

    /// Helper method to create consistent input field borders
    OutlineInputBorder _createInputBorder(
      Color color,
      BorderRadius borderRadius,
    ) {
      return OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 1),
        borderRadius: borderRadius,
      );
    }

    return InputDecorationTheme(
      border: _createInputBorder(themeColor.borderColor, bdRadius),
      enabledBorder: _createInputBorder(themeColor.borderColor, bdRadius),
      focusedBorder: _createInputBorder(themeColor.primary, bdRadius),
      disabledBorder: _createInputBorder(themeColor.disableColor, bdRadius),
      errorBorder: _createInputBorder(
        appTextTheme.inputError?.color ?? Colors.red,
        bdRadius,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: appTextTheme.inputTitle,
      floatingLabelStyle: appTextTheme.inputTitle,
      contentPadding: _inputPadding,
    );
  }

  /// Creates tab bar theme with label styling and indicator colors
  static TabBarThemeData buildTabBarTheme({
    required AppTextTheme textTheme,
    required ThemeColor themeColor,
  }) {
    return TabBarThemeData(
      labelStyle: textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.normal,
      ),
      unselectedLabelColor: themeColor.unselectedLabelColor,
      labelColor: themeColor.selectedLabelColor,
      indicatorColor: themeColor.selected,
    );
  }

  /// Creates checkbox theme with state-based styling
  ///
  /// Configures checkboxes with:
  /// - State-dependent fill colors
  /// - Consistent check marks and borders
  /// - Hover and focus state styling
  /// - Material state overlays
  static CheckboxThemeData buildCheckboxTheme({
    required ThemeColor themeColor,
    required AppTextTheme textTheme,
  }) {
    return CheckboxThemeData(
      checkColor: WidgetStateProperty.resolveWith<Color?>((states) {
        // Color of the check mark inside the checkbox
        if (states.contains(WidgetState.disabled)) {
          return themeColor.checkboxCheckColor.withValues(alpha: 0.5);
        }
        return themeColor.checkboxCheckColor;
      }),
      fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
        // Background color of the checkbox
        if (states.contains(WidgetState.disabled)) {
          return themeColor.checkboxDisabledColor;
        }
        if (states.contains(WidgetState.selected)) {
          return themeColor.checkboxActiveColor;
        }
        return Colors.transparent;
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        // Hover/ripple effect color
        if (states.contains(WidgetState.pressed)) {
          return themeColor.checkboxActiveColor.withValues(alpha: 0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return themeColor.checkboxActiveColor.withValues(alpha: 0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return themeColor.checkboxActiveColor.withValues(alpha: 0.12);
        }
        return null;
      }),
      side: WidgetStateBorderSide.resolveWith((states) {
        // Border styling for unchecked state
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(
            color: themeColor.checkboxDisabledColor,
            width: 1,
          );
        }
        if (states.contains(WidgetState.selected)) {
          return BorderSide(
            color: themeColor.checkboxActiveColor,
            width: 1,
          );
        }
        return BorderSide(
          color: themeColor.checkboxBorderColor,
          width: 1,
        );
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  /// Creates chip theme for Chip widgets
  ///
  /// Configures chips with:
  /// - Consistent background and border colors
  /// - State-based styling for selection and disabled states
  /// - Proper text styling for chip labels
  /// - Material elevation and rounded borders
  /// - Hover and press state effects
  static ChipThemeData buildChipTheme({
    required ThemeColor themeColor,
    required AppTextTheme textTheme,
  }) {
    return ChipThemeData(
      backgroundColor: themeColor.chipBackgroundColor,
      disabledColor: themeColor.chipDisabledColor,
      selectedColor: themeColor.chipSelectedColor,
      secondarySelectedColor: themeColor.chipSelectedColor.withValues(
        alpha: 0.12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: themeColor.chipLabelColor,
      ),
      secondaryLabelStyle: textTheme.bodySmall?.copyWith(
        color: themeColor.chipLabelColor,
      ),
      brightness: themeColor.brightness,
      elevation: 0,
      pressElevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: themeColor.chipBorderColor,
          width: 1,
        ),
      ),
      selectedShadowColor: Colors.transparent,
      showCheckmark: true,
      checkmarkColor: themeColor.checkboxCheckColor,
      deleteIconColor: themeColor.deleteIconColor,
      iconTheme: IconThemeData(
        color: themeColor.chipLabelColor,
        size: 18,
      ),
    );
  }

  /// Creates menu theme for context menus, dropdowns, and popup menus
  ///
  /// Configures menus based on the design with:
  /// - Consistent background colors and shadows
  /// - Proper text styling for menu items
  /// - State-based styling for selection and hover
  /// - Material elevation and border radius
  /// - Comprehensive styling for MenuAnchor, DropdownMenu, and PopupMenuButton
  static MenuThemeData buildMenuTheme({
    required ThemeColor themeColor,
    required AppTextTheme textTheme,
  }) {
    return MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(
          themeColor.cardBackground,
        ),
        elevation: WidgetStateProperty.all(8.0),
        shadowColor: WidgetStateProperty.all(
          themeColor.shadowColor.withValues(alpha: 0.16),
        ),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_defaultBorderRadius),
            side: BorderSide(
              color: themeColor.borderColor.withValues(alpha: 0.12),
              width: 0.5,
            ),
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 8.0),
        ),
        maximumSize: WidgetStateProperty.all(
          const Size(double.infinity, 300),
        ),
        minimumSize: WidgetStateProperty.all(
          const Size(120, 0),
        ),
      ),
    );
  }

  /// Creates popup menu theme for PopupMenuButton widgets
  ///
  /// Configures popup menus with consistent styling that complements
  /// the main menu theme, specifically for traditional popup menu buttons.
  static PopupMenuThemeData _buildPopupMenuTheme(
    ThemeColor themeColor,
    AppTextTheme textTheme,
  ) {
    return PopupMenuThemeData(
      color: themeColor.cardBackground,
      elevation: 8.0,
      shadowColor: themeColor.shadowColor.withValues(alpha: 0.16),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_defaultBorderRadius),
        side: BorderSide(
          color: themeColor.borderColor.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      position: PopupMenuPosition.under,
      textStyle: textTheme.bodyMedium,
    );
  }

  /// Creates menu button theme for MenuAnchor and related button widgets
  ///
  /// Provides consistent styling for buttons that trigger menus,
  /// ensuring visual harmony between menu triggers and menu content.
  static MenuButtonThemeData _buildMenuButtonTheme(
    ThemeColor themeColor,
    AppTextTheme textTheme,
  ) {
    return MenuButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStateProperty.all(textTheme.bodyMedium),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return themeColor.disableColor;
            }
            if (states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.hovered)) {
              return themeColor.primary;
            }
            return themeColor.textButtonColor;
          },
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.hovered)) {
              return themeColor.primary.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.pressed)) {
              return themeColor.primary.withValues(alpha: 0.12);
            }
            return Colors.transparent;
          },
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return themeColor.primary.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return themeColor.primary.withValues(alpha: 0.08);
            }
            return Colors.transparent;
          },
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        minimumSize: WidgetStateProperty.all(const Size(0, 36)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        elevation: WidgetStateProperty.all(0),
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  /// Creates a copy of this theme with optional modifications
  ///
  /// Useful for creating theme variations or overriding specific properties
  /// while maintaining the rest of the theme configuration.
  AppTheme copyWith({
    String? name,
    ThemeData? theme,
  }) {
    return AppTheme(
      name: name ?? this.name,
      theme: theme ?? this.theme,
    );
  }
}
