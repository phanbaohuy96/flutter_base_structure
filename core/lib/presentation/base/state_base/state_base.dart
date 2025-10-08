import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core.dart';
import '../../../l10n/localization_ext.dart';
import '../delegate.dart';
import 'mixin.dart';

part 'state_base.error_handler.dart';
part 'state_base.ext.dart';

/// Base state class that provides common functionality for all stateful widgets
/// in the application including error handling, loading states,
/// and notifications.
abstract class CoreStateBase<T extends StatefulWidget> extends State<T>
    with StateBaseInjectedMixin {
  ErrorType? errorTypeShowing;

  bool get isLoading => EasyLoading.isShow;

  /// Override this to provide bloc instance for error handling
  CoreDelegate? get delegate => null;

  /// Override this to disable automatic error handling
  bool get willHandleError => true;

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    _logLifecycle('initState');
    _setupDelegate();
  }

  @override
  @mustCallSuper
  void dispose() {
    _logLifecycle('dispose');
    super.dispose();
  }

  /// Logs lifecycle events with consistent formatting
  void _logLifecycle(String event) {
    logUtils.d('[${T.toString()}] $event');
  }

  /// Sets up delegate handlers for error and loading management
  void _setupDelegate() {
    if (willHandleError) {
      delegate?.addErrorHandler(onError);
    }
    delegate?.addLoadingHandler(invokeLoading);
  }

  /// Shows loading indicator with customizable options
  void showLoading({
    bool? dismissOnTap,
    String? status,
    EasyLoadingMaskType maskType = EasyLoadingMaskType.clear,
  }) {
    EasyLoading.show(
      status: status ?? coreL10n.loading,
      indicator: const Loading(brightness: Brightness.dark),
      dismissOnTap: dismissOnTap ?? kDebugMode,
      maskType: maskType,
    );
  }

  /// Hides loading indicator if currently showing
  void hideLoading() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }

  void invokeLoading(bool isLoading) {
    if (isLoading) {
      showLoading();
    } else {
      hideLoading();
    }
  }

  /// Handles errors with Firebase-specific processing
  void onError(ErrorData error) {
    final processedError = _processFirebaseError(error);
    hideLoading();
    _onError(processedError);
  }

  /// Processes Firebase authentication errors
  ErrorData _processFirebaseError(ErrorData error) {
    if (error.origin != ErrorOrigin.firebase || error.errorCode == null) {
      return error;
    }

    final firebaseAuthExceptionType =
        FirebaseAuthExceptionTypeExt.fromString(error.errorCode!);

    if (firebaseAuthExceptionType == null) {
      return error;
    }

    final localizedMessage =
        firebaseAuthExceptionType.localizedErrorMessage(context);
    return error.copyWith(message: localizedMessage);
  }

  /// Handles unauthorized errors - triggers auth flow
  void backToAuth({
    VoidCallback? onSuccess,
    VoidCallback? onSkip,
  }) {
    logUtils.w(
      '''There is no backToAuth implementation. Please override it in subclass if needed.''',
    );
  }

  /// Shows error dialog with consistent styling
  void showErrorDialog(
    String? message,
    ErrorData error, {
    VoidCallback? onClose,
  }) {
    errorTypeShowing = error.type;

    final displayMessage =
        message?.isNotEmpty == true ? message! : coreL10n.technicalIssues;

    showNoticeErrorDialog(
      context: context,
      message: displayMessage,
      onClose: () {
        _onCloseErrorDialog();
        onClose?.call();
      },
    );
  }

  /// Resets error state
  void _onCloseErrorDialog() {
    errorTypeShowing = null;
  }

  /// Public method to close error dialog
  @mustCallSuper
  void onCloseErrorDialog() => _onCloseErrorDialog();

  /// Shows login required dialog
  Future<dynamic> showLoginRequired({
    String? message,
    required ErrorData error,
  }) {
    errorTypeShowing = error.type;

    return showNoticeConfirmDialog(
      context: context,
      message: coreL10n.loginRequired,
      title: coreL10n.inform,
      rightBtn: coreL10n.login,
      leftBtn: coreL10n.skip,
      onConfirmed: backToAuth,
    ).then((value) {
      _onCloseErrorDialog();
      return value;
    });
  }

  /// Shows no internet connection notification
  void showNoInternetDialog() {
    showSnackBar(
      context: context,
      message: coreL10n.noInternet,
    );
  }

  /// Handles logic errors
  void onClientError(String? message, ErrorData error) {
    showErrorDialog(message, error);
  }

  /// Returns base loading widget
  Widget get loading => const Loading();

  /// Performs logout operation
  Future<void> doLogout() async {
    logUtils.i('Performing logout');

    try {
      showLoading(status: coreL10n.loggingOut);

      await Future.wait([
        coreLocalDataManager.clearData(),
      ]);

      logUtils.i('Logout completed successfully');
    } catch (e) {
      logUtils.e('Logout failed: $e');
      rethrow;
    } finally {
      hideLoading();
    }
  }
}
