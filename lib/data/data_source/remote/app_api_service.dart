import 'package:dio/dio.dart' as dio_p;

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/utils.dart';
import 'http_constants.dart';
import 'rest_client.dart';

part 'api_service_error.dart';

class AppApiService {
  final dio_p.Dio dio = dio_p.Dio();
  RestClient client;
  ApiServiceHandler handlerEror;
  //cached headers for GraphQl will get headers from lastest `updateHeaders`

  void create() {
    createDioHeader();

    client = RestClient(dio, baseUrl: Config.instance.appConfig.baseApiLayer);

    dio.interceptors.add(
      dio_p.InterceptorsWrapper(
        onRequest: (dio_p.RequestOptions options, handler) {
          LogUtils.i(CommonFunction.prettyJsonStr({
            'Time': DateTime.now().toString().split(' ').last,
            'baseUrl': options.baseUrl,
            'path': options.path,
            'headers': options.headers,
            'method': options.method,
            'data': options.data,
            'queryParameters': options.queryParameters,
          }));
          handler.next(options);
        },
        onResponse: (dio_p.Response response, handler) {
          LogUtils.i(CommonFunction.prettyJsonStr({
            'Time': DateTime.now().toString().split(' ').last,
            'statusCode': response.statusCode,
            'baseUrl': response.requestOptions.baseUrl,
            'path': response.requestOptions.path,
            'method': response.requestOptions.method,
            'data': response.requestOptions.data,
          }));
          handler.next(response);
        },
        onError: (dio_p.DioError error, handler) async {
          LogUtils.e(
            CommonFunction.prettyJsonStr({
              'Time': DateTime.now().toString().split(' ').last,
              'baseUrl': error.requestOptions.baseUrl,
              'path': error.requestOptions.path,
              'type': error.type,
              'message': error.message,
              'statusCode': error?.response?.statusCode,
            }),
            error,
          );

          handlerEror?.onError(ErrorData.fromDio(error));
          handler.reject(error);
        },
      ),
    );
  }

  void createDioHeader() {
    //final token = LocalDataManager.getToken();

    final defaultHeader = <String, String>{
      HttpConstants.contentType: 'application/json',
      HttpConstants.platform: 'dealer',
      HttpConstants.device: 'mobile',
      //...token?.isNotEmpty == true ? {HttpConstants.authorization: token} : {}
    };

    dio.options.headers.clear();

    dio.options.headers = defaultHeader;
  }

  Map<String, String> _getDefaultHeader() {
    //final token = LocalDataManager.getToken();

    final defaultHeader = <String, String>{
      HttpConstants.contentType: 'application/json',
      HttpConstants.platform: 'dealer',
      HttpConstants.device: 'mobile',
      //...token?.isNotEmpty == true ? {HttpConstants.authorization: token} : {}
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
