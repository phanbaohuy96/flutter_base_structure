import 'package:flutter/material.dart';
import 'theme_color.dart';

class AppTextTheme {
  static TextTheme getDefaultTextTheme() => const TextTheme(
        title: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryText,
        ),
        subtitle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryText,
        ),
        headline: TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryText,
        ),
        subhead: TextStyle(
          fontSize: 10,
        ),
      );
  static TextTheme getDefaultTextThemeDark() => const TextTheme(
        title: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryText,
        ),
        subtitle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryText,
        ),
        headline: TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryText,
        ),
      );
}
