import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import '../common/components/i18n/internationalization.dart';
import '../common/utils/log_utils.dart';
import '../data/data_source/remote/app_api_service.dart';
import '../presentation/extentions/dialog_extention.dart';
import 'bloc_base.dart';

abstract class StateBase<T extends StatefulWidget> extends State<T>
    implements ApiServiceHandler {
  BlocBase getBloc();

  @override
  void initState() {
    super.initState();
    LogUtils.i('[ScreenBase->${T.toString()}] initState');
    getBloc()?.appApiService?.handlerEror = this;
  }

  @override
  dynamic onError(ErrorData error) {
    LogUtils.i('[ScreenBase->${T.toString()}] error ${error.type}');

    switch (error.type) {
      case ErrorType.unAuthorized:
        showLoginRequired();
        break;
      case ErrorType.httpException:
        if (error.statusCode >= 500 && error.statusCode < 600) {
          showErrorDialog(
            S.of(context).translate('common.error.technicalIssues'),
          );
          break;
        }
        showErrorDialog(error.message);
        break;
      case ErrorType.timeout:
        showErrorDialog(
          S.of(context).translate('common.error.connectionTimeout'),
        );
        break;
      case ErrorType.noInternet:
        showNoInternetDialog();
        break;
      case ErrorType.unKnown:
        showErrorDialog(
          S.of(context).translate('common.error.unknowError'),
        );
        break;
      case ErrorType.serverUnExpected:
        showErrorDialog(
          S.of(context).translate('common.error.serverMaintenance'),
        );
        break;
      default:
        break;
    }

    return error;
  }

  void showLoading() {
    LogUtils.i('[ScreenBase->${T.toString()}] showLoading');
  }

  void hideLoading() {
    LogUtils.i('[ScreenBase->${T.toString()}] hideLoading');
  }

  void showMessage(String msg) {
    Toast.show(
      msg,
      context,
      duration: Toast.LENGTH_LONG,
      gravity: Toast.BOTTOM,
    );
  }

  void showErrorDialog(String message) {
    showNoticeErrorDialog(context: context, message: message);
  }

  void showLoginRequired() {
    showNoticeConfirmDialog(
      barrierDismissible: false,
      context: context,
      icon: const Icon(Icons.warning, size: 100, color: Colors.orange),
      message: 'Please login to continue!',
      onConfirmed: () {},
    );
  }

  void showNoInternetDialog() {
    showNoticeDialog(
      context: context,
      message: S.of(context).translate('common.error.noInternet'),
      icon: Icon(
        Icons.wifi,
        color: Theme.of(context).accentColor,
        size: 150,
      ),
    );
  }

  Widget baseLoading() {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
    );
  }
}
