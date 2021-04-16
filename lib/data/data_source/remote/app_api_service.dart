import 'package:dio/dio.dart' as dio_p;

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/utils.dart';
import 'http_constants.dart';
import 'interceptor/auth_interceptor.dart';
import 'interceptor/logger_interceptor.dart';
import 'rest_client/rest_client.dart';

part 'api_service_error.dart';

class AppApiService {
  final dio_p.Dio dio = dio_p.Dio();
  late RestClient client;
  ApiServiceHandler? handlerEror;

  void create() {
    createDioHeader();

    client = RestClient(dio, baseUrl: Config.instance.appConfig?.baseApiLayer);

    dio.interceptors.add(AuthInterceptor(/*LocalDataManager.getToken*/ null));
    dio.interceptors.add(LoggerInterceptor(
      onRequestError: (error) => handlerEror?.onError(ErrorData.fromDio(error)),
    ));
  }

  void createDioHeader() {
    dio.options.headers.clear();

    dio.options.headers = _getDefaultHeader();
  }

  Map<String, String> _getDefaultHeader() {
    final defaultHeader = <String, String>{
      HttpConstants.contentType: 'application/json',
      HttpConstants.platform: 'dealer',
      HttpConstants.device: 'mobile',
    };
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
  }
}

mixin ApiServiceHandler {
  void onError(ErrorData onError);
}
