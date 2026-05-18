import 'package:dio/dio.dart';

import '../../../../common/services/header/request_header_service.dart';

class HeaderInterceptor extends Interceptor {
  final RequestHeaderService requestHeaderService;

  HeaderInterceptor({required this.requestHeaderService});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers = {
      ...requestHeaderService.requestHeaders,

      // Allow overriding headers from request
      ...options.headers,
    };
    super.onRequest(options, handler);
  }
}
