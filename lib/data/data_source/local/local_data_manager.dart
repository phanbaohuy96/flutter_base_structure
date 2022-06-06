import 'package:injectable/injectable.dart';

import '../../../di/di.dart';
import '../../../presentation/theme/theme_data.dart';
import 'preferences_helper/preferences_helper.dart';

@Singleton()
class LocalDataManager implements AppPreferenceData {
  late final PreferencesHelper _preferencesHelper = injector.get();

  Future<void> init() async {}

  ////////////////////////////////////////////////////////
  ///             Preferences helper
  ///
  @override
  SupportedTheme getTheme() {
    return _preferencesHelper.getTheme();
  }

  @override
  Future<bool?> setTheme(String? data) {
    return _preferencesHelper.setTheme(data);
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
  Future<bool?> clearData() {
    return _preferencesHelper.clearData();
  }
}
