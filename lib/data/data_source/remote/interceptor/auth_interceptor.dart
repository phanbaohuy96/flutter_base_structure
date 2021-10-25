import 'package:dio/dio.dart';

import '../../../../common/constants.dart';
import '../../../../common/utils.dart';
import '../rest_api_repository/api_contract.dart';

class AuthInterceptor extends Interceptor {
  final String? Function()? getToken;
  final Future<String?> Function(String, RequestOptions) refreshToken;
  final void Function()? onLogoutRequest;

  AuthInterceptor({
    required this.refreshToken,
    this.getToken,
    this.onLogoutRequest,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getToken?.call();
    if (token?.isNotEmpty == true) {
      options.headers[HttpConstants.authorization] = 'Bearer $token';
    }

    final headerToken = options.headers[HttpConstants.authorization];

    if (headerToken != null && options.path != ApiContract.refreshToken) {
      final token = headerToken!.toString().replaceAll('Bearer ', '');
      if (JwtUtils.isAboutToExpire(token)) {
        refreshToken(token, options).then((newToken) {
          options.headers[HttpConstants.authorization] = 'Bearer $newToken';
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
    if (options.path == ApiContract.logout) {
      onLogoutRequest?.call();
    }
  }
}
