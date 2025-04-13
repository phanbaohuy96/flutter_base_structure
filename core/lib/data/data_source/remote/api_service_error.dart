// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_api_service.dart';

enum ErrorType {
  noInternet,
  timeout,

  /// occurred when refresh token with invalid token or user not found `or`
  /// status code is 401
  unauthorized,
  unknown,
  badRequest,
  serverUnExpected,
  internalServerError,
  restricted,
  dataParsing,
}

enum ErrorOrigin {
  dio,
  grapghql,
  firebase,
}

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

  factory ErrorData.fromException({required Exception exception}) {
    if (exception is dio_p.DioException) {
      return ErrorData.fromDio(exception);
    }
    return ErrorData(
      type: ErrorType.unknown,
      message: exception.toString(),
    );
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
    errorCode =
        apiResponse.errorCode ?? apiResponse.error ?? apiResponse.errors;

    switch (error.type) {
      case dio_p.DioExceptionType.receiveTimeout:
      case dio_p.DioExceptionType.sendTimeout:
      case dio_p.DioExceptionType.connectionTimeout:
      case dio_p.DioExceptionType.connectionError:
        type = ErrorType.timeout;
        break;
      case dio_p.DioExceptionType.badResponse:
        message = apiResponse.msg ?? apiResponse.message;
        if (errorCode == ServerErrorCode.invalidToken ||
            errorCode == ServerErrorCode.userNotFound ||
            statusCode == 401) {
          type = ErrorType.unauthorized;
        } else {
          type = ErrorType.badRequest;
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
