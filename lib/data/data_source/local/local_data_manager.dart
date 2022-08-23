import '../../../di/di.dart';
import '../../../presentation/theme/theme_data.dart';
import 'preferences_helper/preferences_helper.dart';

class LocalDataManager implements AppPreferenceData {
  late final PreferencesHelper _preferencesHelper = injector.get();
  // final Box<Province>? _administrativeHiveBox;

  LocalDataManager(
      // this._administrativeHiveBox,
      );

  static Future<LocalDataManager> init() async {
    // Hive.registerAdapter(ProvinceAdapter());

    // return Future.value(
    //   LocalDataManager(
    //     await Hive.openBox<Province>(
    //       'administrative_hive_box',
    //     ),
    //   ),
    // );
    return Future.value(LocalDataManager());
  }

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
