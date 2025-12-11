import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core.dart';

class LoggerInterceptor extends Interceptor {
  const LoggerInterceptor();

  String _formatData(dynamic data, {int maxLength = 1000}) {
    if (data == null) {
      return 'null';
    }
    final dataStr = data.toString();
    if (dataStr.length <= maxLength) {
      return dataStr;
    }

    final truncated = dataStr.substring(0, maxLength);
    final remaining = dataStr.length - maxLength;
    return '''$truncated... ($remaining more characters, ${dataStr.length} total)''';
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['startTime'] = DateTime.now(); // save time for duration calc
    if (!kIsWeb) {
      log(
        '🌐 ${options.method} ${options.baseUrl}${options.path}\n'
        'Headers: ${options.headers}\n'
        'Query: ${options.queryParameters}\n'
        'Body: ${options.data}',
        time: DateTime.now(),
        name: 'HTTP Request',
        level: 800, // INFO level
      );
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['startTime'] as DateTime? ??
        DateTime.now();
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    if (!kIsWeb) {
      log(
        '''✅ ${response.requestOptions.method} ${response.requestOptions.baseUrl}${response.requestOptions.path}\n'''
        'Status: ${response.statusCode}\n'
        'Duration: ${duration.inMilliseconds}ms\n'
        'Data: ${_formatData(response.data)}',
        time: DateTime.now(),
        name: 'HTTP Response',
        level: 800, // INFO level
      );
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
    final duration = endTime.difference(startTime);

    if (!kIsWeb) {
      log(
        '''❌ ${error.requestOptions.method} ${error.requestOptions.baseUrl}${error.requestOptions.path}\n'''
        'Status: ${error.response?.statusCode ?? 'N/A'}\n'
        'Type: ${error.type.name}\n'
        'Duration: ${duration.inMilliseconds}ms\n'
        'Message: ${error.message}\n'
        'Error: ${error.error}\n'
        'Response: ${_formatData(error.response?.data)}',
        time: DateTime.now(),
        error: error,
        name: 'HTTP Error',
        level: 1000, // SEVERE level
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
