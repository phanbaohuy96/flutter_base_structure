// ignore_for_file: invalid_annotation_target

import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  @JsonKey(name: 'id', fromJson: asOrNull)
  final String? id;
  @JsonKey(name: 'first_name', fromJson: asOrNull)
  final String? firstName;
  @JsonKey(name: 'last_name', fromJson: asOrNull)
  final String? lastName;
  @JsonKey(name: 'email', fromJson: asOrNull)
  final String? email;
  @JsonKey(name: 'phone_number', fromJson: asOrNull)
  final String? phoneNumber;
  @JsonKey(name: 'status', fromJson: asOrNull)
  final String? status;
  @JsonKey(name: 'profile', readValue: _readUserProfileValue)
  final UserProfile? profile;
  @JsonKey(name: 'avatar')
  final CloudFile? avatar;

  const UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.status,
    this.profile,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  String get fullName => [
        if (firstName.isNotNullOrEmpty) firstName,
        if (lastName.isNotNullOrEmpty) lastName,
      ].join('');

  static Object? _readUserProfileValue(Map p1, String p2) {
    if (p1[p2] is List) {
      return (p1[p2] as List).first;
    }
    if (p1['profiles'] is List) {
      return (p1['profiles'] as List).first;
    }
    return p1[p2];
  }
}

@JsonEnum(valueField: 'id')
enum UserProfileRole {
  user('user'),
  ;

  const UserProfileRole(this.id);
  final String id;
}

@JsonSerializable(explicitToJson: true)
class UserProfile {
  @JsonKey(name: 'id', fromJson: asOrNull)
  final int? id;
  @JsonKey(name: 'status', fromJson: asOrNull)
  final String? status;
  @JsonKey(
    name: 'role',
    unknownEnumValue: JsonKey.nullForUndefinedEnumValue,
  )
  final UserProfileRole? role;

  UserProfile({
    this.id,
    this.status,
    this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
