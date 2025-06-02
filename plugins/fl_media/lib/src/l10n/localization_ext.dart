import 'package:flutter/widgets.dart';

import 'generated/fl_media_localizations.dart';
import 'generated/fl_media_localizations_en.dart';

export 'generated/fl_media_localizations.dart';

extension CoreLocalizationOnContextExt on BuildContext {
  FlMediaLocalizations get flMediaL10n =>
      FlMediaLocalizations.of(this) ?? FlMediaLocalizationsEn();
}

extension FlMediaLocalizationsLocalizationOnStateExt on State {
  FlMediaLocalizations get flMediaL10n => context.flMediaL10n;
}
