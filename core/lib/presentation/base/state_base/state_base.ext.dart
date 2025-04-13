part of 'state_base.dart';

extension StateBaseExtention on CoreStateBase {
  void hideKeyBoard() => CoreCommonFunction().hideKeyBoard(context);

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

void showToast(BuildContext context, String message) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: context.themeColor.secondary,
    textColor: Colors.black,
    fontSize: 14.0,
  );
}
