import 'package:flutter/material.dart';
import 'text_utils.dart';
import 'theme_color.dart';

class AppTextTheme {
  static TextTheme getDefaultTextTheme() => TextTheme(
        headline1: TextStyle(
          fontSize: TextSize.size30,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryText,
        ),
        headline2: TextStyle(
          fontSize: TextSize.size26,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryText,
        ),
        headline3: TextStyle(
          fontSize: TextSize.size24,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryText,
        ),
        headline4: TextStyle(
          fontSize: TextSize.size22,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryText,
        ),
        headline5: TextStyle(
          fontSize: TextSize.size20,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryText,
        ),
        headline6: TextStyle(
          fontSize: TextSize.size18,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryText,
        ),
        subtitle1: TextStyle(
          fontSize: TextSize.size14,
          fontWeight: FontWeight.normal,
          color: AppColor.subText,
        ),
        subtitle2: TextStyle(
          fontSize: TextSize.size12,
          fontWeight: FontWeight.normal,
          color: AppColor.subText,
        ),
        bodyText1: TextStyle(
          fontSize: TextSize.size16,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryText,
        ),
        bodyText2: TextStyle(
          fontSize: TextSize.size16,
          fontWeight: FontWeight.normal,
          color: AppColor.primaryText,
        ),
        caption: TextStyle(
          fontSize: TextSize.size16,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryText,
        ),
        button: TextStyle(
          fontSize: TextSize.size16,
          fontWeight: FontWeight.normal,
          color: AppColor.primaryText,
        ),
        overline: TextStyle(
          fontSize: TextSize.size14,
          fontWeight: FontWeight.normal,
          color: AppColor.primaryText,
        ),
      );
  static TextTheme getDefaultTextThemeDark() => TextTheme(
        headline1: TextStyle(
          fontSize: TextSize.size30,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryDarkText,
        ),
        headline2: TextStyle(
          fontSize: TextSize.size26,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryDarkText,
        ),
        headline3: TextStyle(
          fontSize: TextSize.size24,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryDarkText,
        ),
        headline4: TextStyle(
          fontSize: TextSize.size22,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryDarkText,
        ),
        headline5: TextStyle(
          fontSize: TextSize.size20,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryDarkText,
        ),
        headline6: TextStyle(
          fontSize: TextSize.size18,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryDarkText,
        ),
        subtitle1: TextStyle(
          fontSize: TextSize.size14,
          fontWeight: FontWeight.normal,
          color: AppColor.subDarkText,
        ),
        subtitle2: TextStyle(
          fontSize: TextSize.size12,
          fontWeight: FontWeight.normal,
          color: AppColor.subDarkText,
        ),
        bodyText1: TextStyle(
          fontSize: TextSize.size16,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryDarkText,
        ),
        bodyText2: TextStyle(
          fontSize: TextSize.size16,
          fontWeight: FontWeight.normal,
          color: AppColor.primaryDarkText,
        ),
        caption: TextStyle(
          fontSize: TextSize.size16,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryDarkText,
        ),
        button: TextStyle(
          fontSize: TextSize.size16,
          fontWeight: FontWeight.normal,
          color: AppColor.primaryDarkText,
        ),
        overline: TextStyle(
          fontSize: TextSize.size14,
          fontWeight: FontWeight.normal,
          color: AppColor.primaryDarkText,
        ),
      );
}
