import 'dart:ui';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'constants/locale/app_locale.dart';

class CalendarHelper {
  static var _isBuddhist = false;

  static bool get isBuddhist => _isBuddhist;

  static set enableBuddhistCalendar(bool enabled) {
    _isBuddhist = enabled;
  }

  static Future setupCalendarByLocale(Locale locale) {
    /// Enable buddhist calendar
    CalendarHelper.enableBuddhistCalendar =
        locale.languageCode == AppLocale.th.languageCode;

    Intl.defaultLocale = locale.languageCode;
    return initializeDateFormatting();
  }
}

extension BuddhistCalendarFormatter on DateTime {
  int get calendarYear {
    return year + (CalendarHelper._isBuddhist ? 543 : 0);
  }

  String get calendarYearStr => calendarYear.toString();
}
