// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: asOrNull(json['id']),
  name: asOrNull(json['name']),
  email: asOrNull(json['email']),
  phoneNumber: asOrNull(json['phone_number']),
  avatar: readAsMapOrNull(json, 'avatar') == null
      ? null
      : CloudFile.fromJson(
          readAsMapOrNull(json, 'avatar') as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'avatar': instance.avatar?.toJson(),
};
