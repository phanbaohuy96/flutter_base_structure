import 'package:shared_preferences/shared_preferences.dart';

import '../../../presentation/theme/theme_data.dart';
import 'preferences_key.dart';

class PreferencesHelper {
  SharedPreferences? _prefs;

  Future<PreferencesHelper> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  SupportedTheme getTheme() {
    final theme = _prefs?.getString(PreferencesKey.theme);
    if (theme == null || theme == SupportedTheme.light.name) {
      return SupportedTheme.light;
    }
    return SupportedTheme.dark;
  }

  Future<bool?> setTheme(String? data) async {
    if (data == null) {
      return _prefs?.remove(PreferencesKey.theme);
    }
    return _prefs?.setString(PreferencesKey.theme, data);
  }

  String? getLocalization() {
    return _prefs?.getString(PreferencesKey.localization);
  }

  Future<bool?> saveLocalization(String? locale) async {
    if (locale == null) {
      return _prefs?.remove(PreferencesKey.localization);
    }
    return _prefs?.setString(PreferencesKey.localization, locale);
  }

  Future<bool?> clearData() async {
    final theme = getTheme();
    final locale = getLocalization();

    await _prefs?.clear();

    await Future.wait([
      saveLocalization(locale),
      setTheme(theme.name),
    ]);

    return setTheme(theme.toString());
  }
}
