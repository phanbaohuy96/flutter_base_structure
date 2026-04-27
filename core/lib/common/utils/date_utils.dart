// ignore_for_file: constant_identifier_names

import 'package:date_format/date_format.dart';
import 'package:timeago/timeago.dart' as tag_format;

import '../calendar.dart';

extension DateUtilsExtention on DateTime {
  String customFormat(
    List<String> format, {
    DateLocale locale = const EnglishDateLocale(),
    bool useCalendarFormat = true,
  }) {
    return formatDate(toLocal(), [
      ...useCalendarFormat
          ? format.map((e) => e == yyyy ? calendarYearStr : e)
          : format,
    ], locale: locale);
  }

  /// **[mm, ' ', yyyy]**
  ///
  /// **01 2000**
  String get toLocalmmyyyy {
    return formatDate(toLocal(), [mm, ' ', calendarYearStr]);
  }

  /// **[dd, '/', mm, '/', yyyy]**
  ///
  /// **01/01/2000**
  String get toLocalddmmyyyy {
    return formatDate(toLocal(), [dd, '/', mm, '/', calendarYearStr]);
  }

  /// **[dd, '/', mm, '/', yyyy]**
  ///
  /// **01/01/2000**
  String get ddmmyyyy {
    return formatDate(this, [dd, '/', mm, '/', calendarYearStr]);
  }

  /// **[HH, ':', nn, ' - ', dd, '/', mm, '/', yyyy]**
  ///
  /// **10:59 - 01/01/2000**
  String get toLocalHHnnddmmyyyy {
    return formatDate(toLocal(), [
      HH,
      ':',
      nn,
      ' - ',
      dd,
      '/',
      mm,
      '/',
      calendarYearStr,
    ]);
  }

  /// **[ dd, '/', mm, '/', yyyy, ' ', HH, ':', nn]**
  ///
  /// **01/01/2000 10:59**
  String get toLocalddmmyyyyHHnn {
    return formatDate(toLocal(), [
      dd,
      '/',
      mm,
      '/',
      calendarYearStr,
      ' ',
      HH,
      ':',
      nn,
    ]);
  }

  /// **[yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]**
  ///
  /// **2000-01-01 10:59:59**
  String get toLocalyyyymmddHHnnss {
    return formatDate(toLocal(), [
      calendarYearStr,
      '-',
      mm,
      '-',
      dd,
      ' ',
      HH,
      ':',
      nn,
      ':',
      ss,
    ]);
  }

  /// **[HH, ':', nn, ', ', dd, '/', mm, '/', yyyy]**
  ///
  /// **10:59, 01/01/2000**
  String get toLocalHHnnddmmyyWithCommas {
    return formatDate(toLocal(), [
      HH,
      ':',
      nn,
      ', ',
      dd,
      '/',
      mm,
      '/',
      calendarYearStr,
    ]);
  }

  /// **[yyyy, mm, dd, HH, nn, ss]**
  ///
  /// **20001225105959**
  String get toLocalyyyymmddHHnnssWithoutSeparate {
    return formatDate(toLocal(), [calendarYearStr, mm, dd, HH, nn, ss]);
  }

  /// **[dd / mm / yyyy - HH:nn:ss]**
  ///
  /// **20/01/2025 - 09:15:36**
  String get toLocalddmmyyyyHHmmss {
    return formatDate(toLocal(), [
      dd,
      '/',
      mm,
      '/',
      calendarYearStr,
      ' - ',
      HH,
      ':',
      nn,
      ':',
      ss,
    ]);
  }

  String? timeAgo([String? locale]) {
    return tag_format.format(this, locale: locale, allowFromNow: true);
  }

  /// **[HH, ':', nn]**
  ///
  /// **10:59**
  String get toTimeFormat {
    return formatDate(toLocal(), [HH, ':', nn]);
  }

  /// **[HH:nn:ss]**
  ///
  /// **09:15:36**
  String get toLocalHHmmss {
    return formatDate(toLocal(), [HH, ':', nn, ':', ss]);
  }

  /// **[D, ', ', dd, '/', mm, '/', yyyy]**
  ///
  /// **Tue, 01/01/2000**
  String toLocalDddmmyyyy({DateLocale locale = const EnglishDateLocale()}) {
    return formatDate(toLocal(), [
      D,
      ', ',
      dd,
      '/',
      mm,
      '/',
      calendarYearStr,
    ], locale: locale);
  }

  /// **[D, ', ', dd, '/', mm, '/', yyyy]**
  ///
  /// **Tue, 01/01/2000**
  String toLocalddMMyyyy({DateLocale locale = const EnglishDateLocale()}) {
    return formatDate(toLocal(), [
      dd,
      '/',
      MM,
      '/',
      calendarYearStr,
    ], locale: locale);
  }

  /// **[D, '\n', dd]**
  ///
  /// **Tue**
  ///
  /// **01**
  String toLocalDAbovedd({DateLocale locale = const EnglishDateLocale()}) {
    return formatDate(toLocal(), [D, '\n', dd], locale: locale);
  }

  /// **[dd, '/', mm]**
  ///
  /// **14/09**
  String toddmm({DateLocale locale = const EnglishDateLocale()}) {
    return formatDate(toLocal(), [dd, '/', mm], locale: locale);
  }

  String toDateRangeString({
    required DateTime endDate,
    DateLocale locale = const EnglishDateLocale(),
  }) {
    if (year == endDate.year) {
      if (month == endDate.month) {
        if (day == endDate.day) {
          return endDate.toLocalddmmyyyy;
        }
        return '$day - ${endDate.toLocalddmmyyyy}';
      } else {
        return '${toddmm()} - ${endDate.toLocalddmmyyyy}';
      }
    } else {
      return '$toLocalddmmyyyy - ${endDate.toLocalddmmyyyy}';
    }
  }

  bool get isToday {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tomorrow.day == day &&
        tomorrow.month == month &&
        tomorrow.year == year;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }
}
