import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/simple_button.dart';

class ThemeButton extends SimpleButton {
  ThemeButton._();
  ThemeButton.primary({
    @required BuildContext context,
    String title,
    Function() onTap,
    double width,
    double height,
  }) : super(
          text: title,
          onPressed: onTap,
          width: width,
          height: height,
          borderRadius: 8,
          textStyle: Theme.of(context).textTheme.title,
          color: Theme.of(context).accentColor,
        );

  ThemeButton.left({
    @required BuildContext context,
    String title,
    Function() onTap,
    double width,
    double height,
  }) : super(
          text: title,
          onPressed: onTap,
          width: width,
          height: height,
          borderRadius: 8,
          textStyle: Theme.of(context).textTheme.title,
          color: Theme.of(context).primaryColorLight,
        );

  ThemeButton.right({
    @required BuildContext context,
    String title,
    Function() onTap,
    double width,
    double height,
  }) : super(
          text: title,
          onPressed: onTap,
          width: width,
          height: height,
          borderRadius: 8,
          textStyle: Theme.of(context).textTheme.title,
          color: Theme.of(context).accentColor,
        );
}
