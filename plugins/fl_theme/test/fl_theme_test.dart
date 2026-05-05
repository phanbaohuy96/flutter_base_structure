import 'package:fl_theme/fl_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses and exports JSON theme config', () {
    final config = ThemeJsonConfig.decode('''
{
  "schemaVersion": 1,
  "name": "Ocean Blue",
  "mode": "light",
  "useMaterial3": true,
  "colors": {
    "primary": "#3B82F6",
    "secondary": "#EFF6FF",
    "surface": "#FFFFFF",
    "background": "#F3F4F6",
    "error": "#B00020",
    "appBarBackground": "#FFFFFF",
    "appBarForeground": "#111827"
  },
  "typography": {
    "buttonFontSize": 15,
    "buttonFontWeight": 600,
    "bodyFontSize": 14
  },
  "decoration": {
    "radius": 8,
    "buttonRadius": 8,
    "inputRadius": 8,
    "chipRadius": 16,
    "screenPadding": 16
  },
  "components": {
    "inputFilled": false,
    "appBarCenterTitle": true,
    "chipShowCheckmark": true
  },
  "screen": {
    "showHeaderImage": false,
    "hasBottomBorderRadius": false,
    "showAppbarDivider": false,
    "centerTitle": false
  }
}
''');

    expect(config.name, 'Ocean Blue');
    expect(config.colors.primary, const Color(0xFF3B82F6));
    expect(config.toJson()['colors']['primary'], '#FF3B82F6');
  });

  test('invalid JSON color reports field path', () {
    expect(
      () => ThemeJsonConfig.decode('''
{
  "colors": {"primary": "blue"}
}
'''),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('colors.primary'),
        ),
      ),
    );
  });

  testWidgets('design system theme exposes extensions', (tester) async {
    final designSystem = AppDesignSystem.fromJsonConfig(
      const ThemeJsonConfig(
        name: 'Test Theme',
        decoration: ThemeJsonDecoration(screenPadding: 20),
        typography: ThemeJsonTypography(buttonFontSize: 18),
      ),
    );
    final appTheme = AppTheme.create(
      AppThemeConfig(designSystem: designSystem),
    );

    late BuildContext capturedContext;
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme.theme,
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(capturedContext.themeColor.primary, const Color(0xFF3B82F6));
    expect(capturedContext.textTheme.buttonText?.fontSize, 18);
    expect(capturedContext.decorationTheme.screenPadding, 20);
    expect(capturedContext.screenTheme, isA<ScreenTheme>());
  });

  test('design system configures broad Material component themes', () {
    final designSystem = AppDesignSystem.fromJsonConfig(
      const ThemeJsonConfig(
        colors: ThemeJsonColor(
          primary: Color(0xFF16A34A),
          secondary: Color(0xFFDCFCE7),
          surface: Color(0xFFFFFFFF),
          background: Color(0xFFF0FDF4),
          error: Color(0xFFDC2626),
        ),
        decoration: ThemeJsonDecoration(
          radius: 10,
          buttonRadius: 18,
          inputRadius: 12,
          chipRadius: 24,
          screenPadding: 18,
        ),
        components: ThemeJsonComponent(inputFilled: true),
      ),
    );
    final theme = AppTheme.create(
      AppThemeConfig(designSystem: designSystem),
    ).theme;

    expect(theme.cardTheme.color, const Color(0xFFFFFFFF));
    expect(theme.scrollbarTheme.interactive, isTrue);
    expect(theme.dialogTheme.backgroundColor, const Color(0xFFFFFFFF));
    expect(theme.bottomSheetTheme.showDragHandle, isTrue);
    expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
    expect(theme.listTileTheme.selectedColor, const Color(0xFF16A34A));
    expect(
      theme.iconTheme.color,
      theme.extension<ThemeColorExtension>()!.colors.labelText,
    );
    expect(
      theme.floatingActionButtonTheme.backgroundColor,
      const Color(0xFF16A34A),
    );
    expect(theme.navigationBarTheme.backgroundColor, const Color(0xFFFFFFFF));
    expect(theme.drawerTheme.backgroundColor, const Color(0xFFFFFFFF));
    expect(theme.tooltipTheme.preferBelow, isFalse);
    expect(theme.progressIndicatorTheme.color, const Color(0xFF16A34A));
    expect(
      theme.switchTheme.trackColor?.resolve({WidgetState.selected}),
      const Color(0xFF16A34A),
    );
    expect(
      theme.radioTheme.fillColor?.resolve({WidgetState.selected}),
      const Color(0xFF16A34A),
    );
  });

  test('legacy factory remains compatible', () {
    final appTheme = AppTheme.factory(
      screenTheme: const ScreenTheme(),
      themeColor: ThemeColor(
        primary: Colors.blue,
        secondary: Colors.orange,
        brightness: Brightness.light,
      ),
    );

    expect(appTheme.theme.extension<ThemeColorExtension>(), isNotNull);
    expect(appTheme.theme.extension<AppTextThemeExtension>(), isNotNull);
    expect(appTheme.theme.extension<AppDecorationTheme>(), isNotNull);
  });
}
