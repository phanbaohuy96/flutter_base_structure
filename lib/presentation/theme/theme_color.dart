import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';

class AppColor {
  static const Color white = Colors.white;
  static const Color primaryColor = Color(0xFF03a1e4);
  static const Color primaryColorLight = Color(0xFF43c8f5);
  static const Color cardBackground = Color(0xFFf7f8f8);
  static const Color iconSelected = primaryColor;
  static const Color iconUnselected = Colors.grey;
  static const Color lightGrey = Color(0xFFbebebe);
  static const Color greyDC = Color(0xFFdcdcdc);
  static const Color scaffoldBackgroundColor = Color(0xFFF1F3F7);

  static const Color inactiveColor = Color(0xFF111111);
  static const Color activeColor = primaryColor;

  static const Color titleMenu = Colors.grey;
  static const Color primaryIcon = Colors.grey;
  static const Color green = Color(0xFF4d9e53);
  static const Color red = Color(0xFFfb4b53);
  static const Color orange = Color(0xFFff9b1a);
  static const Color darkBlue = Color(0xFF002d41);

  //light
  static const Color primaryText = Colors.black;
  static const Color subText = Color(0xFF767676);

  //dart
  static const Color primaryDarkText = Colors.black;
  static const Color subDarkText = Colors.grey;

  static void setLightStatusBar() {
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
  }

  static void setDarkStatusBar() {
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
  }
}
