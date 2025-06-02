// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: asOrNull(json['id']),
      firstName: asOrNull(json['first_name']),
      lastName: asOrNull(json['last_name']),
      email: asOrNull(json['email']),
      phoneNumber: asOrNull(json['phone_number']),
      status: asOrNull(json['status']),
      profile: UserModel._readUserProfileValue(json, 'profile') == null
          ? null
          : UserProfile.fromJson(
              UserModel._readUserProfileValue(json, 'profile')
                  as Map<String, dynamic>),
      avatar: json['avatar'] == null
          ? null
          : CloudFile.fromJson(json['avatar'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'status': instance.status,
      'profile': instance.profile?.toJson(),
      'avatar': instance.avatar?.toJson(),
    };

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      id: asOrNull(json['id']),
      status: asOrNull(json['status']),
      role: $enumDecodeNullable(_$UserProfileRoleEnumMap, json['role'],
          unknownValue: JsonKey.nullForUndefinedEnumValue),
    );

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'role': _$UserProfileRoleEnumMap[instance.role],
    };

const _$UserProfileRoleEnumMap = {
  UserProfileRole.user: 'user',
};
