part of 'state_base.dart';

extension StateBaseExtention on CoreStateBase {
  void hideKeyBoard() => CoreCommonFunction().hideKeyboard(context);

  Size get device => MediaQuery.of(context).size;

  double get paddingTop => MediaQuery.of(context).padding.top;

  double get paddingBottom => MediaQuery.of(context).padding.bottom;

  Future<bool> checkLocationPermission([
    bool refreshInBackground = true,
    bool required = false,
  ]) async {
    final granted = await PermissionService().checkPermission(
      Permission.location,
      context,
    );

    if (!granted) {
      final status = await PermissionService().requestPermission(
        Permission.location,
        context,
        required: required,
      );

      if (status) {
        if (await Geolocator.isLocationServiceEnabled()) {
          await context.read<LocationCubit>().refreshLocation().first;
          return true;
        } else if (required) {
          unawaited(
            showNoticeDialog(
              context: context,
              message: context.coreL10n.pleaseEnableGPS,
            ),
          );
          return false;
        }
      }
      return status;
    } else {
      if (refreshInBackground) {
        unawaited(context.read<LocationCubit>().getLastKnownLocation());
      }
    }

    return granted;
  }
}

void showToast(
  BuildContext context,
  String message, {
  Toast? toastLength = Toast.LENGTH_SHORT,
}) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
    msg: message,
    toastLength: toastLength,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: context.themeColor.secondary,
    textColor: Colors.black,
    fontSize: 14.0,
  );
}

/// Shows snack bar with message
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar({
  required BuildContext context,
  required String message,
  Duration duration = const Duration(seconds: 4),
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: duration, action: action),
  );
}

/// Shows customizable flush bar notification
void showFlushBar({
  required String message,
  Widget? icon,
  Duration duration = const Duration(seconds: 2),
  Color? backgroundColor,
  Color? messageColor,
  EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 24),
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
  EdgeInsets padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
  double borderWidth = 1,
  Color? borderColor,
}) {
  FlashyFlushbar(
    leadingWidget: icon ?? const SizedBox.shrink(),
    message: message,
    duration: duration,
    margin: _adjustFlushBarMarginForWeb(margin),
    horizontalPadding: padding,
    borderRadius: borderRadius,
    backgroundColor:
        backgroundColor ??
        globalNavigatorKey.currentContext?.theme.colorScheme.secondary ??
        Colors.white,
    trailingWidget: const IconButton(
      icon: Icon(Icons.close, color: Colors.black, size: 24),
      onPressed: FlashyFlushbar.cancel,
    ),
    animationDuration: const Duration(milliseconds: 300),
  ).show();
}

/// Adjusts margin for web platform
EdgeInsets _adjustFlushBarMarginForWeb(EdgeInsets margin) {
  return kIsWeb ? margin.copyWith(top: 16) : margin;
}

/// Shows success notification
void showSuccessFlushBar({
  required String message,
  Widget? icon,
  Duration duration = const Duration(seconds: 2),
  Color backgroundColor = const Color(0xffE2F1E6),
  Color messageColor = Colors.black,
  EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 24),
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
  EdgeInsets padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
  double borderWidth = 1,
  Color borderColor = Colors.green,
}) {
  showFlushBar(
    message: message,
    messageColor: messageColor,
    duration: duration,
    backgroundColor: backgroundColor,
    margin: _adjustFlushBarMarginForWeb(margin),
    borderRadius: borderRadius,
    padding: padding,
    icon:
        icon ??
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
    borderWidth: borderWidth,
    borderColor: borderColor,
  );
}

/// Shows error notification
void showErrorFlushBar({
  required String message,
  Widget? icon,
  Duration duration = const Duration(seconds: 2),
  Color backgroundColor = const Color(0xffF6E3E2),
  Color messageColor = Colors.black,
  EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 24),
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
  EdgeInsets padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
  double borderWidth = 1,
  Color borderColor = Colors.red,
}) {
  showFlushBar(
    message: message,
    messageColor: messageColor,
    duration: duration,
    backgroundColor: backgroundColor,
    margin: margin,
    borderRadius: borderRadius,
    padding: padding,
    icon: icon ?? const Icon(Icons.close, color: Colors.red, size: 24),
    borderWidth: borderWidth,
    borderColor: borderColor,
  );
}
