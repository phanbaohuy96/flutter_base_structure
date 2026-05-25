enum AuthTokenType { bearer }

class AuthToken {
  const AuthToken({
    required this.accessToken,
    required this.type,
  });

  final String accessToken;
  final AuthTokenType type;
}

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
