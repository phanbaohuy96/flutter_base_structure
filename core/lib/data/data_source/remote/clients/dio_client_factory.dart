import 'package:dio/dio.dart' as dio_p;

import '../../../../common/services/header/request_header_service.dart';
import '../../local/local_data_manager.dart';
import '../interceptor/header_interceptor.dart';
import '../interceptor/logger_interceptor.dart';
import '../interceptor/retry_interceptor.dart';

class DioClientFactory {
  static dio_p.Dio build({
    required CoreLocalDataManager localDataManager,
    required RequestHeaderService requestHeaderService,
    required String baseUrl,
  }) {
    final dio = dio_p.Dio(
      dio_p.BaseOptions(
        followRedirects: false,
        receiveTimeout: const Duration(seconds: 30000),
        sendTimeout: const Duration(seconds: 30000),
        baseUrl: baseUrl,
      ),
    );

    dio.options.headers.clear();

    dio.interceptors.add(
      HeaderInterceptor(
        requestHeaderService: requestHeaderService,
      ),
    );

    /// Dio InterceptorsWrapper
    // dio.interceptors.add(
    //   AutoRefreshTokenInterceptor(
    //     getToken: () {
    //       final token = authService.token;
    //       return token.isNotNullOrEmpty ? '$token' : null;
    //     },
    //     refreshToken: (token, options) async {
    //       // return authService.refreshToken();
    //       return Future.value(null);
    //     },
    //     onLogoutRequest: () {
    //       unawaited(localDataManager.clearData());
    //     },
    //     // refreshTokenPath: ApiContract.refreshToken,
    //     // logoutPath: ApiContract.logout,
    //   ),
    // );
    dio.interceptors.add(
      LoggerInterceptor(
        ignoreReponseDataLog: (response) {
          // return response.requestOptions.path == ApiContract.administrative;
          return false;
        },
      ),
    );

    // Add retry interceptor for handling retries
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
      ),
    );

    return dio;
  }
}
