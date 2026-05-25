import 'package:injectable/injectable.dart';

import '../../repositories/auth_credential_source.dart';
import '../../repositories/auth_session_store.dart';

part 'auth_usecase.impl.dart';

abstract class AuthUsecase {
  Future<bool> loginWithPhoneNumberPassword({
    required String phoneNumber,
    required String password,
  });
}
