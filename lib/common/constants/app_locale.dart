import 'package:flutter/material.dart';

class AppLocale {
  static const vi = Locale('vi');
  static const en = Locale('en');

  static const supportedLocales = [vi, en];

  static bool isSupported(Locale locale) {
    return supportedLocales.any((e) => e.languageCode == locale.languageCode);
  }
}
