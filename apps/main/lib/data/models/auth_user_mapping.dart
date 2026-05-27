import 'package:core/core.dart';
import 'package:data_source/data_source.dart';

import '../../domain/entities/auth_session.dart';

extension AuthUserModelMapping on UserModel {
  AuthUser toAuthUser() {
    return AuthUser(
      id: id,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
    );
  }
}

extension UserModelAuthMapping on AuthUser {
  UserModel toUserModel() {
    return UserModel(
      id: id,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
    );
  }
}

extension UserTokenAuthMapping on AuthToken {
  UserToken toUserToken() {
    return UserToken(
      accessToken: accessToken,
      type: type.toTokenType(),
    );
  }
}

extension TokenTypeAuthMapping on AuthTokenType {
  TokenType toTokenType() {
    switch (this) {
      case AuthTokenType.bearer:
        return TokenType.bearer;
    }
  }
}
