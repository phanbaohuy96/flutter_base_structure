part of 'state_base.dart';

extension StateBaseErrorHandlerExt on CoreStateBase {
  void _onError(ErrorData error) {
    logUtils.w(
      '''[$runtimeType] error ${error.type} [${error.message?.runtimeType}] message ${error.message}''',
    );
    if (!mounted) {
      logUtils.w('[$runtimeType] error when state disposed!');
      return;
    }

    if (errorTypeShowing == error.type) {
      return;
    }
    errorTypeShowing = error.type;

    final message = getErrorMsg(error);

    hideLoading();
    switch (error.type) {
      case ErrorType.unauthorized:
        showLoginRequired(message: message);
        break;
      case ErrorType.badResponse:
        if (error.statusCode != null &&
            error.statusCode! >= 500 &&
            error.statusCode! < 600) {
          showErrorDialog(message);
        } else {
          onLogicError(message, error);
        }
        break;
      case ErrorType.timeout:
      case ErrorType.noInternet:
        _connectivityErrorOrNot(
          orNot: () {
            showErrorDialog(message);
          },
        );
        break;
      case ErrorType.serverUnExpected:
      case ErrorType.internalServerError:
      case ErrorType.restricted:
      case ErrorType.dataParsing:
        showErrorDialog(message);
        break;
      default:
        break;
    }
  }

  String getErrorMsg(ErrorData error) {
    final isDevEnv = Config.instance.appConfig.isDevBuild;

    String buildErrorMessage(String? message, String? errorCode) {
      return [
        message ?? coreL10n.technicalIssues,
        if (errorCode.isNotNullOrEmpty && isDevEnv) errorCode!,
      ].join('\n');
    }

    switch (error.type) {
      case ErrorType.unauthorized:
        return error.message ?? coreL10n.sessionExpired;
      case ErrorType.badResponse:
        final isBadRequest = error.statusCode != null &&
            error.statusCode! >= 400 &&
            error.statusCode! < 500;
        return isBadRequest || isDevEnv
            ? buildErrorMessage(error.message, error.errorCode)
            : coreL10n.technicalIssues;
      case ErrorType.timeout:
        return error.message ?? coreL10n.connectionTimeout;
      case ErrorType.noInternet:
        return coreL10n.technicalIssues;
      case ErrorType.internalServerError:
      case ErrorType.unknown:
        return isDevEnv
            ? buildErrorMessage(error.message, error.errorCode)
            : coreL10n.technicalIssues;
      case ErrorType.serverUnExpected:
        return error.message ?? coreL10n.serverMaintenance;
      case ErrorType.restricted:
        return error.message ?? coreL10n.requestRestricted;
      case ErrorType.dataParsing:
        return [
          coreL10n.dataParsingError,
          if (isDevEnv) error.message,
        ].join('\n');
      default:
        return isDevEnv
            ? (error.message ?? coreL10n.technicalIssues)
            : coreL10n.technicalIssues;
    }
  }

  void _connectivityErrorOrNot({void Function()? orNot}) {
    Connectivity().checkConnectivity().then((value) {
      if (value.contains(ConnectivityResult.none)) {
        showNoInternetDialog();
      } else {
        orNot?.call();
      }
    });
  }
}
