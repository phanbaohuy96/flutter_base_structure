import 'package:core/core.dart';

class AppScreenFormTheme extends ScreenFormTheme {
  AppScreenFormTheme(AppTextTheme textTheme)
    : super(
        showHeaderImage: false,
        hasBottomBorderRadius: false,
        showAppbarDivider: false,
        centerTitle: false,
        titleStyle: textTheme.bodyLarge,
      );
}

class AppMainPageFormTheme extends MainPageFormTheme {
  AppMainPageFormTheme(AppTextTheme textTheme)
    : super(
        showHeaderImage: false,
        hasBottomBorderRadius: false,
        showAppbarDivider: false,
        titleStyle: textTheme.bodyLarge,
      );
}

class AppScreenFormDarkTheme extends ScreenFormTheme {
  AppScreenFormDarkTheme(AppTextTheme textTheme)
    : super(
        showHeaderImage: false,
        hasBottomBorderRadius: false,
        showAppbarDivider: false,
        centerTitle: false,
        titleStyle: textTheme.bodyLarge,
      );
}

class AppMainPageFormDarkTheme extends MainPageFormTheme {
  AppMainPageFormDarkTheme(AppTextTheme textTheme)
    : super(
        showHeaderImage: false,
        hasBottomBorderRadius: false,
        showAppbarDivider: false,
        titleStyle: textTheme.bodyLarge,
      );
}
