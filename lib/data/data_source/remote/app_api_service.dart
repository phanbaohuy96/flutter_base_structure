import 'package:dio/dio.dart';

import '../../../utils/log_utils.dart';
import 'rest_client.dart';

class AppApiService {
  final Dio dio = Dio();
  RestClient client;
  ApiServiceHandler handlerEror;

  void create() {
    client = RestClient(dio, baseUrl: '');

    dio.options.headers['Content-Type'] = 'application/json';

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options) {
          LogUtils.i(
              '''[${DateTime.now().toString().split(' ').last}]-> DioSTART\tonRequest \t${options.method} [${options.path}] ${options.contentType}''');
          return options; //continue
        },
        onResponse: (Response response) {
          LogUtils.i(
              '''[${DateTime.now().toString().split(' ').last}]-> DioEND\tonResponse \t${response.statusCode} [${response.request.path}] ${response.request.method}  ${response.request.responseType}''');
          return response; // continue
        },
        onError: (DioError error) async {
          LogUtils.e(
              '''[${DateTime.now().toString().split(' ').last}]-> DioEND\tonError \turl:[${error.request.baseUrl}] type:${error.type} message: ${error.message}''');
          handlError(error);
        },
      ),
    );
  }

  dynamic handlError(DioError error) {
    if (handlerEror == null) {
      return null;
    }

    final result = ErrorData(
      type: ErrorType.unKnown,
      message: error.message,
    );

    switch (error.type) {
      case DioErrorType.RECEIVE_TIMEOUT:
      case DioErrorType.SEND_TIMEOUT:
      case DioErrorType.CONNECT_TIMEOUT:
        result.type = ErrorType.timeout;
        break;
      case DioErrorType.RESPONSE:
        {
          LogUtils.e(
              '''[AppApiService] _handleError DioErrorType.RESPONSE status code: ${error.response.statusCode}''');
          result.statusCode = error.response.statusCode;

          if (result.statusCode == 401) {
            result.type = ErrorType.unAuthorized;
          }
          if (result.statusCode == 403) {
          } else if (result.statusCode >= 500 && result.statusCode < 600) {
            result.type = ErrorType.httpException;
          } else {
            result.type = ErrorType.httpException;
            // result.message = getErrorMessage(error.response.data);
          }
          break;
        }
      case DioErrorType.CANCEL:
        break;
      case DioErrorType.DEFAULT:
        LogUtils.e(
            '''[AppApiService] _handleError DioErrorType.DEFAULT status code: error.response is null -> Server die or No Internet connection''');
        result.type = ErrorType.noInternet;

        if (error.message.contains('Unexpected character')) {
          result.type = ErrorType.serverUnExpected;
        }
        break;
    }

    return handlerEror.onError(result); //continue
  }

  String getErrorMessage(Map<String, dynamic> dataRes) {
    if (dataRes.containsKey('message') && dataRes['message'] != null) {
      return dataRes['message']?.toString();
    }
    if (dataRes.containsKey('error') && dataRes['error'] != null) {
      return dataRes['error']?.toString();
    }
    return dataRes.toString();
  }
}

// ignore: constant_identifier_names
enum ErrorType {
  noInternet,
  httpException,
  timeout,
  unAuthorized,
  unKnown,
  serverUnExpected,
}

class ErrorData {
  ErrorType type;
  String message;
  int statusCode;

  ErrorData({this.type, this.statusCode, this.message});
}

mixin ApiServiceHandler {
  void onError(ErrorData onError);
}
