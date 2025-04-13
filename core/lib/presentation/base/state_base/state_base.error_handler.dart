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

    hideLoading();
    switch (error.type) {
      case ErrorType.unauthorized:
        showLoginRequired(message: error.message);
        break;
      case ErrorType.badRequest:
        _connectivityErrorOrNot(
          orNot: () {
            final errorMessage = [
              error.message ?? coreL10n.technicalIssues,
              if (Config.instance.appConfig.developmentMode)
                error.errorCode ?? '',
            ].join('\n');

            if (error.statusCode != null &&
                error.statusCode! >= 500 &&
                error.statusCode! < 600) {
              showErrorDialog(errorMessage);
            } else {
              onLogicError(errorMessage, error);
            }
          },
        );
        break;
      case ErrorType.timeout:
        showErrorDialog(coreL10n.connectionTimeout);
        break;
      case ErrorType.noInternet:
        _connectivityErrorOrNot(
          orNot: () {
            showErrorDialog(coreL10n.technicalIssues);
          },
        );
        break;
      case ErrorType.unknown:
        final errorMessage = [
          error.message ?? coreL10n.unknownError,
          if (Config.instance.appConfig.isDevBuild) error.errorCode ?? '',
        ].join('\n');
        onLogicError(errorMessage, error);
        break;
      case ErrorType.serverUnExpected:
        showErrorDialog(coreL10n.serverMaintenance);
        break;
      case ErrorType.internalServerError:
        showErrorDialog(coreL10n.technicalIssues);
        break;
      case ErrorType.restricted:
        showErrorDialog(coreL10n.requestRestricted);
        break;
      case ErrorType.dataParsing:
        showErrorDialog(
          [
            coreL10n.dataParsingError,
            if (kDebugMode) error.message,
          ].join('\n'),
        );
        break;
      default:
        break;
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
