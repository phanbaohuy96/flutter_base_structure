part of 'state_base.dart';

extension StateBaseErrorHandlerExt on CoreStateBase {
  bool get isDevEnv => Config.instance.appConfig.isDevBuild;

  /// Handles errors with proper logging and user feedback
  void _onError(ErrorData error) {
    _logError(error);

    if (!mounted) {
      logUtils.w('[$runtimeType] error when state disposed!');
      return;
    }

    if (_isErrorAlreadyShowing(error)) {
      return;
    }

    final message = getErrorMsg(error);
    hideLoading();
    _handleErrorByType(error, message);
  }

  /// Logs error details for debugging
  void _logError(ErrorData error) {
    logUtils.w(
      '''[$runtimeType] error ${error.type} [${error.message?.runtimeType}] message ${error.message}''',
    );
  }

  /// Checks if the same error type is already being displayed
  bool _isErrorAlreadyShowing(ErrorData error) {
    return errorTypeShowing == error.type;
  }

  /// Routes error handling based on error type
  void _handleErrorByType(ErrorData error, String message) {
    switch (error.type) {
      case ErrorType.unauthorized:
        _handleUnauthorizedError(message, error);
        break;
      case ErrorType.badResponse:
        _handleBadResponseError(message, error);
        break;
      case ErrorType.timeout:
      case ErrorType.noInternet:
        _handleConnectivityError(message, error);
        break;
      case ErrorType.serverUnExpected:
      case ErrorType.internalServerError:
      case ErrorType.restricted:
      case ErrorType.dataParsing:
        showErrorDialog(message, error);
        break;
      default:
        _handleUnknownError(message, error);
        break;
    }
  }

  /// Handles unauthorized errors
  void _handleUnauthorizedError(String message, ErrorData error) {
    showLoginRequired(
      message: message,
      error: error,
    );
  }

  /// Handles bad response errors with different logic for 5xx vs 4xx codes
  void _handleBadResponseError(String message, ErrorData error) {
    if (_isServerError(error.statusCode)) {
      showErrorDialog(message, error);
    } else {
      onClientError(message, error);
    }
  }

  /// Checks if status code indicates a server error (5xx)
  bool _isServerError(int? statusCode) {
    return statusCode != null && statusCode >= 500 && statusCode < 600;
  }

  /// Handles connectivity-related errors
  void _handleConnectivityError(String message, ErrorData error) {
    _connectivityErrorOrNot(
      orNot: () => showErrorDialog(message, error),
    );
  }

  /// Handles unknown error types
  void _handleUnknownError(String message, ErrorData error) {
    if (Config.instance.appConfig.isDevBuild) {
      showErrorDialog(message, error);
    } else {
      // Log unknown error for investigation
      logUtils.e('[$runtimeType] Unknown error type: ${error.type}');
    }
  }

  /// Generates user-friendly error messages based on error type and environment
  String getErrorMsg(ErrorData error) {
    return switch (error.type) {
      ErrorType.unauthorized => _getUnauthorizedMessage(error),
      ErrorType.badResponse => _getBadResponseMessage(error),
      ErrorType.timeout => _getTimeoutMessage(error),
      ErrorType.noInternet => coreL10n.noInternet,
      ErrorType.internalServerError ||
      ErrorType.unknown =>
        _getInternalErrorMessage(error),
      ErrorType.serverUnExpected => _getServerUnexpectedMessage(error),
      ErrorType.restricted => _getRestrictedMessage(error),
      ErrorType.dataParsing => _getDataParsingMessage(error),
      _ => _getDefaultMessage(error),
    };
  }

  String _getUnauthorizedMessage(ErrorData error) {
    return error.message ?? coreL10n.sessionExpired;
  }

  String _getBadResponseMessage(ErrorData error) {
    final isBadRequest = _isClientError(error.statusCode);
    return (isBadRequest || isDevEnv)
        ? _buildErrorMessage(error.message, error.errorCode)
        : coreL10n.technicalIssues;
  }

  String _getTimeoutMessage(ErrorData error) {
    return error.message ?? coreL10n.connectionTimeout;
  }

  String _getInternalErrorMessage(ErrorData error) {
    return isDevEnv
        ? _buildErrorMessage(error.message, error.errorCode)
        : coreL10n.technicalIssues;
  }

  String _getServerUnexpectedMessage(ErrorData error) {
    return error.message ?? coreL10n.serverMaintenance;
  }

  String _getRestrictedMessage(ErrorData error) {
    return error.message ?? coreL10n.requestRestricted;
  }

  String _getDataParsingMessage(ErrorData error) {
    return [
      coreL10n.dataParsingError,
      if (isDevEnv && error.message.isNotNullOrEmpty) error.message,
    ].where((part) => part != null).join('\n');
  }

  String _getDefaultMessage(ErrorData error) {
    return isDevEnv
        ? (error.message ?? coreL10n.technicalIssues)
        : coreL10n.technicalIssues;
  }

  /// Checks if status code indicates a client error (4xx)
  bool _isClientError(int? statusCode) {
    return statusCode != null && statusCode >= 400 && statusCode < 500;
  }

  /// Builds error message with optional error code for development
  String _buildErrorMessage(String? message, String? errorCode) {
    return [
      message ?? coreL10n.technicalIssues,
      if (errorCode.isNotNullOrEmpty && isDevEnv) errorCode!,
    ].join('\n');
  }

  /// Checks connectivity and shows appropriate error dialog
  Future<void> _connectivityErrorOrNot({
    void Function()? orNot,
  }) async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      if (connectivityResults.contains(ConnectivityResult.none)) {
        showNoInternetDialog();
      } else {
        orNot?.call();
      }
    } catch (e) {
      logUtils.e('[$runtimeType] Failed to check connectivity: $e');
      // Fallback to showing the original error
      orNot?.call();
    }
  }
}
