// ignore_for_file: invalid_annotation_target

import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  @JsonKey(name: 'id', fromJson: asOrNull)
  final String? id;
  @JsonKey(name: 'name', fromJson: asOrNull)
  final String? name;
  @JsonKey(name: 'email', fromJson: asOrNull)
  final String? email;
  @JsonKey(name: 'phone_number', fromJson: asOrNull)
  final String? phoneNumber;
  @JsonKey(name: 'avatar', readValue: readAsMapOrNull)
  final CloudFile? avatar;

  const UserModel({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
