import 'package:core/core.dart';

import 'screen_theme.dart';
import 'theme_color.dart';

class MainAppTheme {
  final AppTheme light;
  final AppTheme dark;

  MainAppTheme(this.light, this.dark);

  factory MainAppTheme.normal() {
    /// Light theme setup
    final lightThemeColor = AppThemeColor();
    final textTheme = AppTextTheme.create(lightThemeColor).let(
      (it) {
        return it.copyWithTypography(
          inputTitle: it.bodyMedium,
        );
      },
    );
    final light = AppTheme.factory(
      fontFamily: 'Poppins',
      screenTheme: ScreenTheme(
        screenFormTheme: AppScreenFormTheme(
          textTheme,
        ),
        mainPageFormTheme: AppMainPageFormTheme(
          textTheme,
        ),
      ),
      appTextTheme: textTheme,
      themeColor: lightThemeColor,
    );

    /// Dart theme setup
    final dartThemeColor = AppDarkThemeColor();
    final dartTextTheme = AppTextTheme.create(dartThemeColor).let(
      (it) {
        return it.copyWithTypography(
          inputTitle: it.bodyMedium,
        );
      },
    );
    final dark = AppTheme.factory(
      fontFamily: 'Poppins',
      screenTheme: ScreenTheme(
        screenFormTheme: AppScreenFormDarkTheme(
          dartTextTheme,
        ),
        mainPageFormTheme: AppMainPageFormDarkTheme(
          dartTextTheme,
        ),
      ),
      appTextTheme: dartTextTheme,
      themeColor: dartThemeColor,
    );
    return MainAppTheme(light, dark);
  }
}
