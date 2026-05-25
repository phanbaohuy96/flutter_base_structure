import '../entities/auth_session.dart';

abstract class AuthSessionStore {
  Future clearAuthSession();
  Future saveAuthSession(AuthSession session);
}
