part of '../base.dart';

abstract class StateBase<T extends StatefulWidget> extends CoreStateBase<T> {
  @override
  void showLoginNoticeDialog({
    required Function() onSuccess,
    Function()? onSkip,
  }) {
    final trans = translate(context);
    showNoticeConfirmDialog(
      context: context,
      message: trans.loginRequired,
      title: trans.inform,
      rightBtn: trans.login,
      leftBtn: trans.skip,
      onConfirmed: () {
        backToAuth(onSuccess: onSuccess, onSkip: onSkip);
      },
    );
  }

  @override
  void backToAuth({
    Function()? onSuccess,
    Function()? onSkip,
  }) {
    context.openSignIn().then((value) {
      if (value is bool && value) {
        onSuccess?.call();
      } else {
        onSkip?.call();
      }
    });
  }

  @override
  Future<void> doLogout() async {
    showLoading();
    return super.doLogout();
  }

  Future<Location?> getLastLocation(bool required) async {
    final cubit = context.read<LocationCubit>();
    final permission = await checkLocationPermission(false, required);
    if (permission == false) {
      return null;
    }
    final positionCompleter = Completer<Location?>();

    cubit.refreshLocation().take(1).listen(positionCompleter.complete);

    final location = await positionCompleter.future;

    return location;
  }
}
