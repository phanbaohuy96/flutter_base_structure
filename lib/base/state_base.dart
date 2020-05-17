import 'package:flutter/material.dart';

import 'package:toast/toast.dart';
import 'package:fluttersimpleui/dialog.dart';
import 'package:fluttersimpleui/simple_button.dart';

import '../data/data_source/remote/app_api_service.dart';
import '../presentation/theme/theme_color.dart';
import '../utils/dimension.dart';
import '../utils/log_utils.dart';
import 'bloc_base.dart';

abstract class StateBase<T extends StatefulWidget> extends State<T>
    implements ApiServiceHandler {
  BlocBase getBloc();

  StateBase() {
    LogUtils.i('[ScreenBase->${T.toString()}] contructor');
  }

  @override
  void initState() {
    super.initState();

    LogUtils.i('[ScreenBase->${T.toString()}] initState');
    getBloc()?.appApiService?.handlerEror = this;
  }

  @override
  dynamic onError(ErrorData error) {
    LogUtils.i('[Statebase] error ${error.type}');

    switch (error.type) {
      case ErrorType.unAuthorized:
        showLoginRequired();
        break;
      case ErrorType.httpException:
        if (error.statusCode >= 500 && error.statusCode < 600) {
          showErrorDialog(
            '''Oops! There seems to be a technical issue. Please check your connectivity or try again later.''',
          );
          break;
        }
        // else if(error.statusCode == 404){
        //   showErrorDialog('404');
        //   // break;
        // }
        showErrorDialog(error.message);
        break;
      case ErrorType.timeout:
        {
          showErrorDialog('Connection timmed out.');
          break;
        }
      case ErrorType.noInternet:
        {
          showNoInternetDialog();
          break;
        }
      case ErrorType.unKnown:
        {
          showErrorDialog('Unknown error!');
          break;
        }
      case ErrorType.serverUnExpected:
        {
          showErrorDialog(
            'Server maintenance \n Unexpected character',
          );
          break;
        }
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

  void showLoginRequired() {
    LogUtils.i('[ScreenBase->${T.toString()}] showLoginRequired ');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return errorNotiedErrorPopup(
          width: Dimension.getWidth(0.9),
          height: Dimension.getWidth(0.9),
          content: 'Please login to continue!',
          onTap: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void showNoInternetDialog() {
    LogUtils.i('[ScreenBase->${T.toString()}] showNoInternetDialog ');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return errorInternet(
          iconPopup: Icon(
            Icons.wifi,
            color: Theme.of(context).accentColor,
            size: 150,
          ),
          width: Dimension.getWidth(0.9),
          height: Dimension.getWidth(0.9),
          onTap: () {
            Navigator.pop(context);
          },
          buttonBg: [
            Theme.of(context).accentColor,
            Theme.of(context).accentColor,
          ],
        );
      },
    );
  }

  void showErrorDialog(String message) {
    LogUtils.i(
        '[ScreenBase->${T.toString()}] showErrorDialog message: $message');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return errorNotiedErrorPopup(
          width: Dimension.getWidth(0.9),
          height: Dimension.getWidth(0.9),
          content: message,
          onTap: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget baseLoading() {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
    );
  }

  void showMessage(String msg) {
    Toast.show(
      msg,
      context,
      duration: Toast.LENGTH_LONG,
      gravity: Toast.BOTTOM,
    );
  }

  dynamic errorInternet({
    String titlePopup = 'Oh No!',
    TextStyle styleTextTitle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    TextStyle styleTextContent = const TextStyle(
      fontSize: 13,
      color: Colors.black45,
    ),
    TextStyle styleTextButton = const TextStyle(
      color: Colors.white,
    ),
    String content =
        'No internet connection found.\n Check your connection and try again',
    String titleButton = 'Try again',
    Function() onTap,
    Icon iconPopup = const Icon(Icons.wifi, color: Colors.red, size: 150),
    double width = 250,
    double height = 280,
    List<Color> buttonBg = const [Colors.redAccent, Colors.redAccent],
  }) {
    return NotifyDialog(
      iconPopup: iconPopup,
      titlePopup: Text(
        titlePopup,
        style: styleTextTitle,
      ),
      content: Text(
        content,
        style: styleTextContent,
        textAlign: TextAlign.center,
      ),
      buttonActions: [
        SimpleButton(
          width: 120,
          height: 45,
          borderRadius: 8,
          textStyle: styleTextButton,
          text: titleButton,
          bgColors: buttonBg,
          onPressed: onTap,
        )
      ],
      width: width,
      height: height,
    );
  }

  dynamic errorNotiedErrorPopup({
    String titlePopup = 'Oh No!',
    TextStyle styleTextTitle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    TextStyle styleTextContent = const TextStyle(
      fontSize: 16,
      color: Colors.grey,
    ),
    TextStyle styleTextButton = const TextStyle(
      color: Colors.white,
    ),
    String content = 'Something went wrong!',
    String titleButton = 'Close',
    Function() onTap,
    Icon iconPopup = const Icon(
      Icons.error,
      color: Colors.red,
      size: 100,
    ),
    double width = 250,
    double height = 280,
  }) {
    return NotifyDialog(
      iconPopup: iconPopup,
      titlePopup: Text(
        titlePopup,
        style: styleTextTitle,
      ),
      content: Text(
        content,
        style: styleTextContent,
        textAlign: TextAlign.center,
      ),
      buttonActions: [
        SimpleButton(
          width: 120,
          height: 45,
          borderRadius: 8,
          textStyle: styleTextButton,
          text: titleButton,
          bgColors: const [Colors.redAccent, Colors.redAccent],
          onPressed: onTap,
        )
      ],
      width: width,
      height: height,
    );
  }

  dynamic errorNotiedPopup({
    String titlePopup = 'Attention',
    TextStyle styleTextTitle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    TextStyle styleTextContent = const TextStyle(
      fontSize: 16,
      color: Colors.grey,
    ),
    TextStyle styleTextButton = const TextStyle(
      color: Colors.white,
    ),
    @required String content,
    String titleButton = 'Close',
    Function() onTap,
    Icon iconPopup = const Icon(
      Icons.warning,
      color: AppColor.primaryColor,
      size: 100,
    ),
    double width = 250,
    double height = 280,
  }) {
    final simpleButton = SimpleButton(
      width: 120,
      height: 45,
      borderRadius: 8,
      textStyle: styleTextButton,
      text: titleButton,
      bgColors: const [AppColor.primaryColor, AppColor.primaryColor],
      onPressed: onTap,
    );

    return NotifyDialog(
      iconPopup: iconPopup,
      titlePopup: Text(
        titlePopup,
        style: styleTextTitle,
      ),
      content: Text(
        content,
        style: styleTextContent,
        textAlign: TextAlign.center,
      ),
      buttonActions: [simpleButton],
      width: width,
      height: height,
    );
  }
}
