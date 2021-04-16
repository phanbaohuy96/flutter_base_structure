import 'package:dio/dio.dart';

import '../http_constants.dart';

class AuthInterceptor extends Interceptor {
  final String Function() getToken;

  AuthInterceptor(this.getToken);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (getToken != null) {
      options.headers[HttpConstants.authorization] = getToken();
    }
    super.onRequest(options, handler);
  }
}
