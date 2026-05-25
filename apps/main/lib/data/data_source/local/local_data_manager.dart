import 'dart:convert';

import 'package:core/core.dart';
import 'package:data_source/data_source.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/auth_session.dart';
import '../../../domain/repositories/auth_session_store.dart';
import '../../models/auth_user_mapping.dart';
import 'preferences_key.dart';

abstract class AppPreferenceData extends CoreAppPreferenceData {
  UserModel? get userInfo;
  Future<bool> saveUserInfo(UserModel? user);
}

@lazySingleton
class LocalDataManager extends CoreLocalDataManager
    implements AppPreferenceData, AuthSessionStore {
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

  @override
  Future clearAuthSession() {
    return Future.wait([setToken(null), saveUserInfo(null)]);
  }

  @override
  Future saveAuthSession(AuthSession session) {
    return Future.wait([
      setToken(session.token.toUserToken()),
      saveUserInfo(session.user.toUserModel()),
    ]);
  }
}
