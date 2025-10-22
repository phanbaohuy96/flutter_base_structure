import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/utils.dart';
import '../../../models/token.dart';
import 'preferences_key.dart';

part 'impl/preferences_helper.impl.dart';

abstract class CorePreferencesHelper extends CoreAppPreferenceData {}

/// Define common local data can be using for both app
abstract class CoreAppPreferenceData {
  int? getTheme();

  Future<bool?> setTheme(int themeMode);

  String? getLocalization();

  Future<bool?> saveLocalization(String? locale);

  Future<bool?> clearData();

  Future<bool?> markLaunched();

  Future<bool?> unMarkLaunched();

  bool isFirstLaunch();

  /// Token
  Future<UserToken?> get token;

  Future setToken(UserToken? value);

  // Cookie - Consent
  bool? get allowCookieConsent;

  Future<bool?> setCookieConsentAccepted(bool? accepted);

  DateTime? get lastDayShowCookieConsent;

  Future<bool?> setLastDayShowCookieConsent(DateTime? today);

  // Development
  String? get domainReplacement;

  Future<bool?> setDomainReplacement(String? domain);
}
