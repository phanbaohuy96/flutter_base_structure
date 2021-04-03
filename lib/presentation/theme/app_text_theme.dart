import 'package:flutter/material.dart';
import 'theme_color.dart';

class AppTextTheme {
  static TextStyle textLinkStyle = const TextStyle(
    decoration: TextDecoration.underline,
    color: AppColor.primaryColorLight,
    fontSize: 14,
  );

  static TextTheme getDefaultTextTheme() => const TextTheme(
        headline3: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryColor,
        ),
        headline4: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryText,
        ),
        headline5: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryText,
        ),
        headline6: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColor.subText,
        ),
        subtitle1: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColor.subText,
        ),
        subtitle2: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColor.subText,
        ),
        bodyText1: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
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
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
  static TextTheme getDefaultTextThemeDark() => const TextTheme(
        headline3: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryColor,
        ),
        headline4: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryDarkText,
        ),
        headline5: TextStyle(
          fontSize: 18,
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
      );
}
