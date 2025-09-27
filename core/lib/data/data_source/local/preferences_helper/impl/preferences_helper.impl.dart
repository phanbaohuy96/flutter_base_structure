part of '../preferences_helper.dart';

@Injectable(as: CorePreferencesHelper)
class CorePreferencesHelperImpl extends CorePreferencesHelper {
  final SharedPreferences _pref;
  final FlutterSecureStorage _secureStorage;

  CorePreferencesHelperImpl(this._pref, this._secureStorage);

  @override
  int? getTheme() {
    return _pref.getInt(CorePreferencesKey.theme);
  }

  @override
  Future<bool?> setTheme(int themeMode) async {
    return _pref.setInt(CorePreferencesKey.theme, themeMode);
  }

  @override
  String? getLocalization() {
    return _pref.getString(CorePreferencesKey.localization);
  }

  @override
  Future<bool?> saveLocalization(String? locale) async {
    if (locale == null) {
      return _pref.remove(CorePreferencesKey.localization);
    }
    return _pref.setString(CorePreferencesKey.localization, locale);
  }

  @override
  Future<bool?> clearData() async {
    final theme = getTheme();
    final locale = getLocalization();
    final isLaunched = !isFirstLaunch();

    await Future.wait([
      _pref.clear(),
      _secureStorage.deleteAll(),
    ]);

    final result = await Future.wait([
      saveLocalization(locale),
      if (theme != null) setTheme(theme),
      if (isLaunched) markLaunched(),
    ]);

    return result.any((e) => e == false) == false;
  }

  @override
  bool isFirstLaunch() {
    return _pref.getString(CorePreferencesKey.isLaunched).isNullOrEmpty == true;
  }

  @override
  Future<bool?> markLaunched() async {
    return _pref.setString(CorePreferencesKey.isLaunched, 'yes');
  }

  @override
  Future<bool?> unMarkLaunched() {
    return _pref.remove(CorePreferencesKey.isLaunched);
  }

  UserToken? _memCacheToken;

  @override
  Future<UserToken?> get token async {
    if (_memCacheToken != null) {
      return _memCacheToken;
    }
    final source = await _secureStorage.read(key: CorePreferencesKey.token);

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
  Future setToken(UserToken? value) async {
    _memCacheToken = value;
    if (value == null) {
      return _secureStorage.delete(key: CorePreferencesKey.token);
    }
    return _secureStorage.write(
      key: CorePreferencesKey.token,
      value: jsonEncode(value.toJson()),
    );
  }

  @override
  bool? get allowCookieConsent =>
      _pref.getBool(CorePreferencesKey.cookieConsent);

  @override
  Future<bool?> setCookieConsentAccepted(bool? accepted) {
    if (accepted == null) {
      return _pref.remove(CorePreferencesKey.cookieConsent);
    }
    return _pref.setBool(
      CorePreferencesKey.cookieConsent,
      accepted,
    );
  }

  @override
  DateTime? get lastDayShowCookieConsent => DateTime.tryParse(
        _pref.getString(CorePreferencesKey.lastDayShowCookieConsent) ?? '',
      );

  @override
  Future<bool?> setLastDayShowCookieConsent(DateTime? today) {
    if (today == null) {
      return _pref.remove(CorePreferencesKey.lastDayShowCookieConsent);
    }
    return _pref.setString(
      CorePreferencesKey.lastDayShowCookieConsent,
      today.toIso8601String(),
    );
  }

  @override
  String? get domainReplacement =>
      _pref.getString(CorePreferencesKey.domainReplacement);

  @override
  Future<bool?> setDomainReplacement(String? domain) {
    if (domain == null) {
      return _pref.remove(CorePreferencesKey.domainReplacement);
    }
    return _pref.setString(CorePreferencesKey.domainReplacement, domain);
  }
}
