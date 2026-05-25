import '../entities/auth_session.dart';

abstract class AuthCredentialSource {
  Future<AuthSession?> signIn({
    required String phoneNumber,
    required String password,
  });
}
