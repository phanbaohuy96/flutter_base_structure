import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../common/constants.dart';
import '../common_widget/export.dart';

class ThemeButton {
  static TextStyle getTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.button;
  }

  static Widget primary({
    @required BuildContext context,
    String title,
    Function() onPressed,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16),
    BoxConstraints constraints = const BoxConstraints(minHeight: 48.0),
  }) =>
      RawMaterialButton(
        fillColor: Theme.of(context).accentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        onPressed: onPressed,
        elevation: 0,
        padding: padding,
        constraints: constraints,
        child: Text(
          title,
          style: getTextStyle(context).copyWith(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      );

  static Widget primaryIcon({
    @required BuildContext context,
    @required String title,
    @required Widget icon,
    Function() onPressed,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 15,
    ),
    BoxConstraints constraints = const BoxConstraints(minHeight: 48.0),
  }) =>
      RawMaterialButton(
        fillColor: Theme.of(context).accentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        onPressed: onPressed,
        elevation: 0,
        padding: padding,
        constraints: constraints,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Text(
                title,
                style: getTextStyle(context).copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 6),
            icon,
          ],
        ),
      );

  static Widget notRecommend({
    @required BuildContext context,
    String title = '',
    Function() onPressed,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16),
    BoxConstraints constraints = const BoxConstraints(minHeight: 48.0),
  }) =>
      RawMaterialButton(
        fillColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        onPressed: onPressed,
        elevation: 0,
        padding: padding,
        constraints: constraints,
        child: Text(
          title,
          style: getTextStyle(context).copyWith(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      );

  static Widget recommend({
    @required BuildContext context,
    String title,
    Function() onPressed,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16),
    BoxConstraints constraints = const BoxConstraints(minHeight: 48.0),
  }) {
    return ThemeButton.primary(
      context: context,
      title: title,
      onPressed: onPressed,
      padding: padding,
      constraints: constraints,
    );
  }

  static Widget loadingButton({
    @required BuildContext context,
    @required LoadingButtonController controller,
    String title = '',
    Function onPressed,
    Widget icon,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 15,
    ),
  }) {
    return LoadingButton(
      controller: controller,
      title: title,
      textStyle: getTextStyle(context),
      normalIcon: icon ??
          Image.asset(
            ImageConstant.iconArrowCircleRight,
            width: 16,
            height: 16,
          ),
      loadingIndicator: const SpinKitFadingCircle(
        color: Colors.white,
        size: 16,
      ),
      bgColor: Theme.of(context).accentColor,
      onPressed: onPressed,
      padding: padding,
    );
  }
}
