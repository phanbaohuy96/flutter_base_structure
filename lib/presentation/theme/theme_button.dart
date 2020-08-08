import 'package:flutter/material.dart';

class ThemeButton extends RawMaterialButton {
  static TextStyle getTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.headline6;
  }

  ThemeButton.primary({
    @required BuildContext context,
    String title,
    Function() onPressed,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) : super(
          fillColor: Theme.of(context).accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: onPressed,
          child: Padding(
            padding: padding,
            child: Text(
              title,
              style: getTextStyle(context).copyWith(
                color: Colors.white,
              ),
            ),
          ),
        );

  ThemeButton.notRecommend({
    @required BuildContext context,
    String title,
    Function() onPressed,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) : super(
          fillColor: Theme.of(context).primaryColorLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: onPressed,
          child: Padding(
            padding: padding,
            child: Text(
              title,
              style: getTextStyle(context).copyWith(
                color: Colors.white,
              ),
            ),
          ),
        );

  factory ThemeButton.recommend({
    @required BuildContext context,
    String title,
    Function() onPressed,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) {
    return ThemeButton.primary(
      context: context,
      title: title,
      onPressed: onPressed,
      padding: padding,
    );
  }
}
