import 'dart:convert';

import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/utils/log_utils.dart';
import '../../models/token.dart';
import 'preferences_key.dart';

abstract class CoreAppPreferenceData {
  int? getTheme();
  Future<bool?> setTheme(int themeMode);

  String? getLocalization();
  Future<bool?> saveLocalization(String? locale);

  Future<bool?> clearData();

  Future<UserToken?> get token;
  Future setToken(UserToken? value);

  String? get domainReplacement;
  Future<bool?> setDomainReplacement(String? domain);
}

@injectable
class CoreLocalDataManager implements CoreAppPreferenceData {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  CoreLocalDataManager(this._prefs, this._secureStorage);

  @protected
  SharedPreferences get prefs => _prefs;

  @override
  int? getTheme() => _prefs.getInt(CorePreferencesKey.theme);

  @override
  Future<bool?> setTheme(int themeMode) =>
      _prefs.setInt(CorePreferencesKey.theme, themeMode);

  @override
  String? getLocalization() =>
      _prefs.getString(CorePreferencesKey.localization);

  @override
  Future<bool?> saveLocalization(String? locale) {
    if (locale == null) {
      return _prefs.remove(CorePreferencesKey.localization);
    }
    return _prefs.setString(CorePreferencesKey.localization, locale);
  }

  @override
  Future<bool?> clearData() async {
    logUtils.i('$runtimeType clearData');

    final theme = getTheme();
    final locale = getLocalization();

    await Future.wait([_prefs.clear(), _secureStorage.deleteAll()]);

    final results = await Future.wait([
      saveLocalization(locale),
      if (theme != null) setTheme(theme),
    ]);

    return results.any((e) => e == false) == false;
  }

  UserToken? _memCacheToken;

  /// Synchronous "is a session in memory" check, intended for hot paths that
  /// can't await secure storage (e.g. `GoRoute.redirect`). Reflects whatever
  /// the async [token] getter last loaded plus any subsequent [setToken]
  /// writes. Bootstrap by `await`-ing [token] once during app init so this
  /// is populated before the first navigation.
  bool get isAuthenticated => _memCacheToken != null;

  @override
  Future<UserToken?> get token async {
    if (_memCacheToken != null) {
      return _memCacheToken;
    }
    final source = await _secureStorage.read(key: CorePreferencesKey.token);
    if (source.isNullOrEmpty == true) {
      return null;
    }
    final parsed = UserToken.fromJson(jsonDecode(source!));
    if (parsed.isValid) {
      _memCacheToken = parsed;
      return parsed;
    }
    return null;
  }

  @override
  Future setToken(UserToken? value) async {
    /// On Safari, Apple doesn't allow cross-site cookies, so in [kDebugMode]
    /// we still permit local-storage token writes on web for the dev demo.
    /// In release web builds, prefer credential cookies for auth.
    if (kIsWeb && !kDebugMode) {
      return Future.value(false);
    }
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
  String? get domainReplacement =>
      _prefs.getString(CorePreferencesKey.domainReplacement);

  @override
  Future<bool?> setDomainReplacement(String? domain) {
    if (domain == null) {
      return _prefs.remove(CorePreferencesKey.domainReplacement);
    }
    return _prefs.setString(CorePreferencesKey.domainReplacement, domain);
  }
}
