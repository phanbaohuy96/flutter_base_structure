import 'package:flutter/material.dart';
import 'theme_color.dart';

class AppTextTheme {
  static TextTheme getDefaultTextTheme() => const TextTheme(
        headline1: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryText,
        ),
        headline2: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryText,
        ),
        headline3: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryText,
        ),
        headline4: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryText,
        ),
        headline5: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryText,
        ),
        headline6: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryText,
        ),
        subtitle1: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColor.subText,
        ),
        subtitle2: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColor.subText,
        ),
        bodyText1: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryText,
        ),
        bodyText2: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColor.primaryText,
        ),
        caption: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryText,
        ),
        button: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColor.primaryText,
        ),
        overline: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColor.primaryText,
        ),
      );
  static TextTheme getDefaultTextThemeDark() => const TextTheme(
        headline1: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryDarkText,
        ),
        headline2: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryDarkText,
        ),
        headline3: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryDarkText,
        ),
        headline4: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryDarkText,
        ),
        headline5: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryDarkText,
        ),
        headline6: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryDarkText,
        ),
        subtitle1: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColor.subDarkText,
        ),
        subtitle2: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColor.subDarkText,
        ),
        bodyText1: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryDarkText,
        ),
        bodyText2: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColor.primaryDarkText,
        ),
        caption: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryDarkText,
        ),
        button: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColor.primaryDarkText,
        ),
        overline: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColor.primaryDarkText,
        ),
      );
}
