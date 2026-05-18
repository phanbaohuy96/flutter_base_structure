import '../../../common/definitions.dart';

const freezedModel =
    '''// ignore_for_file: invalid_annotation_target

import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '$moduleNameKey.freezed.dart';
part '$moduleNameKey.g.dart';

@freezed 
sealed class $classNameKey with _\$$classNameKey {
  @JsonSerializable(explicitToJson: true, includeIfNull: false)
  const factory $classNameKey({
    @JsonKey(name: 'id', fromJson: asOrNull)
    final String? id,
  }) = _$classNameKey;

  const $classNameKey._();

  factory $classNameKey.fromJson(Map<String, Object?> json) =>
      _\$${classNameKey}FromJson(json);
}''';
