import 'package:injectable/injectable.dart';

import '../../repositories/auth_credential_source.dart';
import '../../repositories/auth_session_store.dart';

part 'auth_usecase.impl.dart';

abstract class AuthUsecase {
  /// Authenticates with phone + password. Clears any existing session first,
  /// then persists the new session on success. Returns `true` when the
  /// credentials are accepted, or `false` when the login is rejected.
  Future<bool> loginWithPhoneNumberPassword({
    required String phoneNumber,
    required String password,
  });
}
