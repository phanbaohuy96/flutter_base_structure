import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';
import 'generated/app_localizations_en.dart';

export 'generated/app_localizations.dart';

extension AppLocalizationOnContextExt on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? AppLocalizationsEn();
}

extension AppLocalizationOnStateExt on State {
  AppLocalizations get l10n => context.l10n;
}
