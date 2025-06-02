import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../common/utils/log_utils.dart';
import '../../models/token.dart';
import 'hive/local_hive_data.dart';
import 'preferences_helper/preferences_helper.dart';

@injectable
class CoreLocalDataManager implements CoreAppPreferenceData, CoreLocalHiveData {
  final CorePreferencesHelper _preferencesHelper;

  CoreLocalDataManager(
    this._preferencesHelper,
  );

  //////////////////////////////////////////////////////
  ///             Preferences helper
  ///
  @override
  int? getTheme() {
    return _preferencesHelper.getTheme();
  }

  @override
  Future<bool?> setTheme(int themeMode) {
    return _preferencesHelper.setTheme(themeMode);
  }

  @override
  String? getLocalization() {
    return _preferencesHelper.getLocalization();
  }

  @override
  Future<bool?> saveLocalization(String? locale) {
    return _preferencesHelper.saveLocalization(locale);
  }

  @override
  Future<bool?> clearData() async {
    logUtils.i('$runtimeType clearData');
    final _allowCookieConsent = allowCookieConsent;
    final _lastDayShowCookieConsent = lastDayShowCookieConsent;

    final res = await _preferencesHelper.clearData();

    await setCookieConsentAccepted(_allowCookieConsent);
    await setLastDayShowCookieConsent(_lastDayShowCookieConsent);

    return res;
  }

  @override
  bool isFirstLaunch() {
    return _preferencesHelper.isFirstLaunch();
  }

  @override
  Future<bool?> markLaunched() {
    return _preferencesHelper.markLaunched();
  }

  @override
  Future<bool?> unMarkLaunched() {
    return _preferencesHelper.unMarkLaunched();
  }

  /// Token
  @override
  Future<UserToken?> get token => _preferencesHelper.token;

  @override
  Future setToken(UserToken? value) {
    if (kIsWeb) {
      /// On the web platform, saving the user token locally is not supported
      /// due to security concerns.
      ///
      /// Instead, consider using credential cookies for authentication purposes
      return Future.value(false);
    }
    return _preferencesHelper.setToken(value);
  }

  @override
  bool? get allowCookieConsent => _preferencesHelper.allowCookieConsent;

  @override
  Future<bool?> setCookieConsentAccepted(bool? accepted) {
    return _preferencesHelper.setCookieConsentAccepted(accepted);
  }

  @override
  DateTime? get lastDayShowCookieConsent =>
      _preferencesHelper.lastDayShowCookieConsent;

  @override
  Future<bool?> setLastDayShowCookieConsent(DateTime? today) {
    return _preferencesHelper.setLastDayShowCookieConsent(today);
  }
}
