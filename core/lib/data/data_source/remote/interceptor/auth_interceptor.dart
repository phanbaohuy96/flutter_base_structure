import 'package:dio/dio.dart';

import '../../../../common/services/header/request_header_service.dart';
import '../../../../common/utils.dart';
import '../../../data.dart';

class AutoRefreshTokenInterceptor extends Interceptor {
  final String? Function()? getToken;
  final Future<UserToken?> Function(String, RequestOptions) refreshToken;
  final void Function()? onLogoutRequest;
  final String? refreshTokenPath;
  final String? logoutPath;

  AutoRefreshTokenInterceptor({
    required this.refreshToken,
    this.getToken,
    this.onLogoutRequest,
    this.refreshTokenPath,
    this.logoutPath,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getToken?.call();
    if (token?.isNotEmpty == true) {
      options.headers[RequestHeaderKey.authorization.key] = token;
    }
    final headerToken = options.headers[RequestHeaderKey.authorization.key];

    if (headerToken != null && options.path != refreshTokenPath) {
      if (JwtUtils().isAboutToExpire(token ?? '')) {
        refreshToken(token ?? '', options).then((newToken) {
          options.headers[RequestHeaderKey.authorization.key] =
              newToken?.authorization;
          _logoutRequestCallBack(options);
          super.onRequest(options, handler);
        }).catchError((e, stackTrace) {
          _logoutRequestCallBack(options);
          handler.reject(e);
        });
      } else {
        _logoutRequestCallBack(options);
        super.onRequest(options, handler);
      }
    } else {
      _logoutRequestCallBack(options);
      super.onRequest(options, handler);
    }
  }

  void _logoutRequestCallBack(RequestOptions options) {
    if (options.path == logoutPath) {
      onLogoutRequest?.call();
    }
  }
}
