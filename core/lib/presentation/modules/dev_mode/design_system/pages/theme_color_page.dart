import 'package:flutter/material.dart';

import '../../../../../core.dart';

class ThemeColorPage extends StatefulWidget {
  const ThemeColorPage({super.key});

  @override
  State<ThemeColorPage> createState() => _ThemeColorPageState();
}

class _ThemeColorPageState extends State<ThemeColorPage> {
  List<Map<String, dynamic>> get themeDemo {
    final screenTheme = context.screenTheme;
    return [
      {
        'name': 'Pink',
        'light': AppTheme.factory(
          screenTheme: screenTheme,
          themeColor: ThemeColor(
            primary: const Color.fromARGB(255, 217, 98, 167),
            secondary: const Color.fromARGB(240, 250, 230, 250),
            appbarForegroundColor: Colors.white,
            brightness: Brightness.light,
            shadowColor: const Color.fromARGB(192, 246, 230, 250),
          ),
        ),
        'dark': AppTheme.factory(
          screenTheme: screenTheme,
          themeColor: ThemeColor(
            primary: const Color.fromARGB(255, 93, 47, 74),
            secondary: const Color.fromARGB(240, 250, 230, 250),
            shadowColor: const Color.fromARGB(63, 246, 230, 250),
            appbarForegroundColor: Colors.white,
            brightness: Brightness.dark,
          ),
        ),
      },
      {
        'name': 'Blue',
        'light': AppTheme.factory(
          screenTheme: screenTheme,
          themeColor: ThemeColor(
            primary: Colors.blue,
            secondary: const Color.fromARGB(239, 221, 233, 251),
            appbarForegroundColor: Colors.white,
            brightness: Brightness.light,
          ),
        ),
        'dark': AppTheme.factory(
          screenTheme: screenTheme,
          themeColor: ThemeColor(
            primary: const Color.fromARGB(255, 22, 43, 116),
            secondary: const Color.fromARGB(239, 221, 233, 251),
            appbarForegroundColor: Colors.white,
            brightness: Brightness.dark,
          ),
        ),
      },
      {
        'name': 'Cyan Accent',
        'light': AppTheme.factory(
          screenTheme: screenTheme,
          themeColor: ThemeColor(
            primary: Colors.cyanAccent,
            secondary: const Color.fromARGB(239, 221, 233, 251),
            appbarForegroundColor: Colors.black,
            brightness: Brightness.light,
          ),
        ),
        'dark': AppTheme.factory(
          screenTheme: screenTheme,
          themeColor: ThemeColor(
            primary: const Color.fromARGB(255, 10, 99, 99),
            secondary: const Color.fromARGB(239, 221, 233, 251),
            appbarForegroundColor: Colors.white,
            brightness: Brightness.dark,
          ),
        ),
      },
      {
        'name': 'Red',
        'light': AppTheme.factory(
          screenTheme: screenTheme,
          themeColor: ThemeColor(
            primary: Colors.red,
            secondary: const Color.fromARGB(239, 221, 233, 251),
            appbarForegroundColor: Colors.black,
            brightness: Brightness.light,
          ),
        ),
        'dark': AppTheme.factory(
          screenTheme: screenTheme,
          themeColor: ThemeColor(
            primary: const Color.fromARGB(255, 125, 34, 28),
            secondary: const Color.fromARGB(239, 221, 233, 251),
            appbarForegroundColor: Colors.white,
            brightness: Brightness.dark,
          ),
        ),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16).copyWith(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      children: <Widget>[
        ...themeDemo.map(
          (e) {
            return Theme(
              data: e['light'].theme,
              child: OutlinedButton(
                child: Text('${e['name']} Theme'),
                onPressed: () {
                  context.read<AppGlobalBloc>().updateTheme(
                        lightTheme: e['light'],
                        darkTheme: e['dark'],
                      );
                },
              ),
            );
          },
        ),
        Text(
          'Theme Color',
          style: context.textTheme.bodyLarge,
        ),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 4,
          childAspectRatio: 1.0,
          padding: EdgeInsets.zero,
          mainAxisSpacing: 0.0,
          crossAxisSpacing: 0.0,
          children: [
            ...[
              {
                'color': themeColor.primary,
                'name': 'primary',
              },
              {
                'color': themeColor.primaryVariant,
                'name': 'primaryVariant',
              },
              {
                'color': themeColor.secondary,
                'name': 'secondary',
              },
              {
                'color': themeColor.secondaryVariant,
                'name': 'secondaryVariant',
              },
              {
                'color': themeColor.surface,
                'name': 'surface',
              },
              {
                'color': themeColor.background,
                'name': 'background',
              },
              {
                'color': themeColor.error,
                'name': 'error',
              },
              {
                'color': themeColor.onPrimary,
                'name': 'onPrimary',
              },
              {
                'color': themeColor.onSecondary,
                'name': 'onSecondary',
              },
              {
                'color': themeColor.onBackground,
                'name': 'onBackground',
              },
              {
                'color': themeColor.onSurface,
                'name': 'onSurface',
              },
              {
                'color': themeColor.onError,
                'name': 'onError',
              },
              {
                'color': themeColor.themePrimary,
                'name': 'themePrimary',
              },
              {
                'color': themeColor.appbarForegroundColor,
                'name': 'appbarForegroundColor',
              },
              {
                'color': themeColor.schemeAction,
                'name': 'schemeAction',
              },
              {
                'color': themeColor.cardBackground,
                'name': 'cardBackground',
              },
              {
                'color': themeColor.scaffoldBackgroundColor,
                'name': 'scaffoldBackgroundColor',
              },
              {
                'color': themeColor.disableColor,
                'name': 'disableColor',
              },
              {
                'color': themeColor.dividerColor,
                'name': 'dividerColor',
              },
              {
                'color': themeColor.borderColor,
                'name': 'borderColor',
              },
              {
                'color': themeColor.unselectedLabelColor,
                'name': 'unselectedLabelColor',
              },
              {
                'color': themeColor.selectedLabelColor,
                'name': 'selectedLabelColor',
              },
              {
                'color': themeColor.selected,
                'name': 'selected',
              },
              {
                'color': themeColor.splashColor,
                'name': 'splashColor',
              },
              {
                'color': themeColor.shadowColor,
                'name': 'shadowColor',
              },
              {
                'color': themeColor.textButtonColor,
                'name': 'textButtonColor',
              },
              {
                'color': themeColor.textButtonDisableColor,
                'name': 'textButtonDisableColor',
              },
              {
                'color': themeColor.elevatedBtnForegroundColor,
                'name': 'elevatedBtnForegroundColor',
              },
              {
                'color': themeColor.elevatedBtnBackgroundColor,
                'name': 'elevatedBtnBackgroundColor',
              },
              {
                'color': themeColor.elevatedBtnForegroundDisableColor,
                'name': 'elevatedBtnForegroundDisableColor',
              },
              {
                'color': themeColor.elevatedBtnBackgroundDisableColor,
                'name': 'elevatedBtnBackgroundDisableColor',
              },
              {
                'color': themeColor.outlineButtonColor,
                'name': 'outlineButtonColor',
              },
              {
                'color': themeColor.outlineButtonBackgroundColor,
                'name': 'outlineButtonBackgroundColor',
              },
              {
                'color': themeColor.outlineButtonDisableColor,
                'name': 'outlineButtonDisableColor',
              },
              {
                'color': themeColor.checkboxCheckColor,
                'name': 'checkboxCheckColor',
              },
              {
                'color': themeColor.checkboxActiveColor,
                'name': 'checkboxActiveColor',
              },
              {
                'color': themeColor.checkboxBorderColor,
                'name': 'checkboxBorderColor',
              },
              {
                'color': themeColor.checkboxDisabledColor,
                'name': 'checkboxDisabledColor',
              },
              {
                'color': themeColor.chipBackgroundColor,
                'name': 'chipBackgroundColor',
              },
              {
                'color': themeColor.chipBorderColor,
                'name': 'chipBorderColor',
              },
              {
                'color': themeColor.chipLabelColor,
                'name': 'chipLabelColor',
              },
              {
                'color': themeColor.chipSelectedColor,
                'name': 'chipSelectedColor',
              },
              {
                'color': themeColor.chipDisabledColor,
                'name': 'chipDisabledColor',
              },
              {
                'color': themeColor.deleteIconColor,
                'name': 'deleteIconColor',
              },
              {
                'color': themeColor.displayText,
                'name': 'displayText',
              },
              {
                'color': themeColor.headlineText,
                'name': 'headlineText',
              },
              {
                'color': themeColor.titleText,
                'name': 'titleText',
              },
              {
                'color': themeColor.bodyText,
                'name': 'bodyText',
              },
              {
                'color': themeColor.labelText,
                'name': 'labelText',
              },
              {
                'color': themeColor.warningText,
                'name': 'warningText',
              },
              {
                'color': themeColor.hyperLink,
                'name': 'hyperLink',
              },
            ].map(
              (e) => InkWell(
                onTap: () {
                  showToast(context, '${e['name']} - ${e['color']}');
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  alignment: Alignment.center,
                  color: e['color'] as Color?,
                  child: Text(
                    e['name'] as String,
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
      ].insertSeparator(
        (index) => const SizedBox(height: 16),
      ),
    );
  }
}
