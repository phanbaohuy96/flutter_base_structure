part of 'base.dart';

abstract class StateBase<T extends StatefulWidget> extends State<T>
    implements ApiServiceHandler {
  //prevent show the same error dialog when call multiple api at the same time
  ErrorType errorTypeShowing;
  bool isLoadingShowing = false;

  AppBlocBase get bloc;
  bool get willHandleError => false;

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    LogUtils.i('[${T.toString()}] initState');
    if (willHandleError) {
      bloc?.listenApiError(this);
    }
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    bloc?.updateHeader({
      HttpConstants.language: S.of(context).localeName,
    });
    super.didChangeDependencies();
  }

  @override
  @mustCallSuper
  void dispose() {
    LogUtils.i('[${T.toString()}] dispose');
    super.dispose();
  }

  @override
  void onError(ErrorData error) {
    LogUtils.w(
        '''[${T.toString()}] error ${error.type} message ${error.message}''');
    if (!mounted) {
      LogUtils.w('[${T.toString()}] error when state disposed!');
      return;
    }
    hideLoading();
    switch (error.type) {
      case ErrorType.unAuthorized:
      case ErrorType.grapQLInvalidToken:
        if (errorTypeShowing == error.type) {
          break;
        }
        errorTypeShowing = error.type;
        showLoginRequired();
        break;
      case ErrorType.httpException:
        if (errorTypeShowing == ErrorType.httpException) {
          break;
        }
        errorTypeShowing = ErrorType.httpException;
        if (error.statusCode != null &&
            error.statusCode >= 500 &&
            error.statusCode < 600) {
          showErrorDialog(tr('common.error.technicalIssues'));
        } else {
          showErrorDialog(error.message);
        }
        break;
      case ErrorType.timeout:
        if (errorTypeShowing == ErrorType.timeout) {
          break;
        }
        errorTypeShowing = ErrorType.timeout;
        showErrorDialog(tr('common.error.connectionTimeout'));
        break;
      case ErrorType.noInternet:
        if (errorTypeShowing == ErrorType.noInternet) {
          break;
        }
        errorTypeShowing = ErrorType.noInternet;
        Connectivity().checkConnectivity().then((value) {
          if (value == ConnectivityResult.none) {
            showNoInternetDialog();
          } else {
            showErrorDialog(tr('common.error.technicalIssues'));
          }
        });
        break;
      case ErrorType.unKnown:
        if (errorTypeShowing == ErrorType.unKnown) {
          break;
        }
        errorTypeShowing = ErrorType.unKnown;
        showErrorDialog(tr('common.error.unknowError'));
        break;
      case ErrorType.unKnownGrapQL:
        if (errorTypeShowing == ErrorType.unKnownGrapQL) {
          break;
        }
        errorTypeShowing = ErrorType.unKnownGrapQL;
        onLogicError(error.message);
        break;
      case ErrorType.invalidToken:
        if (errorTypeShowing == ErrorType.invalidToken) {
          break;
        }
        errorTypeShowing = ErrorType.invalidToken;
        onInvalidToken();
        break;
      case ErrorType.serverUnExpected:
        if (errorTypeShowing == ErrorType.serverUnExpected) {
          break;
        }
        errorTypeShowing = ErrorType.serverUnExpected;
        showErrorDialog(tr('common.error.serverMaintenance'));
        break;
    }
  }

  void showLoading() {
    if (!isLoadingShowing) {
      isLoadingShowing = true;
      EasyLoading.show(status: tr('common.loading'));
    }
  }

  void hideLoading() {
    if (isLoadingShowing) {
      isLoadingShowing = false;
      EasyLoading.dismiss();
    }
  }

  void showGuestRequestingNotice() {
    showNoticeDialog(
      context: context,
      message: tr('common.guestRequesting.notice'),
      titleBtn: tr('common.ok'),
    );
  }

  void showErrorDialog(String message, {Function() onClose}) {
    showNoticeErrorDialog(
      context: context,
      message: message?.isNotEmpty != true
          ? tr('common.error.technicalIssues')
          : message,
      onClose: () {
        onCloseErrorDialog();
        onClose?.call();
      },
    );
  }

  @mustCallSuper
  void onCloseErrorDialog() {
    errorTypeShowing = null;
  }

  void showLoginRequired({Function onClose}) {
    LogUtils.i('[${T.toString()}] showLoginRequired!');
    showNoticeErrorDialog(
      barrierDismissible: false,
      context: context,
      message: tr('common.error.sessionExpired'),
      onClose: onClose ?? backToAuth,
    );
  }

  void showNoInternetDialog() {
    showNoticeDialog(
      context: context,
      message: tr('common.error.noInternet'),
      onClose: onCloseErrorDialog,
    );
  }

  void onInvalidToken() {
    showLoginRequired();
  }

  void onLogicError(String message) {
    showErrorDialog(message);
  }

  Widget baseLoading() {
    return const Loading();
  }
}
