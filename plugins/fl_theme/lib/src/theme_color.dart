import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'utils/extension.dart';

class ThemeColor {
  /// Override [ThemeData.primaryColor].
  ///
  /// The background color for major parts of the app (toolbars, tab bars, etc)
  ///
  /// The theme's [colorScheme] property contains [ColorScheme.primary], as
  /// well as a color that contrasts well with the primary color called
  /// [ColorScheme.onPrimary]. It might be simpler to just configure an app's
  /// visuals in terms of the theme's [colorScheme].
  final Color themePrimary;
  final Color? themePrimaryLight;
  final Color? themePrimaryDark;

  /// The color displayed most frequently across your app’s screens
  /// and components.
  final Color primary;

  /// An accent color used for less prominent components in the UI, such as
  /// filter chips, while expanding the opportunity for color expression.
  final Color secondary;

  /// Overrides the default value of [AppBar.foregroundColor] in all
  /// descendant [AppBar] widgets.
  ///
  /// See also:
  ///
  ///  * [foregroundColor], which overrides the default value of
  ///    [AppBar.foregroundColor] in all descendant [AppBar] widgets.
  final Color appbarForegroundColor;

  /// Overrides the default value of [AppBar.backgroundColor] in all
  /// descendant [AppBar] widgets.
  ///
  /// See also:
  ///
  ///  * [backgroundColor], which overrides the default value of
  ///    [AppBar.backgroundColor] in all descendant [AppBar] widgets.
  /// Default is [ThemeColor.primary]
  final Color? appbarBackgroundColor;

  /// Using for highlight actionable
  /// Like a Text Button, Action Icon, Prefix Icon, Surfix Icon
  ///
  /// Usually it equal to primary color
  final Color schemeAction;

  /// The color of ink splashes.
  ///
  /// See also:
  ///  * [splashFactory], which defines the appearance of the splash.
  ///
  /// Usually it equal to primaryColorLight
  final Color splashColor;

  /// The color that the [Material] widget uses to draw elevation shadows.
  ///
  /// Defaults to fully opaque black.
  ///
  /// Shadows can be difficult to see in a dark theme, so the elevation of a
  /// surface should be rendered with an "overlay" in addition to the shadow.
  /// As the elevation of the component increases, the overlay increases in
  /// opacity. The [applyElevationOverlayColor] property turns the elevation
  /// overlay on or off for dark themes.
  final Color shadowColor;

  /// The color of [Material] when it is used as a [Card].
  final Color cardBackground;

  /// The default color of [MaterialType.canvas] [Material].
  final Color canvasColor;

  /// The default color of the [Material] that underlies the [Scaffold]. The
  /// background color for a typical material app or a page within the app.
  final Color scaffoldBackgroundColor;

  /// The color used for widgets that are inoperative, regardless of
  /// their state. For example, a disabled checkbox (which may be
  /// checked or unchecked).
  final Color disableColor;

  /// The color of [Divider]s and [VerticalDivider]s, also
  /// used between [ListTile]s, between rows in [DataTable]s, and so forth.
  final Color dividerColor;

  final Color borderColor;

  /// Overrides the default value for [TabBar.unselectedLabelColor].
  final Color unselectedLabelColor;

  /// Overrides the default value for [TabBar.labelColor].
  ///
  /// If [labelColor] is a [WidgetStateColor], then the effective color will
  /// depend on the [WidgetState.selected] state, i.e. if the [Tab] is
  /// selected or not. In case of unselected state, this [WidgetStateColor]'s
  /// resolved color will be used even if [TabBar.unselectedLabelColor] or
  /// [unselectedLabelColor] is non-null.
  ///
  /// Default is [ThemeColor.primary]
  final Color selectedLabelColor;

  /// [Chip.backgroundColor]
  /// [TabBar.indicatorColor]
  /// Selected [Icon.color]
  ///
  /// Default is [ThemeColor.primary]
  final Color selected;

  /// It is [TextButton.foregroundColor]
  final Color textButtonColor;

  /// It is [TextButton.backgroundColor] when disabled
  final Color? textButtonDisableColor;

  /// It is [ElevatedButton.foregroundColor]
  final Color elevatedBtnForegroundColor;

  /// It is [ElevatedButton.backgroundColor]
  final Color elevatedBtnBackgroundColor;

  /// It is [ElevatedButton.foregroundColor] when disabled
  final Color? elevatedBtnForegroundDisableColor;

  /// It is [ElevatedButton.backgroundColor] when disabled
  final Color? elevatedBtnBackgroundDisableColor;

  /// It is [OutlinedButton.foregroundColor] and [OutlinedButton.side.color]
  final Color outlineButtonColor;

  /// It is [OutlinedButton.backgroundColor]
  final Color outlineButtonBackgroundColor;

  /// It is [OutlinedButton.foregroundColor] and [OutlinedButton.side.color]
  /// when disabled
  final Color outlineButtonDisableColor;

  /// Color of the check mark inside a selected checkbox
  final Color checkboxCheckColor;

  /// Background color of a selected checkbox
  final Color checkboxActiveColor;

  /// Border color of an unselected checkbox
  final Color checkboxBorderColor;

  /// Background and border color of a disabled checkbox
  final Color checkboxDisabledColor;

  /// Background color of a chip
  final Color chipBackgroundColor;

  /// Border color of a chip
  final Color chipBorderColor;

  /// Text color of a chip label
  final Color chipLabelColor;

  /// Background color of a selected chip
  final Color chipSelectedColor;

  /// Background color of a disabled chip
  final Color chipDisabledColor;

  /// Color of delete icon in chip
  final Color deleteIconColor;

  final Brightness brightness;
  // Text Color
  final Color displayText;
  final Color headlineText;
  final Color titleText;
  final Color bodyText;
  final Color lableText;
  final Color warningText;
  final Color hyperLink;

  ThemeColor({
    required this.primary,
    required this.secondary,
    required this.brightness,
    Color? themePrimary,
    Color? themePrimaryLight,
    Color? themePrimaryDark,
    this.appbarForegroundColor = Colors.white,
    this.appbarBackgroundColor,
    Color? schemeAction,
    Color? cardBackground,
    Color? canvasColor,
    Color? scaffoldBackgroundColor,
    this.disableColor = const Color(0xffADADAD),
    Color? dividerColor,
    Color? borderColor,
    this.unselectedLabelColor = const Color(0xFF646464),
    Color? selectedLabelColor,
    Color? selected,
    Color? splashColor,
    Color? shadowColor,
    Color? textButtonColor,
    Color? textButtonDisableColor,
    this.elevatedBtnForegroundColor = Colors.white,
    Color? elevatedBtnBackgroundColor,
    this.elevatedBtnForegroundDisableColor,
    this.elevatedBtnBackgroundDisableColor,
    Color? outlineButtonColor,
    Color? outlineButtonBackgroundColor,
    Color? outlineButtonDisableColor,
    Color? checkboxCheckColor,
    Color? checkboxActiveColor,
    Color? checkboxBorderColor,
    Color? checkboxDisabledColor,
    Color? chipBackgroundColor,
    Color? chipBorderColor,
    Color? chipLabelColor,
    Color? chipSelectedColor,
    Color? chipDisabledColor,
    Color? deleteIconColor,
    Color? displayText,
    Color? headlineText,
    Color? titleText,
    Color? bodyText,
    Color? lableText,
    Color? warningText,
    Color? hyperLink,
  })  : themePrimary = themePrimary ??
            (brightness == Brightness.light ? Colors.white : Colors.grey[900]!),
        themePrimaryLight = themePrimaryLight ??
            themePrimary?.lighten(0.1) ??
            (brightness == Brightness.light ? Colors.white : Colors.grey[900]!)
                .lighten(0.1),
        themePrimaryDark = themePrimaryDark ??
            themePrimary?.darken(0.1) ??
            (brightness == Brightness.light
                    ? Colors.white70
                    : Colors.grey[900]!)
                .darken(0.1),
        scaffoldBackgroundColor = scaffoldBackgroundColor ??
            ThemeData(brightness: brightness).scaffoldBackgroundColor,
        dividerColor = dividerColor ??
            (brightness == Brightness.light
                ? const Color(0xFFF6F6F7)
                : Colors.white38),
        borderColor = borderColor ??
            (brightness == Brightness.light
                ? const Color(0xFFD1D5DB)
                : Colors.white38),
        schemeAction = schemeAction ?? primary,
        cardBackground = cardBackground ??
            (brightness == Brightness.light ? Colors.white : Colors.grey[800]!),
        canvasColor = canvasColor ??
            (brightness == Brightness.light ? Colors.white : Colors.grey[850]!),
        splashColor = splashColor ?? secondary,
        shadowColor = shadowColor ??
            (brightness == Brightness.light
                ? Colors.grey.shade300
                : Colors.grey.shade800),
        textButtonColor = textButtonColor ?? primary,
        textButtonDisableColor = textButtonDisableColor ?? disableColor,
        elevatedBtnBackgroundColor = elevatedBtnBackgroundColor ?? primary,
        outlineButtonColor = outlineButtonColor ?? primary,
        outlineButtonBackgroundColor =
            outlineButtonBackgroundColor ?? Colors.transparent,
        outlineButtonDisableColor = outlineButtonDisableColor ?? disableColor,
        displayText = displayText ??
            (brightness == Brightness.light
                ? const Color(0xFF272727)
                : Colors.grey),
        headlineText = headlineText ??
            (brightness == Brightness.light
                ? const Color(0xFF272727)
                : Colors.grey),
        titleText = titleText ??
            (brightness == Brightness.light
                ? const Color(0xFF272727)
                : Colors.grey),
        bodyText = bodyText ??
            (brightness == Brightness.light
                ? const Color(0xFF272727)
                : Colors.grey),
        lableText = lableText ??
            (brightness == Brightness.light
                ? const Color(0xFF272727)
                : Colors.grey),
        warningText = warningText ??
            (brightness == Brightness.light
                ? const Color(0xFFFF9B1A)
                : Colors.orange[800]!),
        hyperLink = hyperLink ??
            (brightness == Brightness.light ? Colors.blue : Colors.blue[800]!),
        checkboxCheckColor = checkboxCheckColor ?? Colors.white,
        checkboxActiveColor = checkboxActiveColor ?? primary,
        checkboxBorderColor = checkboxBorderColor ??
            borderColor ??
            (brightness == Brightness.light
                ? const Color(0xFFD1D5DB)
                : Colors.white38),
        checkboxDisabledColor = checkboxDisabledColor ?? disableColor,
        chipBackgroundColor = chipBackgroundColor ??
            (brightness == Brightness.light ? Colors.white : Colors.grey[700]!),
        chipBorderColor = chipBorderColor ??
            borderColor ??
            (brightness == Brightness.light
                ? const Color(0xFFD1D5DB)
                : Colors.white38),
        chipLabelColor = chipLabelColor ??
            (brightness == Brightness.light
                ? const Color(0xFF272727)
                : Colors.grey[300]!),
        chipSelectedColor = chipSelectedColor ?? primary,
        chipDisabledColor = chipDisabledColor ?? disableColor,
        deleteIconColor = deleteIconColor ?? const Color(0xFF6B7280),
        selectedLabelColor = selectedLabelColor ?? primary,
        selected = selected ?? primary;

  //HEX code color
  final lightGrey = const Color(0xFFbebebe);
  final greyDC = const Color(0xFFdcdcdc);
  final black = const Color(0xFF000000);
  final greyE5 = const Color(0xFFE5E5E5);
  final greyD1 = const Color(0xFFD1D1D1);
  final greyF7 = const Color(0xffF7F7F7);
  final grayF6F7FB = const Color(0xFFF6F7FB);
  final grayF6F7F8 = const Color(0xFFF6F7F8);
  final gray777E90 = const Color(0xFF777E90);
  final grayF4F5F6 = const Color(0xFFF4F5F6);
  final gray5F788A = const Color(0xFF5F788A);
  final grayE6E8EC = const Color(0xFFE6E8EC);
  final black23262F = const Color(0xFF23262F);

  final green = const Color(0xFF4d9e53);
  final red = const Color(0xFFEC3505);
  final orange = const Color(0xFFff9b1a);
  final darkBlue = const Color(0xFF002d41);
  final gallery = const Color(0xFFEFEFEF);
  final grayAD = const Color(0xFFADADAD);
  final grayE3 = const Color(0xFFE3E3E3);
  final gray8C = const Color(0xFF8C8C8C);
  final lightRed = const Color(0xFFFFE2DF);
  final veryLightRed = const Color(0xFFDE2C00);
  final lightGreen = const Color(0xFFE7F6E9);
  final green33B64F = const Color(0xFF33B64F);

  void setLightStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  void setDarkStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  ThemeColor lerp(
    covariant ThemeColor other,
    double t,
  ) {
    return ThemeColor(
      primary: Color.lerp(primary, other.primary, t) ?? other.primary,
      secondary: Color.lerp(secondary, other.secondary, t) ?? other.secondary,
      brightness: other.brightness,
      appbarForegroundColor:
          Color.lerp(appbarForegroundColor, other.appbarForegroundColor, t) ??
              other.appbarForegroundColor,
      schemeAction: Color.lerp(schemeAction, other.schemeAction, t),
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t) ??
          other.cardBackground,
      scaffoldBackgroundColor: Color.lerp(
            scaffoldBackgroundColor,
            other.scaffoldBackgroundColor,
            t,
          ) ??
          other.scaffoldBackgroundColor,
      disableColor:
          Color.lerp(disableColor, other.disableColor, t) ?? other.disableColor,
      dividerColor:
          Color.lerp(dividerColor, other.dividerColor, t) ?? other.dividerColor,
      unselectedLabelColor:
          Color.lerp(unselectedLabelColor, other.unselectedLabelColor, t) ??
              other.unselectedLabelColor,
      splashColor:
          Color.lerp(splashColor, other.splashColor, t) ?? other.splashColor,
      elevatedBtnForegroundColor: Color.lerp(
            elevatedBtnForegroundColor,
            other.elevatedBtnForegroundColor,
            t,
          ) ??
          other.elevatedBtnForegroundColor,
      elevatedBtnBackgroundColor: Color.lerp(
            elevatedBtnBackgroundColor,
            other.elevatedBtnBackgroundColor,
            t,
          ) ??
          other.elevatedBtnBackgroundColor,
      elevatedBtnForegroundDisableColor: Color.lerp(
            elevatedBtnForegroundDisableColor,
            other.elevatedBtnForegroundDisableColor,
            t,
          ) ??
          other.elevatedBtnForegroundDisableColor,
      elevatedBtnBackgroundDisableColor: Color.lerp(
            elevatedBtnBackgroundDisableColor,
            other.elevatedBtnBackgroundDisableColor,
            t,
          ) ??
          other.elevatedBtnBackgroundDisableColor,
      outlineButtonColor:
          Color.lerp(outlineButtonColor, other.outlineButtonColor, t) ??
              other.outlineButtonColor,
      outlineButtonDisableColor: Color.lerp(
            outlineButtonDisableColor,
            other.outlineButtonDisableColor,
            t,
          ) ??
          other.outlineButtonDisableColor,
      displayText:
          Color.lerp(displayText, other.displayText, t) ?? other.displayText,
      bodyText: Color.lerp(bodyText, other.bodyText, t) ?? other.bodyText,
      lableText: Color.lerp(lableText, other.lableText, t) ?? other.lableText,
      headlineText:
          Color.lerp(headlineText, other.headlineText, t) ?? other.headlineText,
      titleText: Color.lerp(titleText, other.titleText, t) ?? other.titleText,
      warningText:
          Color.lerp(warningText, other.warningText, t) ?? other.warningText,
      hyperLink: Color.lerp(hyperLink, other.hyperLink, t) ?? other.hyperLink,
      chipBackgroundColor:
          Color.lerp(chipBackgroundColor, other.chipBackgroundColor, t) ??
              other.chipBackgroundColor,
      chipBorderColor: Color.lerp(chipBorderColor, other.chipBorderColor, t) ??
          other.chipBorderColor,
      chipLabelColor: Color.lerp(chipLabelColor, other.chipLabelColor, t) ??
          other.chipLabelColor,
      chipSelectedColor:
          Color.lerp(chipSelectedColor, other.chipSelectedColor, t) ??
              other.chipSelectedColor,
      chipDisabledColor:
          Color.lerp(chipDisabledColor, other.chipDisabledColor, t) ??
              other.chipDisabledColor,
    );
  }

  List<BoxShadow> get boxShadowBlur => [
        BoxShadow(
          offset: const Offset(0, 2),
          blurRadius: 3,
          color: shadowColor.withAlpha((0.1 * 255).round()),
        ),
        BoxShadow(
          offset: const Offset(0, 4),
          blurRadius: 6,
          color: shadowColor.withAlpha((0.3 * 255).round()),
        ),
      ];

  List<BoxShadow> get boxShadowLightest => [
        BoxShadow(blurRadius: 1.5, color: shadowColor),
        BoxShadow(blurRadius: 1, color: shadowColor),
      ];
  List<BoxShadow> get boxShadowLight => [
        BoxShadow(blurRadius: 4, color: shadowColor),
        BoxShadow(blurRadius: 4, color: shadowColor),
      ];
  List<BoxShadow> get boxShadowMedium => [
        ...boxShadowLight,
        BoxShadow(blurRadius: 8, color: shadowColor),
        BoxShadow(blurRadius: 8, color: shadowColor),
      ];
  List<BoxShadow> get boxShadowDark => [
        ...boxShadowMedium,
        BoxShadow(blurRadius: 10.9, color: shadowColor),
        BoxShadow(blurRadius: 10.9, color: shadowColor),
      ];
}

class ThemeColorExtension extends ThemeExtension<ThemeColorExtension> {
  final ThemeColor colors;

  ThemeColorExtension({
    required this.colors,
  });

  @override
  ThemeColorExtension copyWith({ThemeColor? colors}) {
    return ThemeColorExtension(colors: colors ?? this.colors);
  }

  @override
  ThemeColorExtension lerp(
    covariant ThemeColorExtension? other,
    double t,
  ) {
    if (other == null) {
      return this;
    }
    // improve handle lerp to using switch color animation
    return ThemeColorExtension(colors: colors.lerp(other.colors, t));
  }
}
