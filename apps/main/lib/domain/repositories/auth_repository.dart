import 'package:data_source/data_source.dart';

/// Domain contract for authenticating a user.
///
/// Adapters live in `data/repositories/` and `data/data_source/remote/auth/`.
/// The template ships a mock-backed implementation; swap the DI binding to
/// wire in a real network adapter.
abstract class AuthRepository {
  /// Returns the authenticated user when credentials match, or `null` when
  /// no user matches the supplied phone/password pair.
  Future<UserModel?> authenticate({
    required String phoneNumber,
    required String password,
  });
}
