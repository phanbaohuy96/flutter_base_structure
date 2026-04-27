import 'package:json_annotation/json_annotation.dart';

import '../../common/utils.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  @JsonKey(name: 'code', fromJson: asOrNull)
  final int? code;
  @JsonKey(name: 'message', fromJson: asOrNull)
  final String? message;
  @JsonKey(name: 'message_key', fromJson: asOrNull)
  final String? messageKey;
  @JsonKey(name: 'data', includeIfNull: false)
  final T? data;

  ApiResponse({this.code, this.message, this.messageKey, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromT,
  ) {
    final response = _$ApiResponseFromJson(json, fromT);

    return response;
  }

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  bool get success {
    final _code = code ?? 0;
    if ([_code < 200, _code >= 300].any((e) => e)) {
      return false;
    }
    return true;
  }
}
