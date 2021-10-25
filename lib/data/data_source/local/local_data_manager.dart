import '../../../presentation/theme/theme_data.dart';
import 'preferences_helper/preferences_helper.dart';

class LocalDataManager implements AppPreferenceData {
  PreferencesHelper? _preferencesHelper;

  Future<void> init() async {
    _preferencesHelper = PreferencesHelperImpl();
    await _preferencesHelper!.init();
  }

  ////////////////////////////////////////////////////////
  ///             Preferences helper
  ///
  @override
  SupportedTheme getTheme() {
    assert(_preferencesHelper != null, 'Must call init first!');
    return _preferencesHelper!.getTheme();
  }

  @override
  Future<bool?> setTheme(String? data) {
    assert(_preferencesHelper != null, 'Must call init first!');
    return _preferencesHelper!.setTheme(data);
  }

  @override
  String? getLocalization() {
    assert(_preferencesHelper != null, 'Must call init first!');
    return _preferencesHelper!.getLocalization();
  }

  @override
  Future<bool?> saveLocalization(String? locale) {
    assert(_preferencesHelper != null, 'Must call init first!');
    return _preferencesHelper!.saveLocalization(locale);
  }

  @override
  Future<bool?> clearData() {
    assert(_preferencesHelper != null, 'Must call init first!');
    return _preferencesHelper!.clearData();
  }
}
