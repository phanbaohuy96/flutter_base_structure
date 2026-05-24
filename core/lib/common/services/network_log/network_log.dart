import 'dart:convert';

import 'package:dio/dio.dart';

const String redactedNetworkLogValue = '***REDACTED***';

const _sensitiveKeyPatternSource = [
  'authorization',
  'password',
  'passwd',
  'token',
  'secret',
  'apikey',
  'session',
  'cookie',
  'credential',
  'privatekey',
];

final _sensitiveKeyPattern = RegExp(_sensitiveKeyPatternSource.join('|'));

bool _isSensitiveKey(Object? key) {
  final normalized = key.toString().toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9]'),
    '',
  );
  return _sensitiveKeyPattern.hasMatch(normalized);
}

Map<String, dynamic> redactNetworkLogHeaders(Map<dynamic, dynamic> headers) {
  return headers.map((key, value) {
    return MapEntry(
      key.toString(),
      _isSensitiveKey(key) ? redactedNetworkLogValue : value,
    );
  });
}

dynamic redactNetworkLogData(dynamic data) {
  if (data is FormData) {
    return redactNetworkLogData(Map.fromEntries(data.fields));
  }
  if (data is Map) {
    return data.map((key, value) {
      return MapEntry(
        key,
        _isSensitiveKey(key)
            ? redactedNetworkLogValue
            : redactNetworkLogData(value),
      );
    });
  }
  if (data is List) {
    return data.map(redactNetworkLogData).toList();
  }
  return data;
}

String redactNetworkLogUrl(String url) {
  try {
    final uri = Uri.parse(url);
    if (uri.queryParameters.isEmpty) {
      return url;
    }
    final redactedQuery = redactNetworkLogData(uri.queryParameters) as Map;
    return uri
        .replace(
          queryParameters: redactedQuery.map(
            (key, value) => MapEntry(key.toString(), value?.toString()),
          ),
        )
        .toString();
  } catch (_) {
    return url;
  }
}

String _shellQuote(String value) {
  return "'${value.replaceAll("'", "'\"'\"'")}'";
}

class NetworkLog {
  final String method;
  final String url;
  final dynamic requestBody;
  final int? statusCode;
  final dynamic responseBody;
  final DateTime timestamp;
  final bool error;
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
    required this.requestHeaders,
    required this.startTime,
    required this.duration,
  });

  String buildCurlCommand() {
    final components = <String>['curl', '-i'];
    if (method.toUpperCase() != 'GET') {
      components.addAll(['-X', _shellQuote(method)]);
    }

    requestHeaders.forEach((key, value) {
      components.addAll(['-H', _shellQuote('$key: $value')]);
    });

    if (requestBody != null) {
      final data = json.encode(requestBody);
      components.addAll(['-d', _shellQuote(data)]);
    }

    components.add(_shellQuote(url));

    return components.join(' \\\n\t');
  }
}
