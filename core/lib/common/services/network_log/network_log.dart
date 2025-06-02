import 'dart:convert';

import 'package:dio/dio.dart';

class NetworkLog {
  final String method;
  final String url;
  final dynamic requestBody;
  final int? statusCode;
  final dynamic responseBody;
  final DateTime timestamp;
  final bool error;
  final RequestOptions options;
  final Map<String, dynamic> requestHeaders;
  final DateTime startTime;
  final Duration duration;

  NetworkLog({
    required this.method,
    required this.url,
    this.requestBody,
    this.statusCode,
    this.responseBody,
    required this.timestamp,
    required this.error,
    required this.options,
    required this.requestHeaders,
    required this.startTime,
    required this.duration,
  });

  String buildCurlCommand() {
    final components = <String>['curl -i'];
    if (options.method.toUpperCase() != 'GET') {
      components.add('-X ${options.method}');
    }

    options.headers.forEach((k, v) {
      if (k != 'Cookie') {
        components.add('-H "$k: $v"');
      }
    });

    if (options.data != null) {
      // FormData can't be JSON-serialized, so keep only their fields attributes
      if (options.data is FormData) {
        options.data = Map.fromEntries(options.data.fields);
      }

      final data = json.encode(options.data).replaceAll('"', '\\"');
      components.add('-d "$data"');
    }

    components.add('"${options.uri.toString()}"');

    return components.join(' \\\n\t');
  }
}
