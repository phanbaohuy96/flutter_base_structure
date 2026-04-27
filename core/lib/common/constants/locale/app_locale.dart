import 'package:flutter/material.dart';

class AppLocale {
  static const vi = Locale('vi', 'VN');
  static const en = Locale('en', 'US');
  static const defaultLocale = en;

  static const supportedLocales = [en, vi];

  static bool isSupported(Locale locale) {
    return supportedLocales.any((e) => e.languageCode == locale.languageCode);
  }
}
