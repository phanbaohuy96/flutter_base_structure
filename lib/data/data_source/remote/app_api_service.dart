import 'package:dio/dio.dart';

import '../../../envs.dart';
import '../../../utils/log_utils.dart';
import 'http_constants.dart';
import 'rest_client.dart';

class AppApiService {
  final Dio dio = Dio();
  RestClient client;
  ApiServiceHandler handlerEror;

  void create() {
    client = RestClient(dio, baseUrl: appConfig.baseApiLayer);

    addDioHeader();

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options) {
          LogUtils.i(
              '''[${DateTime.now().toString().split(' ').last}]-> DioSTART\tonRequest \t${options.method} [${options.path}] ${options.contentType}''');
          return options;
        },
        onResponse: (Response response) {
          LogUtils.i(
              '''[${DateTime.now().toString().split(' ').last}]-> DioEND\tonResponse \t${response.statusCode} [${response.request.path}] ${response.request.method} ${response.request.responseType}''');
          return response;
        },
        onError: (DioError error) async {
          LogUtils.e(
              '''[${DateTime.now().toString().split(' ').last}]-> DioEND\tonError \turl:[${error.request.baseUrl}] type:${error.type} message: ${error.message}''');
          handlError(error);
        },
      ),
    );
  }

  void addDioHeader({Map<String, String> headers}) {
    dio.options.headers.clear();

    //default header
    dio.options.headers[HttpConstants.contentType] = 'application/json';

    //config authentication
    // final User user = _preferencesHelper.getUser();
    // if (user?.accessToken != null) {
    //   dio.options.headers[HttpConstants.authorization] =
    //       'Bearer ${user.accessToken}';
    // }

    headers?.forEach((k, v) {
      dio.options.headers[k] = v;
    });
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
              '''[AppApiService] _handleError ${error.type} status code: ${error.response.statusCode}''');
          result.statusCode = error.response.statusCode;

          if (result.statusCode == 401) {
            result.type = ErrorType.unAuthorized;
          } else if (result.statusCode >= 500 && result.statusCode < 600) {
            result.type = ErrorType.httpException;
          } else {
            result
              ..type = ErrorType.httpException
              ..message = getErrorMessage(error.response.data);
          }
          break;
        }
      case DioErrorType.CANCEL:
        break;
      case DioErrorType.DEFAULT:
        LogUtils.e(
            '''[AppApiService] _handleError ${error.type} status code: ${error.response.statusCode} -> Server die or No Internet connection''');

        if (error.message.contains('Unexpected character')) {
          result.type = ErrorType.serverUnExpected;
        } else {
          result.type = ErrorType.noInternet;
        }
        break;
    }

    return handlerEror.onError(result); //continue
  }

  String getErrorMessage(Map<String, dynamic> dataRes) {
    try {
      if (dataRes.containsKey('message') && dataRes['message'] != null) {
        return dataRes['message'].toString();
      }
      if (dataRes.containsKey('error') && dataRes['error'] != null) {
        return dataRes['error'].toString();
      }
      if (dataRes.containsKey('errors') && dataRes['errors'] != null) {
        return dataRes['errors'].toString();
      }
    } catch (e) {/* ignore */}
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
