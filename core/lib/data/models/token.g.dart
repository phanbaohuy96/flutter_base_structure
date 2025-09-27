// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserToken _$UserTokenFromJson(Map<String, dynamic> json) => UserToken(
      accessToken: asOrNull(json['access_token']),
      refreshToken: asOrNull(json['refresh_token']),
      type: $enumDecodeNullable(_$TokenTypeEnumMap, json['token_type'],
          unknownValue: JsonKey.nullForUndefinedEnumValue),
      scope: asOrNull(json['scope']),
      expireIn: asOrNull(json['expires_in']),
      role: asOrNull(json['role']),
    );

Map<String, dynamic> _$UserTokenToJson(UserToken instance) => <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': _$TokenTypeEnumMap[instance.type],
      'expires_in': instance.expireIn,
      'scope': instance.scope,
      'role': instance.role,
    };

const _$TokenTypeEnumMap = {
  TokenType.bearer: 'Bearer',
  TokenType.jwt: 'jwt',
  TokenType.firebase: 'firebase',
};
