import 'package:core/core.dart';
import 'package:data_source/data_source.dart';
import 'package:injectable/injectable.dart';

import '../../../data/data_source/local/local_data_manager.dart';
import '../../repositories/auth_repository.dart';

part 'auth_usecase.impl.dart';

abstract class AuthUsecase {
  /// Authenticates a user with phone + password, persists the session token
  /// and user info on success. Returns the authenticated [UserModel] when
  /// credentials match, or `null` when the login is rejected.
  Future<UserModel?> loginWithPhoneNumberPassword({
    required String phoneNumber,
    required String password,
  });
}
