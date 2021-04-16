// import 'package:hive/hive.dart';
import '../../../common/components/preferences_helper/preferences_helper.dart';
import '../../../presentation/theme/theme_data.dart';

class LocalDataManager {
  //-------------> Singleton
  static LocalDataManager? _instance;

  factory LocalDataManager() {
    return _instance ??= LocalDataManager._();
  }

  LocalDataManager._();
  //-------------> Singleton

  // static Box _myBox;

  static PreferencesHelper? _preferencesHelper;

  static Future<void> init() async {
    _instance = LocalDataManager();
    await _instance!._init();
  }

  Future<void> _init() async {
    // Hive.init(Directory.current.path);
    _preferencesHelper = PreferencesHelper();
    await _preferencesHelper!.init();
    // _myBox = await Hive.openBox(Config.appConfig.appName);
  }

  ////////////////////////////////////////////////////////
  ///             Preferences helper
  ///
  static SupportedTheme getTheme() {
    assert(_preferencesHelper != null, 'Must call init first!');
    return _preferencesHelper!.getTheme();
  }

  static Future<bool?> setTheme(String data) {
    assert(_preferencesHelper != null, 'Must call init first!');
    return _preferencesHelper!.setTheme(data);
  }

  static String? getLocalization() {
    assert(_preferencesHelper != null, 'Must call init first!');
    return _preferencesHelper!.getLocalization();
  }

  static Future<bool?> saveLocalization(String locale) {
    assert(_preferencesHelper != null, 'Must call init first!');
    return _preferencesHelper!.saveLocalization(locale);
  }
}
