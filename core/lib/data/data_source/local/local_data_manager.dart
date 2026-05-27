import 'dart:convert';

import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/utils/log_utils.dart';
import '../../models/token.dart';
import 'preferences_key.dart';

String? normalizeDomainReplacement(String? domain) {
  final value = domain?.trim();
  if (value.isNullOrEmpty) {
    return null;
  }

  final candidate = value!.contains('://') ? value : 'https://$value';
  final uri = Uri.tryParse(candidate);
  if (uri == null ||
      !uri.hasAuthority ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment) {
    return null;
  }

  final scheme = uri.scheme.toLowerCase();
  if (scheme == 'https') {
    return uri.toString();
  }
  if (scheme == 'http' && _isLocalDomainReplacementHost(uri.host)) {
    return uri.toString();
  }
  return null;
}

bool _isLocalDomainReplacementHost(String host) {
  return host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2';
}

abstract class CoreAppPreferenceData {
  int? getTheme();
  Future<bool?> setTheme(int themeMode);

  String? getLocalization();
  Future<bool?> saveLocalization(String? locale);

  Future<bool?> clearData();

  Future<UserToken?> get token;
  Future setToken(UserToken? value);
  Future<bool> loadAuthSession();

  bool get isAuthenticated;

  String? get domainReplacement;
  Future<bool?> setDomainReplacement(String? domain);
}

@lazySingleton
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

    await Future.wait(
      [_prefs.clear(), _secureStorage.deleteAll()],
      eagerError: true,
    );
    _memCacheToken = null;

    final results = await Future.wait(
      [
        saveLocalization(locale),
        if (theme != null) setTheme(theme),
      ],
      eagerError: true,
    );

    return results.any((e) => e == false) == false;
  }

  UserToken? _memCacheToken;

  /// Synchronous "is a session in memory" check, intended for hot paths that
  /// can't await secure storage (e.g. `GoRoute.redirect`). Reflects whatever
  /// [loadAuthSession] last loaded plus any subsequent [setToken] writes.
  @override
  bool get isAuthenticated => _memCacheToken != null;

  @override
  Future<UserToken?> get token async {
    await loadAuthSession();
    return _memCacheToken;
  }

  @override
  Future<bool> loadAuthSession() async {
    if (_memCacheToken != null) {
      return true;
    }
    final source = await _secureStorage.read(key: CorePreferencesKey.token);
    if (source.isNullOrEmpty == true) {
      return false;
    }
    final parsed = UserToken.fromJson(jsonDecode(source!));
    if (parsed.isValid) {
      _memCacheToken = parsed;
      return true;
    }
    return false;
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
    if (domain == null || domain.trim().isEmpty) {
      return _prefs.remove(CorePreferencesKey.domainReplacement);
    }
    final normalizedDomain = normalizeDomainReplacement(domain);
    if (normalizedDomain == null) {
      return Future.value(false);
    }
    return _prefs.setString(
      CorePreferencesKey.domainReplacement,
      normalizedDomain,
    );
  }
}
