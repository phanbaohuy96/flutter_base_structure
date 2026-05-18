part of '../preferences_helper.dart';

@Injectable(as: CorePreferencesHelper)
class CorePreferencesHelperImpl extends CorePreferencesHelper {
  final SharedPreferences _prefs;

  CorePreferencesHelperImpl(this._prefs);

  @override
  int? getTheme() {
    return _prefs.getInt(CorePreferencesKey.theme);
  }

  @override
  Future<bool?> setTheme(int themeMode) async {
    return _prefs.setInt(CorePreferencesKey.theme, themeMode);
  }

  @override
  String? getLocalization() {
    return _prefs.getString(CorePreferencesKey.localization);
  }

  @override
  Future<bool?> saveLocalization(String? locale) async {
    if (locale == null) {
      return _prefs.remove(CorePreferencesKey.localization);
    }
    return _prefs.setString(CorePreferencesKey.localization, locale);
  }

  @override
  Future<bool?> clearData() async {
    final theme = getTheme();
    final locale = getLocalization();
    final isLaunched = !isFirstLaunch();

    await _prefs.clear();

    final result = await Future.wait([
      saveLocalization(locale),
      if (theme != null) setTheme(theme),
      if (isLaunched) markLaunched(),
    ]);

    return result.any((e) => e == false) == false;
  }

  @override
  bool isFirstLaunch() {
    return _prefs.getString(CorePreferencesKey.isLaunched).isNullOrEmpty ==
        true;
  }

  @override
  Future<bool?> markLaunched() async {
    return _prefs.setString(CorePreferencesKey.isLaunched, 'yes');
  }

  @override
  Future<bool?> unMarkLaunched() {
    return _prefs.remove(CorePreferencesKey.isLaunched);
  }

  @override
  UserToken? get token {
    final source = _prefs.getString(CorePreferencesKey.token);

    if (source.isNullOrEmpty == true) {
      return null;
    }

    final _token = UserToken.fromJson(jsonDecode(source!));
    if (_token.isValid) {
      return _token;
    }
    return null;
  }

  @override
  Future<bool?> setToken(UserToken? value) {
    logUtils.i('setToken', value);
    if (value == null) {
      return _prefs.remove(CorePreferencesKey.token);
    }
    return _prefs.setString(
      CorePreferencesKey.token,
      jsonEncode(value.toJson()),
    );
  }
}
