part of 'auth_usecase.dart';

@Injectable(as: AuthUsecase)
class AuthInteractorImpl implements AuthUsecase {
  AuthInteractorImpl(this._credentialSource, this._sessionStore);

  final AuthCredentialSource _credentialSource;
  final AuthSessionStore _sessionStore;

  @override
  Future<bool> loginWithPhoneNumberPassword({
    required String phoneNumber,
    required String password,
  }) async {
    await _sessionStore.clearAuthSession();

    final session = await _credentialSource.signIn(
      phoneNumber: phoneNumber,
      password: password,
    );
    if (session == null) {
      return false;
    }

    await _sessionStore.saveAuthSession(session);
    return true;
  }
}
