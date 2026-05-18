import 'package:flutter/widgets.dart';

import 'generated/core_localizations.dart';
import 'generated/core_localizations_en.dart';

export 'generated/core_localizations.dart';

extension CoreLocalizationOnContextExt on BuildContext {
  CoreLocalizations get coreL10n =>
      CoreLocalizations.of(this) ?? CoreLocalizationsEn();
}

extension CoreLocalizationOnStateExt on State {
  CoreLocalizations get coreL10n => context.coreL10n;
}
