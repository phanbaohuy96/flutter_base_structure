import 'package:dio/dio.dart';

class HeaderInterceptor extends Interceptor {
  final Map<String, String> Function() getHeader;

  HeaderInterceptor({required this.getHeader});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers = getHeader.call();
    super.onRequest(options, handler);
  }
}
