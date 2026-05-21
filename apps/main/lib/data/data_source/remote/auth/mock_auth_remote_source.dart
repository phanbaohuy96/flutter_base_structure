import 'package:data_source/data_source.dart';
import 'package:injectable/injectable.dart';

import 'auth_remote_source.dart';

/// Demo credential fixture used by [MockAuthRemoteSource].
///
/// The template demonstrates the integration shape across data → domain →
/// presentation. Real apps replace this with a network-backed adapter by
/// rebinding the [AuthRemoteSource] DI key.
class _DemoCredential {
  const _DemoCredential({
    required this.phoneNumber,
    required this.password,
    required this.user,
  });

  final String phoneNumber;
  final String password;
  final UserModel user;
}

const _demoCredentials = <_DemoCredential>[
  _DemoCredential(
    phoneNumber: '0911357924',
    password: 'password1',
    user: UserModel(
      email: 'user1@yopmail.com',
      phoneNumber: '0911357924',
      name: 'User: 1',
    ),
  ),
  _DemoCredential(
    phoneNumber: '0987654321',
    password: 'password2',
    user: UserModel(
      email: 'user2@yopmail.com',
      phoneNumber: '0987654321',
      name: 'User: 2',
    ),
  ),
];

/// Mock implementation for the auth demo. Matches phone+password against an
/// in-memory fixture. Replace this binding with a Retrofit-backed
/// [AuthRemoteSource] implementation to wire in a real backend.
@Injectable(as: AuthRemoteSource)
class MockAuthRemoteSource implements AuthRemoteSource {
  /// Simulates a network round-trip and returns the matched [UserModel]
  /// when credentials are valid, or `null` otherwise.
  @override
  Future<UserModel?> signIn({
    required String phoneNumber,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (final candidate in _demoCredentials) {
      if (candidate.phoneNumber == phoneNumber &&
          candidate.password == password) {
        return candidate.user;
      }
    }
    return null;
  }
}
