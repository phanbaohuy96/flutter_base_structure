import 'package:json_annotation/json_annotation.dart';

import '../../common/utils.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  @JsonKey(name: 'error_code', fromJson: asOrNull)
  final String? errorCode;
  @JsonKey(name: 'error', fromJson: asOrNull)
  final String? error;
  @JsonKey(name: 'errors', fromJson: asOrNull)
  final String? errors;
  @JsonKey(name: 'msg', fromJson: asOrNull)
  final String? msg;
  @JsonKey(name: 'message', fromJson: asOrNull)
  final String? message;
  @JsonKey(name: 'data', includeIfNull: false)
  final T? _data;

  ApiResponse({
    this.errorCode,
    this.error,
    this.errors,
    this.msg,
    this.message,
    T? data,
  }) : _data = data;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromT,
  ) {
    final response = _$ApiResponseFromJson(json, fromT);

    return response;
  }

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  T get data => _getData();

  bool get success {
    if ([
      error.isNotNullOrEmpty,
      errors.isNotNullOrEmpty,
      errorCode.isNotNullOrEmpty,
    ].any((e) => e)) {
      return false;
    }
    return _data != null;
  }

  T _getData() {
    return _data as T;
  }
}
