import '../../../common/definitions.dart';

const entity =
    '''// ignore_for_file: invalid_annotation_target

import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '$moduleNameKey.entity.freezed.dart';
part '$moduleNameKey.entity.g.dart';

/// A $classNameKey as the domain layer sees it.
///
/// `id` is load-bearing: the generated detail route and coordinator use it to
/// build deep links.
// TODO(template): replace these placeholder fields with the real shape.
@freezed
abstract class $classNameKey with _\$$classNameKey {
  @JsonSerializable(explicitToJson: true, includeIfNull: false)
  const factory $classNameKey({
    @JsonKey(name: 'id', fromJson: asOrNull) final String? id,
    @JsonKey(name: 'name', fromJson: asOrNull) final String? name,
  }) = _$classNameKey;

  const $classNameKey._();

  factory $classNameKey.fromJson(Map<String, Object?> json) =>
      _\$${classNameKey}FromJson(json);
}
''';
