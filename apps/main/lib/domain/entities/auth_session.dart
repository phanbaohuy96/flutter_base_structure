enum AuthTokenType { bearer }

class AuthToken {
  const AuthToken({
    required this.accessToken,
    required this.type,
  });

  final String accessToken;
  final AuthTokenType type;
}

/// Minimal identity projection carried inside an [AuthSession]. Intentionally
/// narrower than the data-layer `UserModel`: fields not listed here (e.g.
/// `avatar`) are dropped when mapping in and out, so add them here too if the
/// session needs to round-trip them through the session store.
class AuthUser {
  const AuthUser({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
  });

  final String? id;
  final String? name;
  final String? email;
  final String? phoneNumber;
}

class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
  });

  final AuthToken token;
  final AuthUser user;
}
