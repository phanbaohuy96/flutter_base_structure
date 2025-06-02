import 'package:dio/dio.dart';

import '../../../../core.dart';

class HeaderInterceptor extends Interceptor {
  final RequestHeaderService requestHeaderService;

  HeaderInterceptor({required this.requestHeaderService});

  @override
  Future onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requestHeaders = await requestHeaderService.requestHeaders;
    options.headers = {
      ...requestHeaders,

      // Allow overriding headers from request
      ...options.headers,
    };
    options.headers.removeWhere(
      (key, value) => value == null || (value is String && value.isNullOrEmpty),
    );
    super.onRequest(options, handler);
  }
}
