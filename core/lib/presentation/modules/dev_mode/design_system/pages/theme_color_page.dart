import 'package:flutter/material.dart';

import '../../../../../core.dart';

class ThemeColorPage extends StatefulWidget {
  const ThemeColorPage({super.key});

  @override
  State<ThemeColorPage> createState() => _ThemeColorPageState();
}

class _ThemeColorPageState extends State<ThemeColorPage> {
  late List<_ThemeDemo> _themeDemo;
  ScreenTheme? _screenTheme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenTheme = context.screenTheme;
    if (!identical(_screenTheme, screenTheme)) {
      _screenTheme = screenTheme;
      _themeDemo = _createThemeDemo(screenTheme);
    }
  }

  List<_ThemeDemo> _createThemeDemo(ScreenTheme screenTheme) {
    return [
      _ThemeDemo(
        name: 'Pink',
        light: _createTheme(
          screenTheme: screenTheme,
          name: 'Pink',
          primary: const Color.fromARGB(255, 217, 98, 167),
          secondary: const Color.fromARGB(240, 250, 230, 250),
          appbarForegroundColor: Colors.white,
          shadowColor: const Color.fromARGB(192, 246, 230, 250),
        ),
        dark: _createTheme(
          screenTheme: screenTheme,
          name: 'Pink Dark',
          primary: const Color.fromARGB(255, 93, 47, 74),
          secondary: const Color.fromARGB(240, 250, 230, 250),
          appbarForegroundColor: Colors.white,
          shadowColor: const Color.fromARGB(63, 246, 230, 250),
          brightness: Brightness.dark,
        ),
      ),
      _ThemeDemo(
        name: 'Blue',
        light: _createTheme(
          screenTheme: screenTheme,
          name: 'Blue',
          primary: Colors.blue,
          secondary: const Color.fromARGB(239, 221, 233, 251),
          appbarForegroundColor: Colors.white,
        ),
        dark: _createTheme(
          screenTheme: screenTheme,
          name: 'Blue Dark',
          primary: const Color.fromARGB(255, 22, 43, 116),
          secondary: const Color.fromARGB(239, 221, 233, 251),
          appbarForegroundColor: Colors.white,
          brightness: Brightness.dark,
        ),
      ),
      _ThemeDemo(
        name: 'Cyan Accent',
        light: _createTheme(
          screenTheme: screenTheme,
          name: 'Cyan Accent',
          primary: Colors.cyanAccent,
          secondary: const Color.fromARGB(239, 221, 233, 251),
          appbarForegroundColor: Colors.black,
        ),
        dark: _createTheme(
          screenTheme: screenTheme,
          name: 'Cyan Accent Dark',
          primary: const Color.fromARGB(255, 10, 99, 99),
          secondary: const Color.fromARGB(239, 221, 233, 251),
          appbarForegroundColor: Colors.white,
          brightness: Brightness.dark,
        ),
      ),
      _ThemeDemo(
        name: 'Red',
        light: _createTheme(
          screenTheme: screenTheme,
          name: 'Red',
          primary: Colors.red,
          secondary: const Color.fromARGB(239, 221, 233, 251),
          appbarForegroundColor: Colors.black,
        ),
        dark: _createTheme(
          screenTheme: screenTheme,
          name: 'Red Dark',
          primary: const Color.fromARGB(255, 125, 34, 28),
          secondary: const Color.fromARGB(239, 221, 233, 251),
          appbarForegroundColor: Colors.white,
          brightness: Brightness.dark,
        ),
      ),
    ];
  }

  AppTheme _createTheme({
    required ScreenTheme screenTheme,
    required String name,
    required Color primary,
    required Color secondary,
    required Color appbarForegroundColor,
    Brightness brightness = Brightness.light,
    Color? shadowColor,
  }) {
    final themeColor = ThemeColor(
      primary: primary,
      secondary: secondary,
      appbarForegroundColor: appbarForegroundColor,
      brightness: brightness,
      shadowColor: shadowColor,
    );
    return AppTheme.create(
      AppThemeConfig(
        designSystem: AppDesignSystem(
          name: name,
          colors: themeColor,
          screenTheme: screenTheme,
        ),
      ),
    );
  }

  List<_ColorSwatch> _themeColorSwatches(ThemeColor themeColor) {
    return [
      _ColorSwatch(color: themeColor.primary, name: 'primary'),
      _ColorSwatch(color: themeColor.primaryVariant, name: 'primaryVariant'),
      _ColorSwatch(color: themeColor.secondary, name: 'secondary'),
      _ColorSwatch(
        color: themeColor.secondaryVariant,
        name: 'secondaryVariant',
      ),
      _ColorSwatch(color: themeColor.surface, name: 'surface'),
      _ColorSwatch(color: themeColor.background, name: 'background'),
      _ColorSwatch(color: themeColor.error, name: 'error'),
      _ColorSwatch(color: themeColor.onPrimary, name: 'onPrimary'),
      _ColorSwatch(color: themeColor.onSecondary, name: 'onSecondary'),
      _ColorSwatch(color: themeColor.onBackground, name: 'onBackground'),
      _ColorSwatch(color: themeColor.onSurface, name: 'onSurface'),
      _ColorSwatch(color: themeColor.onError, name: 'onError'),
      _ColorSwatch(color: themeColor.themePrimary, name: 'themePrimary'),
      _ColorSwatch(
        color: themeColor.appbarForegroundColor,
        name: 'appbarForegroundColor',
      ),
      _ColorSwatch(color: themeColor.schemeAction, name: 'schemeAction'),
      _ColorSwatch(color: themeColor.cardBackground, name: 'cardBackground'),
      _ColorSwatch(
        color: themeColor.scaffoldBackgroundColor,
        name: 'scaffoldBackgroundColor',
      ),
      _ColorSwatch(color: themeColor.disableColor, name: 'disableColor'),
      _ColorSwatch(color: themeColor.dividerColor, name: 'dividerColor'),
      _ColorSwatch(color: themeColor.borderColor, name: 'borderColor'),
      _ColorSwatch(
        color: themeColor.unselectedLabelColor,
        name: 'unselectedLabelColor',
      ),
      _ColorSwatch(
        color: themeColor.selectedLabelColor,
        name: 'selectedLabelColor',
      ),
      _ColorSwatch(color: themeColor.selected, name: 'selected'),
      _ColorSwatch(color: themeColor.splashColor, name: 'splashColor'),
      _ColorSwatch(color: themeColor.shadowColor, name: 'shadowColor'),
      _ColorSwatch(color: themeColor.textButtonColor, name: 'textButtonColor'),
      _ColorSwatch(
        color: themeColor.textButtonDisableColor,
        name: 'textButtonDisableColor',
      ),
      _ColorSwatch(
        color: themeColor.elevatedBtnForegroundColor,
        name: 'elevatedBtnForegroundColor',
      ),
      _ColorSwatch(
        color: themeColor.elevatedBtnBackgroundColor,
        name: 'elevatedBtnBackgroundColor',
      ),
      _ColorSwatch(
        color: themeColor.elevatedBtnForegroundDisableColor,
        name: 'elevatedBtnForegroundDisableColor',
      ),
      _ColorSwatch(
        color: themeColor.elevatedBtnBackgroundDisableColor,
        name: 'elevatedBtnBackgroundDisableColor',
      ),
      _ColorSwatch(
        color: themeColor.outlineButtonColor,
        name: 'outlineButtonColor',
      ),
      _ColorSwatch(
        color: themeColor.outlineButtonBackgroundColor,
        name: 'outlineButtonBackgroundColor',
      ),
      _ColorSwatch(
        color: themeColor.outlineButtonDisableColor,
        name: 'outlineButtonDisableColor',
      ),
      _ColorSwatch(
        color: themeColor.checkboxCheckColor,
        name: 'checkboxCheckColor',
      ),
      _ColorSwatch(
        color: themeColor.checkboxActiveColor,
        name: 'checkboxActiveColor',
      ),
      _ColorSwatch(
        color: themeColor.checkboxBorderColor,
        name: 'checkboxBorderColor',
      ),
      _ColorSwatch(
        color: themeColor.checkboxDisabledColor,
        name: 'checkboxDisabledColor',
      ),
      _ColorSwatch(
        color: themeColor.chipBackgroundColor,
        name: 'chipBackgroundColor',
      ),
      _ColorSwatch(color: themeColor.chipBorderColor, name: 'chipBorderColor'),
      _ColorSwatch(color: themeColor.chipLabelColor, name: 'chipLabelColor'),
      _ColorSwatch(
        color: themeColor.chipSelectedColor,
        name: 'chipSelectedColor',
      ),
      _ColorSwatch(
        color: themeColor.chipDisabledColor,
        name: 'chipDisabledColor',
      ),
      _ColorSwatch(color: themeColor.deleteIconColor, name: 'deleteIconColor'),
      _ColorSwatch(color: themeColor.displayText, name: 'displayText'),
      _ColorSwatch(color: themeColor.headlineText, name: 'headlineText'),
      _ColorSwatch(color: themeColor.titleText, name: 'titleText'),
      _ColorSwatch(color: themeColor.bodyText, name: 'bodyText'),
      _ColorSwatch(color: themeColor.labelText, name: 'labelText'),
      _ColorSwatch(color: themeColor.warningText, name: 'warningText'),
      _ColorSwatch(color: themeColor.hyperLink, name: 'hyperLink'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = context.themeColor;
    final colorSwatches = _themeColorSwatches(themeColor);

    return ListView(
      padding: const EdgeInsets.all(
        16,
      ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
      children: <Widget>[
        ..._themeDemo.map((demo) {
          return Theme(
            data: demo.light.theme,
            child: OutlinedButton(
              child: Text('${demo.name} Theme'),
              onPressed: () {
                context.read<AppGlobalBloc>().updateTheme(
                  lightTheme: demo.light,
                  darkTheme: demo.dark,
                );
              },
            ),
          );
        }),
        Text('Theme Color', style: context.textTheme.bodyLarge),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 4,
          childAspectRatio: 1.0,
          padding: EdgeInsets.zero,
          mainAxisSpacing: 0.0,
          crossAxisSpacing: 0.0,
          children: [
            ...colorSwatches.map(
              (swatch) => InkWell(
                onTap: () {
                  showToast(context, '${swatch.name} - ${swatch.color}');
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  alignment: Alignment.center,
                  color: swatch.color,
                  child: Text(
                    swatch.name,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ],
        ),
        BoxColor(
          boxShadow: themeColor.boxShadowLightest,
          color: themeColor.themePrimary,
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: const Text('boxShadowlightest'),
        ),
        BoxColor(
          boxShadow: themeColor.boxShadowLight,
          color: themeColor.themePrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: BorderRadius.circular(12),
          child: const Text('boxShadowlight'),
        ),
        BoxColor(
          boxShadow: themeColor.boxShadowMedium,
          color: themeColor.themePrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: BorderRadius.circular(12),
          child: const Text('boxShadowMedium'),
        ),
        BoxColor(
          boxShadow: themeColor.boxShadowDark,
          color: themeColor.themePrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: BorderRadius.circular(12),
          child: const Text('boxShadowDark'),
        ),
      ].insertSeparator((index) => const SizedBox(height: 16)),
    );
  }
}

class _ThemeDemo {
  final String name;
  final AppTheme light;
  final AppTheme dark;

  const _ThemeDemo({
    required this.name,
    required this.light,
    required this.dark,
  });
}

class _ColorSwatch {
  final Color? color;
  final String name;

  const _ColorSwatch({required this.color, required this.name});
}
