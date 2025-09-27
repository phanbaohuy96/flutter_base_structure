import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core.dart';
import '../../../di/core_micro.dart';
import '../../../l10n/localization_ext.dart';

part 'state_base.error_handler.dart';
part 'state_base.ext.dart';

abstract class CoreStateBase<T extends StatefulWidget> extends State<T> {
  ErrorType? errorTypeShowing;

  bool get isLoading => EasyLoading.isShow;

  CoreBlocBase? get bloc => null;

  List<CoreBlocBase> get subBlocs => [];

  bool get willHandleError => true;

  CoreLocalDataManager get coreLocalDataManager =>
      injector.get<CoreLocalDataManager>();

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    logUtils.d('[${T.toString()}] initState');
    if (willHandleError) {
      bloc?.addErrorHandler(onError);
    }
    for (final bl in subBlocs) {
      bl.addErrorHandler(onError);
    }
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  @mustCallSuper
  void dispose() {
    logUtils.d('[${T.toString()}] dispose');
    super.dispose();
  }

  void showLoading({bool? dismissOnTap, String? status}) {
    EasyLoading.show(
      status: status ?? coreL10n.loading,
      indicator: const Loading(
        brightness: Brightness.dark,
      ),
      dismissOnTap: dismissOnTap ?? kDebugMode,
      maskType: EasyLoadingMaskType.clear,
    );
  }

  void hideLoading() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }

  void onError(ErrorData err) {
    var error = err;
    if (error.origin == ErrorOrigin.firebase && error.errorCode != null) {
      final firebaseAuthExceptionType =
          FirebaseAuthExceptionTypeExt.fromString(error.errorCode!);

      error = error.copyWith(
        //Get localized message, if it's null take the original
        message: firebaseAuthExceptionType?.localizedErrorMessage(
          context,
        ),
      );
    }

    hideLoading();
    _onError(error);
  }

  void showLoginNoticeDialog({
    required Function() onSuccess,
    Function()? onSkip,
  }) {}

  void backToAuth({
    Function()? onSuccess,
    Function()? onSkip,
  }) {}

  void showErrorDialog(String? message, {Function()? onClose}) {
    showNoticeErrorDialog(
      context: context,
      message:
          message?.isNotEmpty != true ? coreL10n.technicalIssues : message!,
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

  Future showLoginRequired({String? message}) {
    return showNoticeConfirmDialog(
      barrierDismissible: true,
      context: context,
      title: coreL10n.inform,
      message: message ?? coreL10n.sessionExpired,
    ).then(
      (value) {
        onCloseErrorDialog();
        return value;
      },
    );
  }

  void showNoInternetDialog() {
    showSnackBar(message: coreL10n.noInternet);
    onCloseErrorDialog.call();
  }

  void onLogicError(String? message, ErrorData error) {
    showErrorDialog(message);
  }

  Widget baseLoading() {
    return const Loading();
  }

  Future<void> doLogout() async {
    logUtils.i('doLogout');
    showLoading();
    await Future.wait(
      [
        coreLocalDataManager.clearData(),
      ],
    );
    hideLoading();
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar({
    required String message,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void showFlushBar({
    required String message,
    Widget? icon,
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? messageColor,
    EdgeInsets margin = const EdgeInsets.symmetric(
      horizontal: 24,
    ),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
    EdgeInsets padding = const EdgeInsets.symmetric(
      vertical: 16,
      horizontal: 12,
    ),
    double borderWidth = 1,
    Color? borderColor,
  }) {
    return FlashyFlushbar(
      leadingWidget: icon ?? const SizedBox.shrink(),
      message: message,
      duration: duration,
      margin: margin,
      horizontalPadding: padding,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor ?? context.theme.colorScheme.secondary,
      trailingWidget: const IconButton(
        icon: Icon(
          Icons.close,
          color: Colors.black,
          size: 24,
        ),
        onPressed: FlashyFlushbar.cancel,
      ),
      animationDuration: const Duration(milliseconds: 300),
    ).show();
  }

  void showSuccessFlushBar({
    required String message,
    Widget? icon,
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = const Color(0xffE2F1E6),
    Color messageColor = Colors.black,
    EdgeInsets margin = const EdgeInsets.symmetric(
      horizontal: 24,
    ),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
    EdgeInsets padding = const EdgeInsets.symmetric(
      vertical: 16,
      horizontal: 12,
    ),
    double borderWidth = 1,
    Color borderColor = Colors.green,
  }) {
    return showFlushBar(
      message: message,
      messageColor: messageColor,
      duration: duration,
      backgroundColor: backgroundColor,
      margin: margin.let(
        (it) {
          if (kIsWeb) {
            return it.copyWith(
              top: 16,
            );
          }
          return it;
        },
      ),
      borderRadius: borderRadius,
      padding: padding,
      icon: icon ??
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 24,
          ),
      borderWidth: borderWidth,
      borderColor: borderColor,
    );
  }

  void showErrorFlushBar({
    required String message,
    Widget? icon,
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = const Color(0xffF6E3E2),
    Color messageColor = Colors.black,
    EdgeInsets margin = const EdgeInsets.symmetric(
      horizontal: 24,
    ),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
    EdgeInsets padding = const EdgeInsets.symmetric(
      vertical: 16,
      horizontal: 12,
    ),
    double borderWidth = 1,
    Color borderColor = Colors.red,
  }) {
    return showFlushBar(
      message: message,
      messageColor: messageColor,
      duration: duration,
      backgroundColor: backgroundColor,
      margin: margin,
      borderRadius: borderRadius,
      padding: padding,
      icon: icon ??
          const Icon(
            Icons.close,
            color: Colors.red,
            size: 24,
          ),
      borderWidth: borderWidth,
      borderColor: borderColor,
    );
  }
}
