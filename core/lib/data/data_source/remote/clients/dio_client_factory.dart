import 'package:dio/dio.dart' as dio_p;

import '../../../../common/services/header/request_header_service.dart';
import '../../local/local_data_manager.dart';
import '../interceptor/domain_interceptor.dart';
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

        /// In Web platform we disable timeout to avoid the warning from DIO
        /// Ref: https://github.com/cfug/dio/issues/2255
        receiveTimeout: const Duration(seconds: 300),

        /// In Web platform we disable timeout to avoid the warning from DIO
        /// Ref: https://github.com/cfug/dio/issues/2255
        sendTimeout: const Duration(seconds: 300),
        baseUrl: baseUrl,
      ),
    );

    dio.options.headers.clear();

    dio.interceptors.add(DomainInterceptor(localDataManager: localDataManager));

    dio.interceptors.add(
      HeaderInterceptor(requestHeaderService: requestHeaderService),
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
    dio.interceptors.add(const LoggerInterceptor());

    // Add retry interceptor for handling retries
    dio.interceptors.add(RetryInterceptor(dio: dio));

    // Enable cookies
    dio.options.extra['withCredentials'] = true;
    return dio;
  }
}
