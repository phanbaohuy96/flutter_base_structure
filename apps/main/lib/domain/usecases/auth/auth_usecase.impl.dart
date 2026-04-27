/// This file contains a sample implementation of the `AuthUsecase` interface.
/// It provides methods for handling authentication-related operations, such as:
/// - Logging in with a phone number and password
/// - Authenticating with a user token
/// - Logging in with a user model
/// - Retrieving a list of users (currently hardcoded)
///
/// Note: This implementation is intended as a sample and may include hardcoded
/// values or mock data. Replace these with actual server-side integrations
/// or dynamic data as needed.

part of 'auth_usecase.dart';

@Injectable(as: AuthUsecase)
class AuthInteractorImpl extends AuthUsecase {
  AuthInteractorImpl(this.localDataManager);

  final LocalDataManager localDataManager;

  @override
  Future<AuthResponse> loginWithPhoneNumberPassword({
    required String phoneNumber,
    required String password,
  }) async {
    // Clear token if any
    await localDataManager.setToken(null);
    final token = await Future.value(
      UserToken(accessToken: 'accessToken', type: TokenType.bearer),
    );

    return authWithUserToken(token);
  }

  @override
  Future<AuthResponse> authWithUserToken(UserToken token) async {
    unawaited(localDataManager.saveUserInfo(null));

    UserModel? user;
    await localDataManager.setToken(token);
    try {
      user = await Future.value(const UserModel());
    } catch (e) {
      // Clear token if any error occurs
      await localDataManager.setToken(null);
      rethrow;
    }

    if (user == null) {
      // Currently we not support this role yet
      return AuthResponse(result: LoginResultType.unsupportedRole);
    }
    unawaited(localDataManager.saveUserInfo(user));

    return AuthSuccessResponse(user: user);
  }

  @override
  @Deprecated('Example Implementation: Suspended soon')
  Future<AuthResponse> loginWithUser({required UserModel user}) async {
    final credentials = user.phoneNumber?.split('-');
    if (credentials == null || credentials.length < 2) {
      return AuthResponse(result: LoginResultType.failed);
    }
    final users = await getUsers();
    final userModel = users.firstWhereOrNull(
      (element) => element.phoneNumber == credentials[0],
    );
    if (userModel == null) {
      return AuthResponse(result: LoginResultType.failed);
    }
    return AuthSuccessResponse(user: userModel);
  }

  @override
  @Deprecated('Example Implementation: Suspended soon')
  Future<List<UserModel>> getUsers() {
    /// Return the hardcode user roles
    ///
    return Future.value([...demoUsers]);
  }
}
