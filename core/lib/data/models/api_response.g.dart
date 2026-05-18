// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    ApiResponse<T>(
      errorCode: asOrNull(json['error_code']),
      error: asOrNull(json['error']),
      errors: asOrNull(json['errors']),
      msg: asOrNull(json['msg']),
      message: asOrNull(json['message']),
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
    );

Map<String, dynamic> _$ApiResponseToJson<T>(
  ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'error_code': instance.errorCode,
      'error': instance.error,
      'errors': instance.errors,
      'msg': instance.msg,
      'message': instance.message,
      'data': toJsonT(instance.data),
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);
