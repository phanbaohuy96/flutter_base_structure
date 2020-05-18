import 'package:flutter/material.dart';
import 'text_utils.dart';
import 'theme_color.dart';

class AppTextTheme {
  static TextTheme getDefaultTextTheme() => TextTheme(
        title: TextStyle(
          fontSize: TextSize.size20,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryText,
        ),
        subtitle: TextStyle(
          fontSize: TextSize.size16,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryText,
        ),
        headline: TextStyle(
          fontSize: TextSize.size35,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryText,
        ),
        subhead: TextStyle(
          fontSize: TextSize.size10,
        ),
      );
  static TextTheme getDefaultTextThemeDark() => TextTheme(
        title: TextStyle(
          fontSize: TextSize.size20,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryText,
        ),
        subtitle: TextStyle(
          fontSize: TextSize.size16,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryText,
        ),
        headline: TextStyle(
          fontSize: TextSize.size35,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryText,
        ),
      );
}
