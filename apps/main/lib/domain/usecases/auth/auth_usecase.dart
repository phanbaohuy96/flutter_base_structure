import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:data_source/data_source.dart';
import 'package:injectable/injectable.dart';

import '../../../data/data_source/local/local_data_manager.dart';
import '../../entities/auth/response.dart';
import 'demo_users.dart';

part 'auth_usecase.impl.dart';

abstract class AuthUsecase {
  Future<AuthResponse> loginWithPhoneNumberPassword({
    required String phoneNumber,
    required String password,
  });

  Future<AuthResponse> authWithUserToken(UserToken token);

  @Deprecated('Example Implementation: Suspended soon')
  Future<AuthResponse> loginWithUser({required UserModel user});

  @Deprecated('Example Implementation: Suspended soon')
  Future<List<UserModel>> getUsers();
}
