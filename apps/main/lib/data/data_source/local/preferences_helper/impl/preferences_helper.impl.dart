part of '../preferences_helper.dart';

@Injectable(as: PreferencesHelper)
class PreferencesHelperImpl extends PreferencesHelper {
  // ignore: unused_field
  final SharedPreferences _prefs;

  PreferencesHelperImpl(this._prefs);

  @override
  UserModel? get userInfo {
    final source = _prefs.getString(PreferencesKey.userInfo);

    if (source.isNullOrEmpty == true) {
      return null;
    }

    return UserModel.fromJson(jsonDecode(source!));
  }

  @override
  Future<bool> saveUserInfo(UserModel? user) {
    if (user == null) {
      return _prefs.remove(PreferencesKey.userInfo);
    }
    return _prefs.setString(
      PreferencesKey.userInfo,
      jsonEncode(user.toJson()),
    );
  }
}
