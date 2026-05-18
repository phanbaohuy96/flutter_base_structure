import 'dart:convert';

import 'package:core/core.dart';
import 'package:data_source/data_source.dart';
import 'package:injectable/injectable.dart';

import 'preferences_key.dart';

part 'impl/preferences_helper.impl.dart';

abstract class PreferencesHelper extends AppPreferenceData {}

abstract class AppPreferenceData {
  UserModel? get userInfo;

  Future<bool> saveUserInfo(UserModel? user);
}
