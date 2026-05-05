import 'package:core/core.dart';

class AppScreenThemes {
  AppScreenThemes._();

  static ScreenTheme create(AppTextTheme textTheme) {
    return ScreenTheme.fromTextTheme(
      textTheme,
      showHeaderImage: false,
      hasBottomBorderRadius: false,
      showAppbarDivider: true,
      centerTitle: true,
    );
  }
}
