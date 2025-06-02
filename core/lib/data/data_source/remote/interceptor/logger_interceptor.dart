import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../common/services/network_log/network_log_service.dart';
import '../../../../common/utils.dart';

class LoggerInterceptor extends Interceptor {
  //For case response data is too large, dont need to show on log
  final bool Function(Response)? ignoreResponseDataLog;

  LoggerInterceptor({this.ignoreResponseDataLog});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['startTime'] = DateTime.now(); // save time for duration calc
    if (!kIsWeb) {
      logUtils.i({
        'from': 'onRequest',
        'Time': DateTime.now().toString(),
        'baseUrl': options.baseUrl,
        'path': options.path,
        'headers': options.headers,
        'extra': options.extra,
        'method': options.method,
        'requestData': options.data,
        'queryParameters': options.queryParameters,
      });
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['startTime'] as DateTime? ??
        DateTime.now();
    final endTime = DateTime.now();

    if (!kIsWeb) {
      logUtils.i({
        'from': 'onResponse',
        'Time': DateTime.now().toString(),
        'statusCode': response.statusCode,
        'baseUrl': response.requestOptions.baseUrl,
        'path': response.requestOptions.path,
        'method': response.requestOptions.method,
        if (ignoreResponseDataLog == null ||
            ignoreResponseDataLog?.call(response) == false)
          'responseData': response.data,
      });
    }

    NetworkLoggerService().add(
      NetworkLog(
        method: response.requestOptions.method,
        url: response.requestOptions.uri.toString(),
        requestBody: response.requestOptions.data,
        statusCode: response.statusCode,
        responseBody: response.data,
        timestamp: DateTime.now(),
        options: response.requestOptions,
        error: false,
        requestHeaders: Map<String, dynamic>.from(
          response.requestOptions.headers,
        ),
        startTime: startTime,
        duration: endTime.difference(startTime),
      ),
    );

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    final startTime =
        error.requestOptions.extra['startTime'] as DateTime? ?? DateTime.now();
    final endTime = DateTime.now();
    if (!kIsWeb) {
      logUtils.e(
        {
          'from': 'onError',
          'Time': DateTime.now().toString(),
          'baseUrl': error.requestOptions.baseUrl,
          'header': error.requestOptions.headers,
          'extra': error.requestOptions.extra,
          'path': error.requestOptions.path,
          'type': error.type.toString(),
          'message': error.message,
          'statusCode': error.response?.statusCode,
          'error': error.error.toString(),
          'responseData': error.response?.data,
        },
        error,
      );
    }
    NetworkLoggerService().add(
      NetworkLog(
        method: error.requestOptions.method,
        url: error.requestOptions.uri.toString(),
        requestBody: error.requestOptions.data,
        statusCode: error.response?.statusCode,
        responseBody: error.response?.data,
        timestamp: DateTime.now(),
        error: true,
        options: error.requestOptions,
        requestHeaders: Map<String, dynamic>.from(error.requestOptions.headers),
        startTime: startTime,
        duration: endTime.difference(startTime),
      ),
    );
    super.onError(error, handler);
  }
}
