import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/simple_button.dart';

class ThemeButton extends SimpleButton {
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
          textStyle: Theme.of(context).textTheme.button,
          color: Theme.of(context).accentColor,
        );

  ThemeButton.notRecommend({
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
          textStyle: Theme.of(context).textTheme.button,
          color: Theme.of(context).primaryColorLight,
        );

  ThemeButton.recommend({
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
          textStyle: Theme.of(context).textTheme.button,
          color: Theme.of(context).accentColor,
        );
}
