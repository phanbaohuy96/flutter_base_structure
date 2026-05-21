part of 'auth_usecase.dart';

@Injectable(as: AuthUsecase)
class AuthInteractorImpl implements AuthUsecase {
  AuthInteractorImpl(this._authRepository, this._localDataManager);

  final AuthRepository _authRepository;
  final AppPreferenceData _localDataManager;

  @override
  Future<UserModel?> loginWithPhoneNumberPassword({
    required String phoneNumber,
    required String password,
  }) async {
    await Future.wait([
      _localDataManager.setToken(null),
      _localDataManager.saveUserInfo(null),
    ]);

    final user = await _authRepository.authenticate(
      phoneNumber: phoneNumber,
      password: password,
    );
    if (user == null) {
      return null;
    }

    await Future.wait([
      _localDataManager.setToken(
        UserToken(accessToken: 'demo-access-token', type: TokenType.bearer),
      ),
      _localDataManager.saveUserInfo(user),
    ]);
    return user;
  }
}
