import 'package:flutter/material.dart';

class AppLocale {
  static const th = Locale('th', 'TH');
  static const en = Locale('en', 'US');
  static const defaultLocale = th;

  static const supportedLocales = [en, th];

  static bool isSupported(Locale locale) {
    return supportedLocales.any((e) => e.languageCode == locale.languageCode);
  }
}
