import 'package:fl_theme/fl_theme.dart';
import 'package:flutter/material.dart';

import '../../common/constants/locale/app_locale.dart';
import '../../common/constants/locale/date_locale.dart';
import '../../common/constants/locale/datetime/en.dart';
import '../../common/constants/locale/datetime/vi.dart';
import '../theme/export.dart';

export 'package:fl_theme/src/extension.dart';

extension CorePresentationContextOnStateExt on State {
  ThemeColor get themeColor => context.themeColor;

  ScreenTheme get screenTheme => context.screenTheme;

  ScreenFormTheme get screenFormTheme => context.screenFormTheme;

  MainPageFormTheme get mainPageFormTheme => context.mainPageFormTheme;
}

extension CoreAppDateLocaleExt on BuildContext {
  AppDateLocale get appDateLocale {
    return Localizations.localeOf(this).languageCode ==
            AppLocale.en.languageCode
        ? ENDateLocale().toAppDateLocale
        : VIDateLocale().toAppDateLocale;
  }
}
