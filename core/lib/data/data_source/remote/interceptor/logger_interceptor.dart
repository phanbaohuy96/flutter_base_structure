import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core.dart';

class LoggerInterceptor extends Interceptor {
  const LoggerInterceptor();

  static String _formatDataSync(dynamic data, {int maxLength = 1000}) {
    if (data == null) {
      return 'null';
    }
    var dataStr = '';
    try {
      dataStr = jsonEncode(data);
    } catch (_) {
      dataStr = data.toString();
    }
    if (dataStr.length <= maxLength) {
      return dataStr;
    }

    final truncated = dataStr.substring(0, maxLength);
    final remaining = dataStr.length - maxLength;
    return '''$truncated... ($remaining more characters, ${dataStr.length} total)''';
  }

  static void _formatDataIsolate(Map<String, dynamic> message) {
    final sendPort = message['sendPort'] as SendPort;
    final data = message['data'];
    final maxLength = message['maxLength'] as int;

    final result = _formatDataSync(data, maxLength: maxLength);
    sendPort.send(result);
  }

  Future<String> _formatData(dynamic data, {int maxLength = 1000}) async {
    // For web or small data, use synchronous version
    if (kIsWeb || data == null) {
      return _formatDataSync(data, maxLength: maxLength);
    }

    // Quick check if data is likely small
    if (data is String && data.length <= maxLength) {
      return data;
    }
    if (data is Map && data.length < 10) {
      return _formatDataSync(data, maxLength: maxLength);
    }
    if (data is List && data.length < 10) {
      return _formatDataSync(data, maxLength: maxLength);
    }

    // For potentially large data, use isolate
    try {
      final receivePort = ReceivePort();
      await Isolate.spawn(_formatDataIsolate, {
        'sendPort': receivePort.sendPort,
        'data': data,
        'maxLength': maxLength,
      });

      final result = await receivePort.first as String;
      return result;
    } catch (_) {
      // Fallback to sync if isolate fails
      return _formatDataSync(data, maxLength: maxLength);
    }
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    super.onRequest(options, handler);

    options.extra['startTime'] = DateTime.now(); // save time for duration calc
    if (!kIsWeb) {
      final formattedData = await _formatData(options.data);
      log(
        '🌐 ${options.method} ${options.baseUrl}${options.path}\n'
        'Headers: ${options.headers}\n'
        'Query: ${options.queryParameters}\n'
        '''Body: $formattedData''',
        time: DateTime.now(),
        name: 'HTTP Request',
        level: 800, // INFO level
      );
    }
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    super.onResponse(response, handler);

    final startTime =
        response.requestOptions.extra['startTime'] as DateTime? ??
        DateTime.now();
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    if (!kIsWeb) {
      final formattedData = await _formatData(response.data);
      log(
        '''✅ ${response.requestOptions.method} ${response.requestOptions.baseUrl}${response.requestOptions.path}\n'''
        'Status: ${response.statusCode}\n'
        'Duration: ${duration.inMilliseconds}ms\n'
        'Data: $formattedData',
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
  }

  @override
  Future<void> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    super.onError(error, handler);

    final startTime =
        error.requestOptions.extra['startTime'] as DateTime? ?? DateTime.now();
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    if (!kIsWeb) {
      final formattedData = await _formatData(error.response?.data);
      log(
        '''❌ ${error.requestOptions.method} ${error.requestOptions.baseUrl}${error.requestOptions.path}\n'''
        'Status: ${error.response?.statusCode ?? 'N/A'}\n'
        'Type: ${error.type.name}\n'
        'Duration: ${duration.inMilliseconds}ms\n'
        'Message: ${error.message}\n'
        'Error: ${error.error}\n'
        'Response: $formattedData',
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
  }
}
