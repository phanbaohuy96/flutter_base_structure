import 'package:shared_preferences/shared_preferences.dart';

import '../../../presentation/theme/theme_data.dart';
import 'preferences_key.dart';

class PreferencesHelper {
  static PreferencesHelper _instance;

  factory PreferencesHelper() {
    return _instance ??= PreferencesHelper._();
  }

  PreferencesHelper._();

  SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SupportedTheme getTheme() {
    final String theme = _prefs.getString(PreferencesKey.theme);
    if (theme == null || theme == SupportedTheme.light.toString()) {
      return SupportedTheme.light;
    }
    return SupportedTheme.dark;
  }

  Future<bool> setTheme(String data) async {
    return _prefs.setString(PreferencesKey.theme, data);
  }

  String getLocalization() {
    return _prefs.getString(PreferencesKey.localization);
  }

  Future<bool> saveLocalization(String locale) async {
    return _prefs.setString(PreferencesKey.localization, locale);
  }

  Future<bool> clearData() async {
    final SupportedTheme theme = getTheme();
    final String locale = getLocalization();

    await _prefs.clear();

    await saveLocalization(locale);
    return setTheme(theme.toString());
  }
}
