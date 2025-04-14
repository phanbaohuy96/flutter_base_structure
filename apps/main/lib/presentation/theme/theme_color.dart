import 'package:core/core.dart';
import 'package:flutter/material.dart';

class AppThemeColor extends ThemeColor {
  AppThemeColor({
    super.primary = const Color(0xFF3B82F6),
    super.secondary = const Color(0xFFEFF6FF),
    super.appbarBackgroundColor = Colors.white,
    super.appbarForegroundColor = Colors.black,
    super.scaffoldBackgroundColor = const Color(0xffF3F4F6),
    super.brightness = Brightness.light,
    super.elevatedBtnForegroundColor = Colors.white,
    super.schemeAction = Colors.grey,
    super.outlineButtonColor = const Color(0xff3B82F6),
    super.lableText = const Color(0xff8E8E93),
  });
}

class AppDarkThemeColor extends ThemeColor {
  AppDarkThemeColor({
    super.primary = const Color(0xFF3B82F6),
    super.secondary = const Color(0xFFEFF6FF),
    super.appbarForegroundColor = Colors.white60,
    super.appbarBackgroundColor = Colors.black54,
    super.brightness = Brightness.dark,
    super.schemeAction = Colors.grey,
    super.outlineButtonColor = const Color(0xff3B82F6),
    super.lableText = const Color(0xff8E8E93),
  });
}
