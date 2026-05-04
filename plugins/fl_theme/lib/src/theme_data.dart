import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'app_component_theme.dart';
import 'app_decoration_theme.dart';
import 'app_design_system.dart';
import 'app_text_theme.dart';
import 'app_typography_theme.dart';
import 'screen_theme.dart';
import 'theme_color.dart';

/// Builds a legacy [InputDecorationTheme] from semantic colors and text roles.
///
/// Prefer configuring [AppDesignSystem.components] and
/// [AppDesignSystem.decoration] for new code. This callback remains for callers
/// still using [AppTheme.factory] or legacy [AppThemeConfig] fields.
typedef InputDecorationThemeBuilder =
    InputDecorationTheme Function({
      required ThemeColor themeColor,
      required AppTextTheme appTextTheme,
    });

/// Builds a legacy [TextButtonThemeData] from semantic colors and text roles.
typedef TextButtonThemeBuilder =
    TextButtonThemeData Function({
      required AppTextTheme textTheme,
      required ThemeColor themeColor,
    });

/// Builds a legacy [ElevatedButtonThemeData] from semantic colors and text
/// roles.
typedef ElevatedButtonThemeBuilder =
    ElevatedButtonThemeData Function({
      required ThemeColor themeColor,
      required AppTextTheme textTheme,
    });

/// Builds a legacy [OutlinedButtonThemeData] from semantic colors and text
/// roles.
typedef OutlinedButtonThemeBuilder =
    OutlinedButtonThemeData Function({
      required ThemeColor themeColor,
      required AppTextTheme textTheme,
    });

/// Builds a legacy [TabBarThemeData] from semantic colors and text roles.
typedef TabBarThemeBuilder =
    TabBarThemeData Function({
      required AppTextTheme textTheme,
      required ThemeColor themeColor,
    });

/// Builds a legacy [CheckboxThemeData] from semantic colors and text roles.
typedef CheckboxThemeBuilder =
    CheckboxThemeData Function({
      required ThemeColor themeColor,
      required AppTextTheme textTheme,
    });

/// Builds a legacy [MenuThemeData] from semantic colors and text roles.
typedef MenuThemeBuilder =
    MenuThemeData Function({
      required ThemeColor themeColor,
      required AppTextTheme textTheme,
    });

/// Builds a legacy [ChipThemeData] from semantic colors and text roles.
typedef ChipThemeBuilder =
    ChipThemeData Function({
      required ThemeColor themeColor,
      required AppTextTheme textTheme,
    });

/// Configuration used to create an [AppTheme].
///
/// New code should provide [designSystem], which groups colors, typography,
/// screen chrome, decoration tokens, component behavior, FlexColorScheme
/// overrides, platform, Material version, and font family in one reusable
/// object.
///
/// The legacy fields remain supported for existing apps that already pass
/// [screenTheme], [themeColor], an optional [appTextTheme], and component
/// builder callbacks. When [designSystem] is omitted, [AppTheme.create]
/// normalizes those legacy pieces into an [AppDesignSystem] internally.
class AppThemeConfig {
  /// Preferred design-system configuration for generated themes.
  final AppDesignSystem? designSystem;

  /// Legacy screen theme used when [designSystem] is not provided.
  final ScreenTheme? screenTheme;

  /// Legacy semantic colors used when [designSystem] is not provided.
  final ThemeColor? themeColor;

  /// Whether generated themes should use Material 3 defaults.
  final bool useMaterial3;

  /// Optional font family for generated themes.
  final String? fontFamily;

  /// Optional legacy text theme override.
  final AppTextTheme? appTextTheme;

  /// Legacy input decoration builder override.
  final InputDecorationThemeBuilder inputDecorationThemeBuilder;

  /// Legacy text button theme builder override.
  final TextButtonThemeBuilder textButtonThemeBuilder;

  /// Legacy elevated button theme builder override.
  final ElevatedButtonThemeBuilder elevatedButtonThemeBuilder;

  /// Legacy outlined button theme builder override.
  final OutlinedButtonThemeBuilder outlinedButtonThemeBuilder;

  /// Legacy tab bar theme builder override.
  final TabBarThemeBuilder tabBarThemeBuilder;

  /// Legacy checkbox theme builder override.
  final CheckboxThemeBuilder checkboxThemeBuilder;

  /// Legacy menu theme builder override.
  final MenuThemeBuilder menuThemeBuilder;

  /// Legacy chip theme builder override.
  final ChipThemeBuilder chipThemeBuilder;

  /// Optional platform override for generated [ThemeData].
  final TargetPlatform? targetPlatform;

  /// Creates theme configuration from a design system or legacy theme pieces.
  ///
  /// Provide either [designSystem] or both [screenTheme] and [themeColor]. If
  /// both are supplied, [designSystem] wins and legacy builder callbacks are
  /// ignored
  /// for design-system-owned components.
  const AppThemeConfig({
    this.designSystem,
    this.screenTheme,
    this.themeColor,
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
  }) : assert(
         designSystem != null || (screenTheme != null && themeColor != null),
         'Provide designSystem or both screenTheme and themeColor.',
       );
}

/// Material theme wrapper that attaches app semantic theme extensions.
///
/// [AppTheme.create] builds a Flutter [ThemeData] through FlexColorScheme, then
/// applies repo-specific overrides and attaches [ScreenTheme],
/// [ThemeColorExtension], [AppTextThemeExtension], and [AppDecorationTheme].
/// Apps pass [theme] to `MaterialApp.theme` or `MaterialApp.darkTheme`, while
/// [name]
/// is useful for pickers, playgrounds, and debug tooling.
class AppTheme {
  static const double _defaultBorderRadius = 8.0;
  static const Size _minimumButtonSize = Size(88, 40);
  static const EdgeInsets _buttonPadding = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets _inputPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );

  /// Human-readable theme name.
  final String name;

  /// Generated Flutter Material theme data.
  final ThemeData theme;

  /// Creates a named theme wrapper around generated [ThemeData].
  const AppTheme({required this.name, required this.theme});

  /// Creates an app theme from [config].
  ///
  /// The preferred path resolves [AppThemeConfig.designSystem], creates or
  /// reuses its [AppTextTheme], builds Material defaults with FlexColorScheme,
  /// and then attaches the semantic extensions used by `context.themeColor`,
  /// `context.textTheme`, `context.screenTheme`, and `context.decorationTheme`.
  factory AppTheme.create(AppThemeConfig config) {
    final designSystem = _resolveDesignSystem(config);
    final appTextTheme =
        designSystem.textTheme ??
        designSystem.typography.create(designSystem.colors);

    return AppTheme(
      name: designSystem.name,
      theme: _buildThemeData(config, designSystem, appTextTheme),
    );
  }

  /// Creates an app theme from legacy theme pieces.
  ///
  /// Prefer [AppTheme.create] with [AppThemeConfig.designSystem] for new code.
  /// This factory remains a compatibility wrapper for older app code that
  /// passes [ScreenTheme], [ThemeColor], and optional per-component builder
  /// callbacks.
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

  static AppDesignSystem _resolveDesignSystem(AppThemeConfig config) {
    final designSystem = config.designSystem;
    if (designSystem != null) {
      return designSystem;
    }

    final themeColor = config.themeColor!;
    final appTextTheme = config.appTextTheme;
    return AppDesignSystem(
      name: themeColor.brightness.name,
      colors: themeColor,
      screenTheme: config.screenTheme!,
      typography: AppTypographyTheme(
        override: appTextTheme == null ? null : (_) => appTextTheme,
      ),
      textTheme: appTextTheme,
      targetPlatform: config.targetPlatform,
      useMaterial3: config.useMaterial3,
      fontFamily: config.fontFamily,
    );
  }

  static ThemeData _buildThemeData(
    AppThemeConfig config,
    AppDesignSystem designSystem,
    AppTextTheme appTextTheme,
  ) {
    final colors = designSystem.colors;
    final decoration = designSystem.decoration;
    final components = designSystem.components;
    final baseTheme = _buildFlexThemeData(designSystem, appTextTheme);
    final useDesignSystem = config.designSystem != null;

    return baseTheme.copyWith(
      brightness: colors.brightness,
      textTheme: appTextTheme,
      primaryTextTheme: appTextTheme,
      platform: designSystem.targetPlatform,
      primaryColor: colors.themePrimary,
      primaryColorLight: colors.themePrimaryLight,
      primaryColorDark: colors.themePrimaryDark,
      cardColor: colors.cardBackground,
      canvasColor: colors.canvasColor,
      scaffoldBackgroundColor: colors.scaffoldBackgroundColor,
      unselectedWidgetColor: colors.disableColor,
      splashColor: colors.splashColor,
      shadowColor: colors.shadowColor,
      disabledColor: colors.disableColor,
      dividerColor: colors.dividerColor,
      inputDecorationTheme: useDesignSystem
          ? components.inputDecorationTheme(
              colors: colors,
              textTheme: appTextTheme,
              decoration: decoration,
            )
          : config.inputDecorationThemeBuilder(
              themeColor: colors,
              appTextTheme: appTextTheme,
            ),
      textSelectionTheme: _buildTextSelectionTheme(colors),
      buttonTheme: _buildButtonTheme(),
      textButtonTheme: config.textButtonThemeBuilder(
        textTheme: appTextTheme,
        themeColor: colors,
      ),
      elevatedButtonTheme: config.elevatedButtonThemeBuilder(
        textTheme: appTextTheme,
        themeColor: colors,
      ),
      outlinedButtonTheme: config.outlinedButtonThemeBuilder(
        textTheme: appTextTheme,
        themeColor: colors,
      ),
      appBarTheme: _buildAppBarTheme(colors, components),
      tabBarTheme: config.tabBarThemeBuilder(
        textTheme: appTextTheme,
        themeColor: colors,
      ),
      checkboxTheme: useDesignSystem
          ? components.checkboxTheme(colors: colors, decoration: decoration)
          : config.checkboxThemeBuilder(
              themeColor: colors,
              textTheme: appTextTheme,
            ),
      chipTheme: useDesignSystem
          ? components.chipTheme(
              colors: colors,
              textTheme: appTextTheme,
              decoration: decoration,
            )
          : config.chipThemeBuilder(
              themeColor: colors,
              textTheme: appTextTheme,
            ),
      menuTheme: config.menuThemeBuilder(
        themeColor: colors,
        textTheme: appTextTheme,
      ),
      popupMenuTheme: _buildPopupMenuTheme(colors, appTextTheme, decoration),
      menuButtonTheme: _buildMenuButtonTheme(colors, appTextTheme, decoration),
      dividerTheme: _buildDividerTheme(colors, decoration),
      cardTheme: components.cardTheme(colors: colors, decoration: decoration),
      scrollbarTheme: components.scrollbarTheme(
        colors: colors,
        decoration: decoration,
      ),
      dialogTheme: components.dialogTheme(
        colors: colors,
        textTheme: appTextTheme,
        decoration: decoration,
      ),
      bottomSheetTheme: components.bottomSheetTheme(
        colors: colors,
        decoration: decoration,
      ),
      snackBarTheme: components.snackBarTheme(
        colors: colors,
        textTheme: appTextTheme,
        decoration: decoration,
      ),
      listTileTheme: components.listTileTheme(
        colors: colors,
        textTheme: appTextTheme,
        decoration: decoration,
      ),
      iconTheme: components.iconTheme(colors: colors),
      primaryIconTheme: components.iconTheme(colors: colors),
      floatingActionButtonTheme: components.floatingActionButtonTheme(
        colors: colors,
        textTheme: appTextTheme,
        decoration: decoration,
      ),
      navigationBarTheme: components.navigationBarTheme(
        colors: colors,
        textTheme: appTextTheme,
        decoration: decoration,
      ),
      drawerTheme: components.drawerTheme(
        colors: colors,
        decoration: decoration,
      ),
      tooltipTheme: components.tooltipTheme(
        colors: colors,
        textTheme: appTextTheme,
        decoration: decoration,
      ),
      progressIndicatorTheme: components.progressIndicatorTheme(
        colors: colors,
        decoration: decoration,
      ),
      switchTheme: components.switchTheme(colors: colors),
      radioTheme: components.radioTheme(colors: colors),
      colorScheme: _buildColorScheme(colors),
      extensions: [
        designSystem.screenTheme,
        ThemeColorExtension(colors: colors),
        AppTextThemeExtension(textTheme: appTextTheme),
        decoration,
      ],
    );
  }

  static ThemeData _buildFlexThemeData(
    AppDesignSystem designSystem,
    AppTextTheme textTheme,
  ) {
    final colors = designSystem.colors;
    final schemeColor = FlexSchemeColor(
      primary: colors.primary,
      primaryContainer: colors.primaryVariant,
      secondary: colors.secondary,
      secondaryContainer: colors.secondaryVariant,
      tertiary: colors.schemeAction,
      appBarColor: colors.appbarBackgroundColor,
      error: colors.error,
    );
    final subThemesData =
        designSystem.flexSubThemesData ??
        designSystem.components.flexSubThemesData(
          decoration: designSystem.decoration,
          textTheme: textTheme,
        );

    if (colors.brightness == Brightness.dark) {
      return FlexColorScheme.dark(
        colors: designSystem.flexSchemeData?.dark ?? schemeColor,
        subThemesData: subThemesData,
        useMaterial3: designSystem.useMaterial3,
        fontFamily: designSystem.fontFamily,
        textTheme: textTheme,
        primaryTextTheme: textTheme,
        platform: designSystem.targetPlatform,
        scaffoldBackground: colors.scaffoldBackgroundColor,
        appBarBackground: colors.appbarBackgroundColor,
      ).toTheme;
    }

    return FlexColorScheme.light(
      colors: designSystem.flexSchemeData?.light ?? schemeColor,
      subThemesData: subThemesData,
      useMaterial3: designSystem.useMaterial3,
      fontFamily: designSystem.fontFamily,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      platform: designSystem.targetPlatform,
      scaffoldBackground: colors.scaffoldBackgroundColor,
      appBarBackground: colors.appbarBackgroundColor,
    ).toTheme;
  }

  static TextSelectionThemeData _buildTextSelectionTheme(
    ThemeColor themeColor,
  ) {
    return TextSelectionThemeData(
      cursorColor: themeColor.primary,
      selectionColor: themeColor.primary,
      selectionHandleColor: themeColor.primary,
    );
  }

  static ButtonThemeData _buildButtonTheme() {
    return const ButtonThemeData(height: 38);
  }

  static AppBarTheme _buildAppBarTheme(
    ThemeColor themeColor,
    AppComponentTheme components,
  ) {
    return AppBarTheme(
      backgroundColor: themeColor.appbarBackgroundColor ?? themeColor.primary,
      foregroundColor: themeColor.appbarForegroundColor,
      centerTitle: components.appBarCenterTitle,
    );
  }

  static DividerThemeData _buildDividerTheme(
    ThemeColor themeColor,
    AppDecorationTheme decoration,
  ) {
    return DividerThemeData(
      color: themeColor.dividerColor,
      thickness: decoration.borderThin,
      space: decoration.borderThin,
    );
  }

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

  static BorderRadius get _borderRadius =>
      BorderRadius.circular(_defaultBorderRadius);

  /// Builds the default legacy text button theme.
  static TextButtonThemeData buildTextButtonTheme({
    required AppTextTheme textTheme,
    required ThemeColor themeColor,
  }) {
    return TextButtonThemeData(
      style:
          TextButton.styleFrom(
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

  /// Builds the default legacy elevated button theme.
  static ElevatedButtonThemeData buildElevatedButtonTheme({
    required ThemeColor themeColor,
    required AppTextTheme textTheme,
  }) {
    return ElevatedButtonThemeData(
      style:
          ElevatedButton.styleFrom(
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

  /// Builds the default legacy outlined button theme.
  static OutlinedButtonThemeData buildOutlinedButtonTheme({
    required ThemeColor themeColor,
    required AppTextTheme textTheme,
  }) {
    return OutlinedButtonThemeData(
      style:
          OutlinedButton.styleFrom(
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
            side: WidgetStateProperty.resolveWith<BorderSide>((states) {
              final color = states.contains(WidgetState.disabled)
                  ? themeColor.outlineButtonDisableColor
                  : themeColor.outlineButtonColor;
              return BorderSide(color: color, width: 1);
            }),
          ),
    );
  }

  /// Builds the default legacy input decoration theme.
  static InputDecorationTheme buildInputDecorationTheme({
    required ThemeColor themeColor,
    required AppTextTheme appTextTheme,
    BorderRadius? borderRadius,
  }) {
    final bdRadius = borderRadius ?? _borderRadius;

    OutlineInputBorder createInputBorder(
      Color color,
      BorderRadius borderRadius,
    ) {
      return OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 1),
        borderRadius: borderRadius,
      );
    }

    return InputDecorationTheme(
      border: createInputBorder(themeColor.borderColor, bdRadius),
      enabledBorder: createInputBorder(themeColor.borderColor, bdRadius),
      focusedBorder: createInputBorder(themeColor.primary, bdRadius),
      disabledBorder: createInputBorder(themeColor.disableColor, bdRadius),
      errorBorder: createInputBorder(
        appTextTheme.inputError?.color ?? Colors.red,
        bdRadius,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: appTextTheme.inputTitle,
      floatingLabelStyle: appTextTheme.inputTitle,
      contentPadding: _inputPadding,
    );
  }

  /// Builds the default legacy tab bar theme.
  static TabBarThemeData buildTabBarTheme({
    required AppTextTheme textTheme,
    required ThemeColor themeColor,
  }) {
    return TabBarThemeData(
      labelStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.normal,
      ),
      unselectedLabelColor: themeColor.unselectedLabelColor,
      labelColor: themeColor.selectedLabelColor,
      indicatorColor: themeColor.selected,
    );
  }

  /// Builds the default legacy checkbox theme.
  static CheckboxThemeData buildCheckboxTheme({
    required ThemeColor themeColor,
    required AppTextTheme textTheme,
  }) {
    return const AppComponentTheme().checkboxTheme(
      colors: themeColor,
      decoration: const AppDecorationTheme(),
    );
  }

  /// Builds the default legacy chip theme.
  static ChipThemeData buildChipTheme({
    required ThemeColor themeColor,
    required AppTextTheme textTheme,
  }) {
    return const AppComponentTheme().chipTheme(
      colors: themeColor,
      textTheme: textTheme,
      decoration: const AppDecorationTheme(),
    );
  }

  /// Builds the default legacy menu theme.
  static MenuThemeData buildMenuTheme({
    required ThemeColor themeColor,
    required AppTextTheme textTheme,
  }) {
    return MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(themeColor.cardBackground),
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
        maximumSize: WidgetStateProperty.all(const Size(double.infinity, 300)),
        minimumSize: WidgetStateProperty.all(const Size(120, 0)),
      ),
    );
  }

  static PopupMenuThemeData _buildPopupMenuTheme(
    ThemeColor themeColor,
    AppTextTheme textTheme,
    AppDecorationTheme decoration,
  ) {
    return PopupMenuThemeData(
      color: themeColor.cardBackground,
      elevation: decoration.elevationMd,
      shadowColor: themeColor.shadowColor.withValues(alpha: 0.16),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: decoration.radiusMdBorder,
        side: BorderSide(
          color: themeColor.borderColor.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      position: PopupMenuPosition.under,
      textStyle: textTheme.bodyMedium,
    );
  }

  static MenuButtonThemeData _buildMenuButtonTheme(
    ThemeColor themeColor,
    AppTextTheme textTheme,
    AppDecorationTheme decoration,
  ) {
    return MenuButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStateProperty.all(textTheme.bodyMedium),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return themeColor.disableColor;
          }
          if (states.contains(WidgetState.pressed) ||
              states.contains(WidgetState.hovered)) {
            return themeColor.primary;
          }
          return themeColor.textButtonColor;
        }),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.hovered)) {
            return themeColor.primary.withValues(alpha: 0.08);
          }
          if (states.contains(WidgetState.pressed)) {
            return themeColor.primary.withValues(alpha: 0.12);
          }
          return Colors.transparent;
        }),
        overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return themeColor.primary.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return themeColor.primary.withValues(alpha: 0.08);
          }
          return Colors.transparent;
        }),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(
            horizontal: decoration.spaceMd,
            vertical: decoration.spaceSm,
          ),
        ),
        minimumSize: WidgetStateProperty.all(Size(0, decoration.spaceXxl + 4)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: decoration.radiusSmBorder),
        ),
        elevation: WidgetStateProperty.all(decoration.elevationNone),
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  /// Creates a copy with selected theme wrapper values replaced.
  AppTheme copyWith({String? name, ThemeData? theme}) {
    return AppTheme(name: name ?? this.name, theme: theme ?? this.theme);
  }
}
