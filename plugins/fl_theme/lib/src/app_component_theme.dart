import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'app_decoration_theme.dart';
import 'app_text_theme.dart';
import 'json/theme_json_component.dart';
import 'theme_color.dart';

/// Configures Material component behavior that belongs to the design system.
///
/// `AppComponentTheme` captures the small set of component decisions this
/// plugin owns directly. Broader Material defaults still come from
/// FlexColorScheme, and
/// these values are passed into Flex sub-theme data or post-processed component
/// themes where the app needs semantic colors and decoration tokens.
class AppComponentTheme {
  /// Whether input decorations should render with a filled background.
  final bool inputFilled;

  /// Whether app bar titles should be centered by default.
  final bool appBarCenterTitle;

  /// Whether selectable chips should show Material checkmarks.
  final bool chipShowCheckmark;

  /// Creates component defaults for generated app themes.
  const AppComponentTheme({
    this.inputFilled = false,
    this.appBarCenterTitle = true,
    this.chipShowCheckmark = true,
  });

  /// Creates component settings from a JSON theme component section.
  factory AppComponentTheme.fromJsonConfig(ThemeJsonComponent config) {
    return AppComponentTheme(
      inputFilled: config.inputFilled,
      appBarCenterTitle: config.appBarCenterTitle,
      chipShowCheckmark: config.chipShowCheckmark,
    );
  }

  /// Converts these component settings to their JSON DTO.
  ThemeJsonComponent toJsonConfig() {
    return ThemeJsonComponent(
      inputFilled: inputFilled,
      appBarCenterTitle: appBarCenterTitle,
      chipShowCheckmark: chipShowCheckmark,
    );
  }

  /// Creates FlexColorScheme sub-theme settings from app design tokens.
  ///
  /// This is used before `FlexColorScheme.toTheme` so generated Material
  /// widgets
  /// pick up the same radius, padding, border, and typography decisions exposed
  /// through [AppDecorationTheme] and [AppTextTheme].
  FlexSubThemesData flexSubThemesData({
    required AppDecorationTheme decoration,
    required AppTextTheme textTheme,
  }) {
    return FlexSubThemesData(
      defaultRadius: decoration.radiusMd,
      buttonMinSize: decoration.buttonMinSize,
      buttonPadding: decoration.buttonPadding,
      thinBorderWidth: decoration.borderThin,
      thickBorderWidth: decoration.borderRegular,
      textButtonRadius: decoration.buttonRadius,
      elevatedButtonRadius: decoration.buttonRadius,
      elevatedButtonElevation: decoration.elevationNone,
      outlinedButtonRadius: decoration.buttonRadius,
      inputDecoratorRadius: decoration.inputRadius,
      inputDecoratorContentPadding: decoration.inputPadding,
      inputDecoratorIsFilled: inputFilled,
      checkboxSchemeColor: SchemeColor.primary,
      chipRadius: decoration.chipRadius,
      chipPadding: decoration.chipPadding,
      chipLabelStyle: textTheme.bodyMedium,
      chipSecondaryLabelStyle: textTheme.bodySmall,
      appBarCenterTitle: appBarCenterTitle,
      useMaterial3Typography: true,
    );
  }

  /// Builds the app input decoration theme from semantic colors and tokens.
  InputDecorationTheme inputDecorationTheme({
    required ThemeColor colors,
    required AppTextTheme textTheme,
    required AppDecorationTheme decoration,
  }) {
    OutlineInputBorder border(Color color) {
      return OutlineInputBorder(
        borderSide: BorderSide(color: color, width: decoration.borderThin),
        borderRadius: decoration.inputRadiusBorder,
      );
    }

    return InputDecorationTheme(
      border: border(colors.borderColor),
      enabledBorder: border(colors.borderColor),
      focusedBorder: border(colors.primary),
      disabledBorder: border(colors.disableColor),
      errorBorder: border(textTheme.inputError?.color ?? colors.error),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: textTheme.inputTitle,
      floatingLabelStyle: textTheme.inputTitle,
      contentPadding: decoration.inputPadding,
      filled: inputFilled,
      fillColor: inputFilled ? colors.surface : null,
    );
  }

  /// Builds the checkbox theme from semantic colors and tokens.
  CheckboxThemeData checkboxTheme({
    required ThemeColor colors,
    required AppDecorationTheme decoration,
  }) {
    return CheckboxThemeData(
      checkColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.checkboxCheckColor.withValues(alpha: 0.5);
        }
        return colors.checkboxCheckColor;
      }),
      fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.checkboxDisabledColor;
        }
        if (states.contains(WidgetState.selected)) {
          return colors.checkboxActiveColor;
        }
        return Colors.transparent;
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return colors.checkboxActiveColor.withValues(alpha: 0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.checkboxActiveColor.withValues(alpha: 0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return colors.checkboxActiveColor.withValues(alpha: 0.12);
        }
        return null;
      }),
      side: WidgetStateBorderSide.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(
            color: colors.checkboxDisabledColor,
            width: decoration.borderThin,
          );
        }
        if (states.contains(WidgetState.selected)) {
          return BorderSide(
            color: colors.checkboxActiveColor,
            width: decoration.borderThin,
          );
        }
        return BorderSide(
          color: colors.checkboxBorderColor,
          width: decoration.borderThin,
        );
      }),
      shape: RoundedRectangleBorder(borderRadius: decoration.radiusXsBorder),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  /// Builds the chip theme from semantic colors and tokens.
  ChipThemeData chipTheme({
    required ThemeColor colors,
    required AppTextTheme textTheme,
    required AppDecorationTheme decoration,
  }) {
    return ChipThemeData(
      backgroundColor: colors.chipBackgroundColor,
      disabledColor: colors.chipDisabledColor,
      selectedColor: colors.chipSelectedColor,
      secondarySelectedColor: colors.chipSelectedColor.withValues(alpha: 0.12),
      padding: decoration.chipPadding,
      labelStyle: textTheme.bodyMedium?.copyWith(color: colors.chipLabelColor),
      secondaryLabelStyle: textTheme.bodySmall?.copyWith(
        color: colors.chipLabelColor,
      ),
      brightness: colors.brightness,
      elevation: decoration.elevationNone,
      pressElevation: decoration.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: decoration.chipRadiusBorder,
        side: BorderSide(
          color: colors.chipBorderColor,
          width: decoration.borderThin,
        ),
      ),
      selectedShadowColor: Colors.transparent,
      showCheckmark: chipShowCheckmark,
      checkmarkColor: colors.checkboxCheckColor,
      deleteIconColor: colors.deleteIconColor,
      iconTheme: IconThemeData(color: colors.chipLabelColor, size: 18),
    );
  }

  /// Builds the card theme from semantic colors and decoration tokens.
  CardThemeData cardTheme({
    required ThemeColor colors,
    required AppDecorationTheme decoration,
  }) {
    return CardThemeData(
      clipBehavior: Clip.antiAlias,
      color: colors.cardBackground,
      shadowColor: colors.shadowColor.withValues(alpha: 0.16),
      surfaceTintColor: Colors.transparent,
      elevation: decoration.elevationSm,
      margin: EdgeInsets.all(decoration.spaceSm),
      shape: RoundedRectangleBorder(
        borderRadius: decoration.radiusLgBorder,
        side: BorderSide(
          color: colors.borderColor.withValues(alpha: 0.12),
          width: decoration.borderThin,
        ),
      ),
    );
  }

  /// Builds the scrollbar theme from semantic colors and spacing tokens.
  ScrollbarThemeData scrollbarTheme({
    required ThemeColor colors,
    required AppDecorationTheme decoration,
  }) {
    return ScrollbarThemeData(
      radius: Radius.circular(decoration.radiusPill),
      thickness: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.dragged)) {
          return decoration.spaceSm;
        }
        return decoration.spaceXs;
      }),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        final alpha = states.contains(WidgetState.dragged) ? 0.72 : 0.48;
        return colors.primary.withValues(alpha: alpha);
      }),
      trackColor: WidgetStateProperty.all(
        colors.surface.withValues(alpha: 0.32),
      ),
      trackBorderColor: WidgetStateProperty.all(Colors.transparent),
      minThumbLength: decoration.spaceXxl,
      interactive: true,
    );
  }

  /// Builds the dialog theme from semantic colors, text roles, and tokens.
  DialogThemeData dialogTheme({
    required ThemeColor colors,
    required AppTextTheme textTheme,
    required AppDecorationTheme decoration,
  }) {
    return DialogThemeData(
      backgroundColor: colors.cardBackground,
      elevation: decoration.elevationMd,
      shadowColor: colors.shadowColor.withValues(alpha: 0.2),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: decoration.radiusXlBorder),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
      iconColor: colors.primary,
      actionsPadding: EdgeInsets.all(decoration.spaceLg),
      insetPadding: EdgeInsets.all(decoration.screenPadding),
      clipBehavior: Clip.antiAlias,
    );
  }

  /// Builds the bottom sheet theme from semantic colors and radius tokens.
  BottomSheetThemeData bottomSheetTheme({
    required ThemeColor colors,
    required AppDecorationTheme decoration,
  }) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(decoration.radiusXl),
      ),
    );
    return BottomSheetThemeData(
      backgroundColor: colors.cardBackground,
      modalBackgroundColor: colors.cardBackground,
      surfaceTintColor: Colors.transparent,
      elevation: decoration.elevationMd,
      modalElevation: decoration.elevationMd,
      shadowColor: colors.shadowColor.withValues(alpha: 0.2),
      modalBarrierColor: Colors.black.withValues(alpha: 0.48),
      shape: shape,
      showDragHandle: true,
      dragHandleColor: colors.borderColor,
      clipBehavior: Clip.antiAlias,
    );
  }

  /// Builds the snackbar theme from semantic colors, text roles, and tokens.
  SnackBarThemeData snackBarTheme({
    required ThemeColor colors,
    required AppTextTheme textTheme,
    required AppDecorationTheme decoration,
  }) {
    return SnackBarThemeData(
      backgroundColor: colors.onSurface,
      actionTextColor: colors.primary,
      disabledActionTextColor: colors.disableColor,
      closeIconColor: colors.surface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: colors.surface),
      elevation: decoration.elevationMd,
      shape: RoundedRectangleBorder(borderRadius: decoration.radiusMdBorder),
      behavior: SnackBarBehavior.floating,
      insetPadding: EdgeInsets.all(decoration.spaceLg),
    );
  }

  /// Builds list tile defaults from semantic text and color roles.
  ListTileThemeData listTileTheme({
    required ThemeColor colors,
    required AppTextTheme textTheme,
    required AppDecorationTheme decoration,
  }) {
    return ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: decoration.radiusMdBorder),
      selectedColor: colors.primary,
      iconColor: colors.labelText,
      textColor: colors.bodyText,
      titleTextStyle: textTheme.titleMedium,
      subtitleTextStyle: textTheme.bodySmall?.copyWith(color: colors.labelText),
      leadingAndTrailingTextStyle: textTheme.labelMedium,
      contentPadding: EdgeInsets.symmetric(horizontal: decoration.spaceLg),
      tileColor: Colors.transparent,
      selectedTileColor: colors.primary.withValues(alpha: 0.08),
      horizontalTitleGap: decoration.spaceMd,
      minVerticalPadding: decoration.spaceSm,
      visualDensity: VisualDensity.compact,
    );
  }

  /// Builds app-wide icon defaults from semantic color roles.
  IconThemeData iconTheme({required ThemeColor colors}) {
    return IconThemeData(color: colors.labelText, size: 24);
  }

  /// Builds floating action button defaults from semantic colors and tokens.
  FloatingActionButtonThemeData floatingActionButtonTheme({
    required ThemeColor colors,
    required AppTextTheme textTheme,
    required AppDecorationTheme decoration,
  }) {
    return FloatingActionButtonThemeData(
      foregroundColor: colors.onPrimary,
      backgroundColor: colors.primary,
      focusColor: colors.primary.withValues(alpha: 0.12),
      hoverColor: colors.primary.withValues(alpha: 0.08),
      splashColor: colors.splashColor.withValues(alpha: 0.16),
      elevation: decoration.elevationSm,
      focusElevation: decoration.elevationMd,
      hoverElevation: decoration.elevationMd,
      highlightElevation: decoration.elevationMd,
      disabledElevation: decoration.elevationNone,
      shape: RoundedRectangleBorder(
        borderRadius: decoration.buttonRadiusBorder,
      ),
      iconSize: 24,
      extendedPadding: decoration.buttonPadding,
      extendedTextStyle: textTheme.buttonText,
    );
  }

  /// Builds navigation bar defaults from semantic colors and text roles.
  NavigationBarThemeData navigationBarTheme({
    required ThemeColor colors,
    required AppTextTheme textTheme,
    required AppDecorationTheme decoration,
  }) {
    return NavigationBarThemeData(
      height: decoration.spaceXxl + 48,
      backgroundColor: colors.cardBackground,
      elevation: decoration.elevationNone,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      indicatorColor: colors.primary.withValues(alpha: 0.12),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: decoration.radiusPillBorder,
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final color = states.contains(WidgetState.selected)
            ? colors.primary
            : colors.labelText;
        return textTheme.labelMedium?.copyWith(color: color);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final color = states.contains(WidgetState.selected)
            ? colors.primary
            : colors.labelText;
        return IconThemeData(color: color, size: 24);
      }),
      overlayColor: WidgetStateProperty.all(
        colors.primary.withValues(alpha: 0.08),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    );
  }

  /// Builds drawer defaults from semantic colors and radius tokens.
  DrawerThemeData drawerTheme({
    required ThemeColor colors,
    required AppDecorationTheme decoration,
  }) {
    final radius = Radius.circular(decoration.radiusXl);
    return DrawerThemeData(
      backgroundColor: colors.cardBackground,
      scrimColor: Colors.black.withValues(alpha: 0.48),
      elevation: decoration.elevationMd,
      shadowColor: colors.shadowColor.withValues(alpha: 0.2),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: radius),
      ),
      endShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: radius),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }

  /// Builds tooltip defaults from semantic text and decoration tokens.
  TooltipThemeData tooltipTheme({
    required ThemeColor colors,
    required AppTextTheme textTheme,
    required AppDecorationTheme decoration,
  }) {
    return TooltipThemeData(
      constraints: BoxConstraints(minHeight: decoration.spaceXxl),
      padding: EdgeInsets.symmetric(
        horizontal: decoration.spaceMd,
        vertical: decoration.spaceSm,
      ),
      margin: EdgeInsets.all(decoration.spaceSm),
      verticalOffset: decoration.spaceLg,
      preferBelow: false,
      decoration: BoxDecoration(
        color: colors.onSurface,
        borderRadius: decoration.radiusSmBorder,
      ),
      textStyle: textTheme.bodySmall?.copyWith(color: colors.surface),
    );
  }

  /// Builds progress indicator defaults from semantic colors and radius tokens.
  ProgressIndicatorThemeData progressIndicatorTheme({
    required ThemeColor colors,
    required AppDecorationTheme decoration,
  }) {
    return ProgressIndicatorThemeData(
      color: colors.primary,
      linearTrackColor: colors.primary.withValues(alpha: 0.16),
      circularTrackColor: colors.primary.withValues(alpha: 0.16),
      refreshBackgroundColor: colors.surface,
      linearMinHeight: decoration.spaceXs,
      borderRadius: decoration.radiusPillBorder,
      strokeWidth: decoration.borderRegular * 3,
      strokeCap: StrokeCap.round,
    );
  }

  /// Builds switch defaults from semantic colors and component density tokens.
  SwitchThemeData switchTheme({required ThemeColor colors}) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disableColor;
        }
        if (states.contains(WidgetState.selected)) {
          return colors.onPrimary;
        }
        return colors.surface;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disableColor.withValues(alpha: 0.32);
        }
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return colors.borderColor;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  /// Builds radio defaults from semantic colors and component density tokens.
  RadioThemeData radioTheme({required ThemeColor colors}) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disableColor;
        }
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return colors.borderColor;
      }),
      overlayColor: WidgetStateProperty.all(
        colors.primary.withValues(alpha: 0.08),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  /// Creates a copy with selected component settings replaced.
  AppComponentTheme copyWith({
    bool? inputFilled,
    bool? appBarCenterTitle,
    bool? chipShowCheckmark,
  }) {
    return AppComponentTheme(
      inputFilled: inputFilled ?? this.inputFilled,
      appBarCenterTitle: appBarCenterTitle ?? this.appBarCenterTitle,
      chipShowCheckmark: chipShowCheckmark ?? this.chipShowCheckmark,
    );
  }
}
