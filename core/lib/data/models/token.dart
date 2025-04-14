import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../common/utils.dart';

part 'token.g.dart';

@JsonEnum(valueField: 'value')
enum TokenType {
  bearer('Bearer'),
  jwt('jwt'),
  firebase('firebase'),
  ;

  const TokenType(this.value);
  final String value;
}

@JsonSerializable(explicitToJson: true)
class UserToken {
  @JsonKey(name: 'access_token', fromJson: asOrNull)
  final String? accessToken;
  @JsonKey(name: 'refresh_token', fromJson: asOrNull)
  final String? refreshRoken;
  @JsonKey(
    name: 'token_type',
    unknownEnumValue: JsonKey.nullForUndefinedEnumValue,
  )
  final TokenType? type;
  @JsonKey(name: 'expires_in', fromJson: asOrNull)
  int? expireIn;
  @JsonKey(name: 'scope', fromJson: asOrNull)
  final List<String>? scope;
  @JsonKey(name: 'role', fromJson: asOrNull)
  final String? role;

  UserToken({
    this.accessToken,
    this.refreshRoken,
    this.type,
    this.scope,
    this.expireIn,
    this.role,
  });

  UserToken copyWith({
    ValueGetter<String?>? accessToken,
    ValueGetter<String?>? refreshRoken,
    ValueGetter<TokenType?>? type,
    ValueGetter<int?>? expireIn,
    ValueGetter<List<String>?>? scope,
    ValueGetter<String?>? role,
  }) {
    return UserToken(
      accessToken: accessToken != null ? accessToken() : this.accessToken,
      refreshRoken: refreshRoken != null ? refreshRoken() : this.refreshRoken,
      type: type != null ? type() : this.type,
      expireIn: expireIn != null ? expireIn() : this.expireIn,
      scope: scope != null ? scope() : this.scope,
      role: role != null ? role() : this.role,
    );
  }

  factory UserToken.fromJson(Map<String, dynamic> json) =>
      _$UserTokenFromJson(json);

  Map<String, dynamic> toJson() => _$UserTokenToJson(this);

  @override
  bool operator ==(covariant UserToken other) {
    if (identical(this, other)) {
      return true;
    }

    return other.accessToken == accessToken &&
        other.type == type &&
        other.role == role;
  }

  @override
  int get hashCode => accessToken.hashCode ^ type.hashCode;

  String get authorization => [
        if (type != null && type != TokenType.jwt) type?.value,
        accessToken,
      ].join(' ');

  bool get isValid => type != null && accessToken.isNotNullOrEmpty;

  @override
  String toString() {
    return '''Token(
  token: $accessToken, 
  refreshRoken: $refreshRoken, 
  type: $type, 
  expireIn: $expireIn, 
  scope: $scope,
)''';
  }
}
