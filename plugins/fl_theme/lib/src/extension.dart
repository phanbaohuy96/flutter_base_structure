import 'package:flutter/material.dart';

import '../fl_theme.dart';

extension FLThemePresentationContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);

  AppTextTheme get textTheme =>
      theme.extension<AppTextThemeExtension>()!.textTheme;

  ThemeColor get themeColor => theme.extension<ThemeColorExtension>()!.colors;

  ScreenTheme get screenTheme => theme.extension<ScreenTheme>()!;

  ScreenFormTheme get screenFormTheme => screenTheme.screenFormTheme;

  MainPageFormTheme get mainPageFormTheme => screenTheme.mainPageFormTheme;
}
