import '../entities/auth_session.dart';

/// Domain port for exchanging credentials for an [AuthSession].
///
/// The template binds this to a mock adapter; real apps rebind the DI key to
/// a network-backed implementation.
abstract class AuthCredentialSource {
  /// Returns the [AuthSession] when credentials match, or `null` when the
  /// supplied phone/password pair is rejected.
  Future<AuthSession?> signIn({
    required String phoneNumber,
    required String password,
  });
}
