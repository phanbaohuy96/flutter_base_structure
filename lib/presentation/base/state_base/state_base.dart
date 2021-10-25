part of '../base.dart';

abstract class StateBase<T extends StatefulWidget> extends State<T>
    implements ApiServiceDelegate {
  //prevent show the same error dialog when call multiple api at the same time
  ErrorType? errorTypeShowing;
  var _isLoadingShowing = false;

  bool get isLoading => _isLoadingShowing;

  AppBlocBase? get bloc;
  bool get willHandleError => true;

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    LogUtils.d('[${T.toString()}] initState');
    if (willHandleError) {
      bloc?.registerDelegate(this);
    }
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    refreshHeader();
    super.didChangeDependencies();
  }

  @override
  @mustCallSuper
  void dispose() {
    LogUtils.d('[${T.toString()}] dispose');
    super.dispose();
  }

  void showLoading() {
    if (!_isLoadingShowing) {
      _isLoadingShowing = true;
      EasyLoading.show(
        status: tr('common.loading'),
        indicator: const Loading(),
      );
    }
  }

  void hideLoading() {
    if (_isLoadingShowing) {
      _isLoadingShowing = false;
      EasyLoading.dismiss();
    }
  }

  @override
  void onError(ErrorData error) {
    _onError(error);
  }

  void showGuestRequestingNotice() {
    showNoticeDialog(
      context: context,
      message: tr('common.guestRequesting.notice'),
      titleBtn: tr('common.ok'),
    );
  }

  void showErrorDialog(String? message, {Function()? onClose}) {
    showNoticeErrorDialog(
      context: context,
      message: message?.isNotEmpty != true
          ? tr('common.error.technicalIssues')
          : message!,
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

  void showLoginRequired({String? message, Function()? onConfirmed}) {
    LogUtils.d('[${T.toString()}] showLoginRequired!');
    showNoticeConfirmDialog(
      barrierDismissible: true,
      context: context,
      title: tr('common.inform'),
      message: message ?? tr('common.error.sessionExpired'),
      onConfirmed: () {
        onCloseErrorDialog();
        (onConfirmed ?? backToAuth).call();
      },
      onCanceled: onCloseErrorDialog,
    );
  }

  void showNoInternetDialog() {
    showNoticeDialog(
      context: context,
      message: tr('common.error.noInternet'),
      onClose: onCloseErrorDialog,
    );
  }

  void onLogicError(String? message) {
    showErrorDialog(message);
  }

  Widget baseLoading() {
    return const Loading();
  }
}
