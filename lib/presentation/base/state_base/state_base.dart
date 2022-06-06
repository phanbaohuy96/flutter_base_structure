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
      bloc?.errorHandler = onError;
    }
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    ClientInfo.languageCode = languageCode;
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
        status: trans.processing,
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
    hideLoading();
    _onError(error);
  }

  void showErrorDialog(String? message, {Function()? onClose}) {
    showNoticeErrorDialog(
      context: context,
      message: message?.isNotEmpty != true ? trans.technicalIssues : message!,
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

  void showNoInternetDialog() {
    showNoticeDialog(
      context: context,
      message: trans.noInternet,
      onClose: onCloseErrorDialog,
    );
  }

  void onLogicError(String? message) {
    showErrorDialog(message);
  }

  Widget baseLoading() {
    return const Loading();
  }

  void requireLogin({required Function() onSuccess, Function()? onSkip}) {
    // if (injector.get<AuthService>().isSignedIn) {
    //   onSuccess.call();
    //   return;
    // }
    showNoticeConfirmDialog(
      context: context,
      message: trans.loginRequired,
      title: trans.inform,
      titleBtnDone: trans.login,
      titleBtnCancel: trans.dismiss,
      onCanceled: onSkip,
      onConfirmed: () {
        _showLoginScreen(onSuccess, onSkip);
      },
    );
  }

  void _showLoginScreen(Function() onSuccess, Function()? onSkip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const SizedBox();
      },
    );
  }

  Future<void> openWeb({String? title, String? url, String? html}) async {
    await Navigator.of(context).pushNamed(
      RouteList.webview,
      arguments: WebviewArgs(
        title: title,
        html: html,
        url: url,
      ),
    );
  }

  String get languageCode =>
      context.read<AppDataBloc>().state?.locale.languageCode ??
      AppLocale.vi.languageCode;
}
