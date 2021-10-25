import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart' as dio_p;
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pedantic/pedantic.dart';

import '../../../common/client_info.dart';
import '../../../common/components/graphql/graphql.dart';
import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/utils.dart';
import '../../../di/di.dart';
import '../../models/graphql_error.dart';
import '../local/local_data_manager.dart';
import 'interceptor/auth_interceptor.dart';
import 'interceptor/logger_interceptor.dart';
import 'rest_api_repository/api_contract.dart';
import 'rest_api_repository/rest_api_repository.dart';

part 'api_service_error.dart';

class AppApiService {
  late dio_p.Dio dio;
  late RestApiRepository client;
  late GraphQLClient graphQLClient;
  ApiServiceDelegate? apiServiceDelegate;

  /// Cached headers for GraphQl will get headers from lastest `updateHeaders`
  late Map<String, String> _cacheHeaders;

  LocalDataManager get localDataManager => injector.get();

  void create() {
    _cacheHeaders = _getDefaultHeader();

    _createGraphQLClient();

    _setupDioClient();

    _createRestClient();
  }

  Map<String, String> _getDefaultHeader() {
    final defaultHeader = <String, String>{
      HttpConstants.contentType: 'application/json',
      HttpConstants.device: 'mobile',
      HttpConstants.model: ClientInfo.model,
      HttpConstants.osversion: ClientInfo.osversion,
      HttpConstants.appVersion: ClientInfo.appVersionName,
      HttpConstants.appVersionFull: ClientInfo.appVersion,
    };

    if (!kIsWeb) {
      defaultHeader[HttpConstants.osplatform] = Platform.operatingSystem;
    }
    return defaultHeader;
  }

  void updateHeaders({Map<String, String> headers = const {}}) {
    final defaultHeader = _getDefaultHeader();

    final _headers = <String, String>{
      ...defaultHeader,
      ...headers,
    };

    dio.options.headers.clear();

    dio.options.headers = _headers;

    _cacheHeaders = _headers;
  }

  void _createGraphQLClient() {
    graphQLClient = createGraphQLClient(
      baseUri: Config.instance.appConfig.baseGraphQLUrl,
      // TODO : implement get token if needed
      getToken: () async {
        // return localDataManager.getToken();
        return '';
      },
      onError: (err, exception) {
        final error = GraphQLException.fromJson({
          'message': err?.message,
          'locations': err?.locations,
          'path': err?.path,
          'extensions': err?.extensions,
        });

        if (!error.isAccessDenied) {
          apiServiceDelegate?.onError(ErrorData.fromGraplQL(
            error: error,
            exception: exception,
          ));
        } else {
          apiServiceDelegate?.onError(ErrorData.fromGraplQL(
            error: null,
            exception: RefreshTokenException(),
          ));
        }
      },

      /// Remove old `authorization` bcs of GraphQl will get new from `getToken`
      headers: _getDefaultHeader()..remove(HttpConstants.authorization),
      customHeaderFnc: () {
        return {..._cacheHeaders}..remove(HttpConstants.authorization);
      },
      onRefreshToken: refreshToken,
    );
  }

  void _setupDioClient() {
    dio = dio_p.Dio(dio_p.BaseOptions(
      followRedirects: false,
      receiveTimeout: 30000, // 30s
      sendTimeout: 30000, // 30s
    ));

    dio.options.headers.clear();

    dio.options.headers = _getDefaultHeader();

    /// CERTIFICATE_VERIFY_FAILED
    final clientAdapter = dio.httpClientAdapter;
    if (clientAdapter is DefaultHttpClientAdapter) {
      clientAdapter.onHttpClientCreate = (client) {
        client.badCertificateCallback = (cert, host, port) {
          LogUtils.d({
            'From': 'AppApiService -> badCertificateCallback',
            'Time': DateTime.now().toString(),
            'host': host,
            'port': port,
            'cert': cert,
          });
          return true;
        };
        return client;
      };
    }

    /// Dio InterceptorsWrapper
    dio.interceptors.add(
      AuthInterceptor(
        // TODO : implement get token if needed
        getToken: null /*localDataManager.getToken*/,
        refreshToken: (token, options) async {
          // TODO : implement refresh token if needed
          return refreshToken(
            token,
            saveToken: options.path != ApiContract.logout,
          );
        },
        onLogoutRequest: () {
          unawaited(localDataManager.clearData());
        },
      ),
    );
    dio.interceptors.add(
      LoggerInterceptor(
        onRequestError: (error) => apiServiceDelegate?.onError(
          ErrorData.fromDio(error),
        ),
        // TODO : implement ignore large logs if needed
        ignoreReponseDataLog: (response) {
          // return response.requestOptions.path == ApiContract.administrative;
          return false;
        },
      ),
    );
  }

  void _createRestClient() {
    client = RestApiRepository(
      dio,
      baseUrl: Config.instance.appConfig.baseApiLayer,
    );
  }

  Future<String?> refreshToken(String token, {bool saveToken = true}) async {
    // TODO : implement refresh token if needed
    // final res = await client.refreshToken({
    //   'token': token,
    //   'refreshToken': LocalDataManager.getUser().refreshToken,
    // });
    // if (res != null && saveToken) {
    //   await LocalDataManager.saveNewToken(res?.token);
    // }
    // return res?.token?.token;
    return token;
  }
}

mixin ApiServiceDelegate {
  void onError(ErrorData onError);
}
