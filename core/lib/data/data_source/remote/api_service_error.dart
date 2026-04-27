part of 'app_api_service.dart';

enum ErrorType {
  noInternet,
  timeout,

  /// occurred when refresh token with invalid token or user not found `or`
  /// status code is 401
  unauthorized,
  unknown,
  badResponse,
  serverUnExpected,
  internalServerError,
  restricted,
  dataParsing,
}

enum ErrorOrigin { dio, graphql, firebase }

class ErrorData {
  ErrorType? type;
  String? message;
  int? statusCode;
  String? errorCode;
  ErrorOrigin? origin;
  dynamic responseData;

  ErrorData({
    this.type,
    this.message,
    this.statusCode,
    this.errorCode,
    this.origin,
    this.responseData,
  });

  static ErrorData? fromObject({required dynamic error}) {
    if (error is Exception) {
      return ErrorData.fromException(exception: error);
    } else if (error is Error) {
      return ErrorData.fromError(error: error);
    }
    return null;
  }

  factory ErrorData.fromException({required Exception exception}) {
    if (exception is dio_p.DioException) {
      return ErrorData.fromDio(exception);
    }
    return ErrorData(type: ErrorType.unknown, message: exception.toString());
  }

  ErrorData.fromDio(dio_p.DioException error) {
    final apiResponse = ApiResponse.fromJson(
      asOrNull(error.response?.data) ?? {},
      (json) => json,
    );

    origin = ErrorOrigin.dio;

    type = ErrorType.unknown;
    responseData = error.response?.data;
    message = error.message;
    statusCode = error.response?.statusCode;
    errorCode = apiResponse.messageKey;

    switch (error.type) {
      case dio_p.DioExceptionType.sendTimeout:
      case dio_p.DioExceptionType.connectionTimeout:
        type = ErrorType.timeout;
        break;
      case dio_p.DioExceptionType.connectionError:
        type = ErrorType.noInternet;
        break;
      case dio_p.DioExceptionType.receiveTimeout:
        type = ErrorType.internalServerError;
        break;
      case dio_p.DioExceptionType.badResponse:
        message = apiResponse.message;
        if (errorCode == ServerErrorCode.invalidToken ||
            errorCode == ServerErrorCode.userNotFound ||
            statusCode == 401) {
          type = ErrorType.unauthorized;
        } else {
          type = ErrorType.badResponse;
        }
        break;
      case dio_p.DioExceptionType.cancel:
      case dio_p.DioExceptionType.badCertificate:
        break;
      case dio_p.DioExceptionType.unknown:
        if (error.message?.contains('Unexpected character') == true) {
          type = ErrorType.serverUnExpected;
        } else {
          type = ErrorType.noInternet;
        }
        break;
    }
  }

  ErrorData.fromError({required Error error}) {
    type = error is TypeError ? ErrorType.dataParsing : ErrorType.unknown;
    message = error.toString();
  }

  ErrorData copyWith({
    ErrorType? type,
    String? message,
    int? statusCode,
    String? errorCode,
  }) {
    return ErrorData(
      type: type ?? this.type,
      message: message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  @override
  String toString() {
    return '''ErrorData(
    type: $type, 
    message: $message, 
    statusCode: $statusCode, 
    errorCode: $errorCode, 
    origin: $origin
  )''';
  }
}
