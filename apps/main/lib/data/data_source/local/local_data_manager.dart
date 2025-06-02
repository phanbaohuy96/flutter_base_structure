import 'package:core/core.dart';
import 'package:data_source/data_source.dart';
import 'package:injectable/injectable.dart';

import 'preferences_helper/preferences_helper.dart';

@Injectable()
class LocalDataManager extends CoreLocalDataManager
    implements AppPreferenceData {
  // ignore: unused_field
  final PreferencesHelper _appPrefs;

  LocalDataManager(
    this._appPrefs,
    super.preferencesHelper,
  );

  @override
  Future<bool> saveUserInfo(UserModel? user) {
    return _appPrefs.saveUserInfo(user);
  }

  @override
  UserModel? get userInfo => _appPrefs.userInfo;
}
