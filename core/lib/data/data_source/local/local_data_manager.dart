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
    return _preferencesHelper.clearData();
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
  UserToken? get token => _preferencesHelper.token;

  @override
  Future<bool?> setToken(UserToken? value) {
    return _preferencesHelper.setToken(value);
  }
}
