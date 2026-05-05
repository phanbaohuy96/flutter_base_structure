import 'package:flutter/material.dart';

import '../fl_theme.dart';

/// Convenience accessors for app theme extensions on [BuildContext].
///
/// These getters assume the nearest [ThemeData] was created by [AppTheme] or
/// has equivalent extensions attached. Use them in `build` and
/// `didChangeDependencies`, not before a widget has an inherited [Theme]
/// ancestor.
extension FLThemePresentationContextExt on BuildContext {
  /// The nearest Material [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// The app semantic text theme extension.
  AppTextTheme get textTheme =>
      theme.extension<AppTextThemeExtension>()!.textTheme;

  /// The app semantic color extension.
  ThemeColor get themeColor => theme.extension<ThemeColorExtension>()!.colors;

  /// The app screen chrome theme extension.
  ScreenTheme get screenTheme => theme.extension<ScreenTheme>()!;

  /// The screen form theme from [screenTheme].
  ScreenFormTheme get screenFormTheme => screenTheme.screenFormTheme;

  /// The main page form theme from [screenTheme].
  MainPageFormTheme get mainPageFormTheme => screenTheme.mainPageFormTheme;

  /// The app decoration token theme extension.
  AppDecorationTheme get decorationTheme =>
      theme.extension<AppDecorationTheme>()!;
}
