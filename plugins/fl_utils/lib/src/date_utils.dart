// ignore_for_file: constant_identifier_names

import 'package:date_format/date_format.dart';
import 'package:timeago/timeago.dart' as tag_format;

class DateTimeFormat {
  /// **[HH, ':', nn, ' - ', dd, '/', mm, '/', yyyy]**
  ///
  /// **10:59 - 01/01/2000**
  final HHnnddmmyyyy = [HH, ':', nn, ' - ', dd, '/', mm, '/', yyyy];

  /// **[HH, ':', nn, ' ', dd, '/', mm, '/', yyyy]**
  ///
  /// **01/01/2000 10:59**
  final ddmmyyyyHHnn = [dd, '/', mm, '/', yyyy, ' ', HH, ':', nn];

  /// **[HH, ':', nn]**
  ///
  /// **10:59**
  final timeFormat = [HH, ':', nn];

  /// **[D, ', ', dd, '/', mm, '/', yyyy]**
  ///
  /// **Tue, 01/01/2000**
  final Dddmmyyyy = [D, ', ', dd, '/', mm, '/', yyyy];

  /// **[yyyy, '/', mm, '/', dd]**
  ///
  /// **2000/01/01**
  final yyyymmdd = [yyyy, '/', mm, '/', dd];

  /// **[dd, '/', mm, '/', yyyy]**
  ///
  /// **01/01/2000**
  final ddmmyyyy = [dd, '/', mm, '/', yyyy];

  /// **[yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]**
  ///
  /// **2000-01-01 10:59:59**
  final yyyymmddHHnnss = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss];

  /// **[HH, ':', nn, ', ', dd, '/', mm, '/', yyyy]**
  ///
  /// **10:59, 01/01/2000**
  final HHnnddmmyyWithCommas = [HH, ':', nn, ', ', dd, '/', mm, '/', yyyy];

  /// **[D, '\n', dd]**
  ///
  /// **Tue**
  ///
  /// **01**
  final DAbovedd = [D, '\n', dd];

  /// **[mm, ' ', yyyy]**
  ///
  /// **01 2000**
  final mmSpaceyyyy = [mm, ' ', yyyy];

  /// **[yyyy, mm, dd, HH, nn, ss]**
  ///
  /// **20001225105959**
  final yyyymmddHHnnssWithoutSeparate = [yyyy, mm, dd, HH, nn, ss];

  /// **[dd / mm / yyyy - HH:nn:ss]**
  ///
  /// **20/01/2025 - 09:15:36**
  final ddmmyyyyHHmmss = [dd, '/', mm, '/', yyyy, ' - ', HH, ':', nn, ':', ss];

  /// **[dd, mm]**
  ///
  /// **14 / 12**
  final ddmm = [dd, '/', mm];
}

extension DateUtilsExtention on DateTime {
  String customFormat(
    List<String> format, {
    DateLocale locale = const EnglishDateLocale(),
  }) {
    return formatDate(
      toLocal(),
      format,
      locale: locale,
    );
  }

  /// **[mm, ' ', yyyy]**
  ///
  /// **01 2000**
  String toLocalmmyyyy() {
    return formatDate(
      toLocal(),
      DateTimeFormat().mmSpaceyyyy,
    );
  }

  /// **[dd, '/', mm, '/', yyyy]**
  ///
  /// **01/01/2000**
  String toLocalddmmyyyy() {
    return formatDate(
      toLocal(),
      DateTimeFormat().ddmmyyyy,
    );
  }

  /// **[dd, '/', mm, '/', yyyy]**
  ///
  /// **01/01/2000**
  String toddmmyyyy() {
    return formatDate(
      this,
      DateTimeFormat().ddmmyyyy,
    );
  }

  /// **[HH, ':', nn, ' - ', dd, '/', mm, '/', yyyy]**
  ///
  /// **10:59 - 01/01/2000**
  String toLocalHHnnddmmyyyy() {
    return formatDate(
      toLocal(),
      DateTimeFormat().HHnnddmmyyyy,
    );
  }

  /// **[ dd, '/', mm, '/', yyyy, ' ', HH, ':', nn]**
  ///
  /// **01/01/2000 10:59**
  String toLocalddmmyyyyHHnn() {
    return formatDate(
      toLocal(),
      DateTimeFormat().ddmmyyyyHHnn,
    );
  }

  /// **[HH, ':', nn, ' - ', dd, '/', mm, '/', yyyy]**
  ///
  /// **10:59 - 01/01/2000**
  String toUTCHHnnddmmyyyy() {
    return formatDate(
      toUtc(),
      DateTimeFormat().HHnnddmmyyyy,
    );
  }

  /// **[yyyy, '/', mm, '/', dd]**
  ///
  /// **2000/01/01**
  String toUTCyyyymmdd() {
    return formatDate(
      toUtc(),
      DateTimeFormat().yyyymmdd,
    );
  }

  /// **[yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]**
  ///
  /// **2000-01-01 10:59:59**
  String toUTCyyyymmddHHnnss() {
    return formatDate(
      toUtc(),
      DateTimeFormat().yyyymmddHHnnss,
    );
  }

  /// **[yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]**
  ///
  /// **2000-01-01 10:59:59**
  String toLocalyyyymmddHHnnss() {
    return formatDate(
      toLocal(),
      DateTimeFormat().yyyymmddHHnnss,
    );
  }

  /// **[HH, ':', nn, ', ', dd, '/', mm, '/', yyyy]**
  ///
  /// **10:59, 01/01/2000**
  String toLocalHHnnddmmyyWithCommas() {
    return formatDate(
      toLocal(),
      DateTimeFormat().HHnnddmmyyWithCommas,
    );
  }

  /// **[yyyy, mm, dd, HH, nn, ss]**
  ///
  /// **20001225105959**
  String toLocalyyyymmddHHnnssWithoutSeparate() {
    return formatDate(
      toLocal(),
      DateTimeFormat().yyyymmddHHnnssWithoutSeparate,
    );
  }

  /// **[dd / mm / yyyy - HH:nn:ss]**
  ///
  /// **20/01/2025 - 09:15:36**
  String toLocalddmmyyyyHHmmss() {
    return formatDate(
      toLocal(),
      DateTimeFormat().ddmmyyyyHHmmss,
    );
  }

  String? timeago([String? locale]) {
    return tag_format.format(
      this,
      locale: locale,
      allowFromNow: true,
    );
  }

  /// **[HH, ':', nn]**
  ///
  /// **10:59**
  String toTimeFormat() {
    return formatDate(
      toLocal(),
      DateTimeFormat().timeFormat,
    );
  }

  /// **[D, ', ', dd, '/', mm, '/', yyyy]**
  ///
  /// **Tue, 01/01/2000**
  String toLocalDddmmyyyy({
    DateLocale locale = const EnglishDateLocale(),
  }) {
    return formatDate(
      toLocal(),
      DateTimeFormat().Dddmmyyyy,
      locale: locale,
    );
  }

  /// **[D, '\n', dd]**
  ///
  /// **Tue**
  ///
  /// **01**
  String toLocalDAbovedd({
    DateLocale locale = const EnglishDateLocale(),
  }) {
    return formatDate(
      toLocal(),
      DateTimeFormat().DAbovedd,
      locale: locale,
    );
  }

  /// **[dd, '/', mm]**
  ///
  /// **14/09**
  String toddmm({
    DateLocale locale = const EnglishDateLocale(),
  }) {
    return formatDate(
      toLocal(),
      DateTimeFormat().ddmm,
      locale: locale,
    );
  }

  String toDateRangeString({
    required DateTime endDate,
  }) {
    if (year == endDate.year) {
      if (month == endDate.month) {
        if (day == endDate.day) {
          return endDate.toLocalddmmyyyy();
        }
        return '$day - ${endDate.toLocalddmmyyyy()}';
      } else {
        return '${toddmm()} - ${endDate.toLocalddmmyyyy()}';
      }
    } else {
      return '${toLocalddmmyyyy()} - ${endDate.toLocalddmmyyyy()}';
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

  String get serverFormat => toUtc().toIso8601String();
}
