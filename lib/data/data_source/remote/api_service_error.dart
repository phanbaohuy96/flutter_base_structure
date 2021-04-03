part of 'app_api_service.dart';

enum ErrorType {
  noInternet,
  httpException,
  //occurred when refresh token with invalid token or user not found
  invalidToken,
  timeout,
  unAuthorized,
  unKnown,
  unKnownGrapQL,
  grapQLInvalidToken,
  serverUnExpected,
}

class ErrorData {
  ErrorType type;
  String message;
  int statusCode;

  ErrorData({this.type, this.statusCode, this.message});

  ErrorData.fromDio(dio_p.DioError error) {
    type = ErrorType.unKnown;
    message = error.message;

    switch (error.type) {
      case dio_p.DioErrorType.connectTimeout:
      case dio_p.DioErrorType.sendTimeout:
      case dio_p.DioErrorType.receiveTimeout:
        type = ErrorType.timeout;
        break;
      case dio_p.DioErrorType.response:
        statusCode = error.response.statusCode;
        final errorCode = error.response?.data is Map<dynamic, dynamic>
            ? error.response?.data['code']?.toString()
            : null;
        if (errorCode == ServerErrorCode.invalidToken) {
          type = ErrorType.invalidToken;
        } else if (statusCode == 401) {
          type = ErrorType.unAuthorized;
        } else {
          type = ErrorType.httpException;
          if (error.response.data is Map<dynamic, dynamic>) {
            message = getErrorMessage(error.response.data);
          }
        }
        break;
      case dio_p.DioErrorType.cancel:
        break;
      case dio_p.DioErrorType.other:
        if (error.message.contains('Unexpected character')) {
          type = ErrorType.serverUnExpected;
        } else {
          type = ErrorType.noInternet;
        }
        break;
    }
  }

  String getErrorMessage(Map<String, dynamic> dataRes) {
    LogUtils.e('getErrorMessage $dataRes');
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
