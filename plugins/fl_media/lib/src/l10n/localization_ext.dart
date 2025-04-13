import 'package:flutter/widgets.dart';

import 'generated/fl_media_localizations.dart';
import 'generated/fl_media_localizations_en.dart';

export 'generated/fl_media_localizations.dart';

extension CoreLocalizationOnContextExt on BuildContext {
  FlMeidaLocalizations get flMediaL10n =>
      FlMeidaLocalizations.of(this) ?? FlMeidaLocalizationsEn();
}

extension FlMeidaLocalizationsLocalizationOnStateExt on State {
  FlMeidaLocalizations get flMediaL10n => context.flMediaL10n;
}
