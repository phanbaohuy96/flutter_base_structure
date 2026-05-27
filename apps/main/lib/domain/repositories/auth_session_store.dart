import '../entities/auth_session.dart';

/// Domain port for persisting (and dropping) the authenticated session.
///
/// Adapters live in the data layer and translate [AuthSession] to whatever
/// storage seam the app uses. The template binds this to `LocalDataManager`.
abstract class AuthSessionStore {
  /// Drops any persisted token and user info, leaving the app signed out.
  Future<void> clearAuthSession();

  /// Persists [session] so subsequent launches resolve as authenticated.
  Future<void> saveAuthSession(AuthSession session);
}
