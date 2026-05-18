import '../../../common/definations.dart';

const jsonSerializableModel = '''

import 'package:core/core.dart';
import 'package:json_annotation/json_annotation.dart';

part '$moduleNameKey.g.dart';

@JsonSerializable(explicitToJson: true)
class $classNameKey { 
  @JsonKey(name: 'id', fromJson: asOrNull)
  final String? id;

  $classNameKey({
    this.id,
  });

  factory $classNameKey.fromJson(Map<String, dynamic> json) =>
      _\$${classNameKey}FromJson(json);

  Map<String, dynamic> toJson() => _\$${classNameKey}ToJson(this);
}''';
