import 'package:fl_theme/fl_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Checkbox Theme Tests', () {
    testWidgets('Checkbox theme is applied correctly', (
      WidgetTester tester,
    ) async {
      // Create a theme with custom checkbox colors
      final themeColor = ThemeColor(
        primary: Colors.red,
        secondary: Colors.blue,
        brightness: Brightness.light,
        checkboxCheckColor: Colors.yellow,
        checkboxActiveColor: Colors.green,
        checkboxBorderColor: Colors.purple,
        checkboxDisabledColor: Colors.grey,
      );

      final appTheme = AppTheme.create(
        AppThemeConfig(
          screenTheme: const ScreenTheme(),
          themeColor: themeColor,
        ),
      );

      var checkboxValue = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme.theme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Checkbox(
                value: checkboxValue,
                onChanged: (value) {
                  setState(() {
                    checkboxValue = value ?? false;
                  });
                },
              ),
            ),
          ),
        ),
      );

      // Verify the checkbox widget is present
      expect(find.byType(Checkbox), findsOneWidget);

      // Verify the theme is applied
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);

      // Test checkbox interaction
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // The checkbox should be checked now
      final updatedCheckbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(updatedCheckbox.value, true);
    });

    test('ThemeColor has checkbox properties', () {
      final themeColor = ThemeColor(
        primary: Colors.blue,
        secondary: Colors.orange,
        brightness: Brightness.light,
        checkboxCheckColor: Colors.white,
        checkboxActiveColor: Colors.blue,
        checkboxBorderColor: Colors.grey,
        checkboxDisabledColor: Colors.grey[300],
      );

      expect(themeColor.checkboxCheckColor, Colors.white);
      expect(themeColor.checkboxActiveColor, Colors.blue);
      expect(themeColor.checkboxBorderColor, Colors.grey);
      expect(themeColor.checkboxDisabledColor, Colors.grey[300]);
    });

    test('AppTheme includes checkbox theme', () {
      final themeColor = ThemeColor(
        primary: Colors.blue,
        secondary: Colors.orange,
        brightness: Brightness.light,
      );

      final appTheme = AppTheme.create(
        AppThemeConfig(
          screenTheme: const ScreenTheme(),
          themeColor: themeColor,
        ),
      );

      expect(appTheme.theme.checkboxTheme, isNotNull);
      expect(appTheme.theme.checkboxTheme.checkColor, isNotNull);
      expect(appTheme.theme.checkboxTheme.fillColor, isNotNull);
      expect(appTheme.theme.checkboxTheme.overlayColor, isNotNull);
      expect(appTheme.theme.checkboxTheme.side, isNotNull);
    });

    test('Custom checkbox theme builder works', () {
      CheckboxThemeData customCheckboxTheme({
        required ThemeColor themeColor,
        required AppTextTheme textTheme,
      }) {
        return CheckboxThemeData(
          checkColor: WidgetStateProperty.all(Colors.red),
          shape: const CircleBorder(),
        );
      }

      final themeColor = ThemeColor(
        primary: Colors.blue,
        secondary: Colors.orange,
        brightness: Brightness.light,
      );

      final appTheme = AppTheme.create(
        AppThemeConfig(
          screenTheme: const ScreenTheme(),
          themeColor: themeColor,
          checkboxThemeBuilder: customCheckboxTheme,
        ),
      );

      expect(appTheme.theme.checkboxTheme.checkColor?.resolve({}), Colors.red);
      expect(appTheme.theme.checkboxTheme.shape, isA<CircleBorder>());
    });
  });
}
