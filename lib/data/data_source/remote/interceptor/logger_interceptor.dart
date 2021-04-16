import 'package:dio/dio.dart';

import '../../../../common/utils.dart';

class LoggerInterceptor extends Interceptor {
  final Function(DioError) onRequestError;

  LoggerInterceptor({this.onRequestError});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    LogUtils.i(CommonFunction.prettyJsonStr({
      'from': 'onRequest',
      'Time': DateTime.now().toString(),
      'baseUrl': options.baseUrl,
      'path': options.path,
      'headers': options.headers,
      'method': options.method,
      'data': options.data,
      'queryParameters': options.queryParameters,
    }));
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    LogUtils.i(CommonFunction.prettyJsonStr({
      'from': 'onResponse',
      'Time': DateTime.now().toString(),
      'statusCode': response.statusCode,
      'baseUrl': response.requestOptions.baseUrl,
      'path': response.requestOptions.path,
      'method': response.requestOptions.method,
      'data': response.requestOptions.data,
    }));

    super.onResponse(response, handler);
  }

  @override
  void onError(DioError error, ErrorInterceptorHandler handler) {
    LogUtils.e(
      CommonFunction.prettyJsonStr({
        'from': 'onError',
        'Time': DateTime.now().toString(),
        'baseUrl': error.requestOptions.baseUrl,
        'header': error.requestOptions.headers,
        'path': error.requestOptions.path,
        'type': error.type,
        'message': error.message,
        'statusCode': error?.response?.statusCode,
        'error': error.error,
      }),
      error,
    );
    onRequestError?.call(error);
    super.onError(error, handler);
  }
}
