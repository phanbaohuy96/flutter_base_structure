import 'package:another_flushbar/flushbar.dart';
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

  void showLoginRequired({String? message, Function()? onConfirmed}) {
    showNoticeConfirmDialog(
      barrierDismissible: true,
      context: context,
      title: coreL10n.inform,
      message: message ?? coreL10n.sessionExpired,
      onConfirmed: () {
        onCloseErrorDialog();
        if (onConfirmed != null) {
          onConfirmed.call();
        }
      },
      onCanceled: onCloseErrorDialog,
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
        injector.get<CoreLocalDataManager>().clearData(),
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

  Future showFlushBar({
    String? title,
    String? message,
    Widget? icon,
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = Colors.black87,
    Color? messageColor,
    FlushbarPosition flushbarPosition = FlushbarPosition.TOP,
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
    return Flushbar(
      title: title,
      message: message,
      messageColor: messageColor,
      duration: duration,
      backgroundColor: backgroundColor,
      flushbarPosition: flushbarPosition,
      margin: margin,
      borderRadius: borderRadius,
      padding: padding,
      icon: icon,
      flushbarStyle: FlushbarStyle.FLOATING,
      borderWidth: borderWidth,
      borderColor: borderColor,
    ).show(globalNavigatorKey.currentContext ?? context);
  }

  Future showSuccessFlushBar({
    String? title,
    String? message,
    Widget? icon,
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = const Color(0xffE2F1E6),
    Color messageColor = Colors.black,
    FlushbarPosition flushbarPosition = FlushbarPosition.TOP,
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
      title: title,
      message: message,
      messageColor: messageColor,
      duration: duration,
      backgroundColor: backgroundColor,
      flushbarPosition: flushbarPosition,
      margin: margin,
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

  Future showErrorFlushBar({
    String? title,
    String? message,
    Widget? icon,
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = const Color(0xffE2F1E6),
    Color messageColor = Colors.black,
    FlushbarPosition flushbarPosition = FlushbarPosition.TOP,
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
      title: title,
      message: message,
      messageColor: messageColor,
      duration: duration,
      backgroundColor: backgroundColor,
      flushbarPosition: flushbarPosition,
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
