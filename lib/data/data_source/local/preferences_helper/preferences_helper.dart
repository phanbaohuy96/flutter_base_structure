import 'package:shared_preferences/shared_preferences.dart';

import '../../../../presentation/theme/theme_data.dart';
import 'preferences_key.dart';

part 'impl/preferences_helper.impl.dart';

abstract class PreferencesHelper extends AppPreferenceData {
  Future<PreferencesHelper> init();
}

abstract class AppPreferenceData {
  SupportedTheme getTheme();

  Future<bool?> setTheme(String? data);

  String? getLocalization();

  Future<bool?> saveLocalization(String? locale);

  Future<bool?> clearData();
}
