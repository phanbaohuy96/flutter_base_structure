import 'dart:convert';

import 'package:core/core.dart';
import 'package:data_source/data_source.dart';
import 'package:injectable/injectable.dart';

import 'preferences_key.dart';

abstract class AppPreferenceData {
  UserModel? get userInfo;
  Future<bool> saveUserInfo(UserModel? user);
}

@Injectable()
class LocalDataManager extends CoreLocalDataManager
    implements AppPreferenceData {
  LocalDataManager(super.prefs, super.secureStorage);

  @override
  UserModel? get userInfo {
    final source = prefs.getString(PreferencesKey.userInfo);
    if (source.isNullOrEmpty == true) {
      return null;
    }
    return UserModel.fromJson(jsonDecode(source!));
  }

  @override
  Future<bool> saveUserInfo(UserModel? user) {
    if (user == null) {
      return prefs.remove(PreferencesKey.userInfo);
    }
    return prefs.setString(
      PreferencesKey.userInfo,
      jsonEncode(user.toJson()),
    );
  }
}
