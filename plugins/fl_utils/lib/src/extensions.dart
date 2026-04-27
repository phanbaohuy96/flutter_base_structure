import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'number_format_utils.dart';
import 'phone_number_utils.dart';

extension ExtendedIterable<E> on Iterable<E> {
  /// Like Iterable<T>.map but callback have index as second argument
  Iterable<T> mapIndex<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }

  void forEachIndex(void Function(E e, int i) f) {
    var i = 0;
    forEach((e) => f(e, i++));
  }

  List<E> insertSeparator(E Function(int index) creator) {
    return fold<List<E>>([], (previousValue, element) {
      if (previousValue.isEmpty) {
        return [element];
      }
      return [
        ...previousValue,
        ...[creator(previousValue.length), element],
      ];
    });
  }

  List<E> addOrUpdate(E element, bool Function(E element) test) {
    if (any(test)) {
      return [
        ...map((e) {
          if (test(e)) {
            return element;
          }
          return e;
        }),
      ];
    } else {
      return [...this, element];
    }
  }
}

extension NullableStringIsNullOrEmptyExtension on String? {
  /// Returns `true` if the String is either null or empty.
  bool get isNullOrEmpty => this?.isEmpty ?? true;

  String? get trimOrNull => this?.trim();
}

extension CoreNullableStringExtension on String? {
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  String? obfuscated([int show = 3, String charactor = '*']) {
    if (this == null) {
      return null;
    }
    if (this!.length <= show) {
      return this;
    }
    return charactor * (this!.length - show) +
        this!.substring(this!.length - show);
  }

  String? obfuscatePhoneNumber({
    int show = 3,
    String charactor = '*',
    RegExp? regex,
    String Function(String)? to,
  }) {
    if (this == null) {
      return null;
    }

    final phoneNumberRegex = regex ?? RegExp(r'\d{10}');

    return this!.replaceAllMapped(phoneNumberRegex, (match) {
      if (match.group(0) == null) {
        return '';
      }
      return to?.call(match.group(0)!) ??
          '${match.group(0).obfuscated(show, charactor)}';
    });
  }
}

extension StringExt on String {
  String displayNationalNumber([IsoCode code = IsoCode.VN]) {
    return PhoneNumberUtils.parse(this, code)?.nationalNumber ?? '';
  }

  bool validPhoneNumber([IsoCode code = IsoCode.VN]) {
    return PhoneNumberUtils.parse(this, code) != null;
  }

  bool isValidPhoneNumber() {
    if (isNullOrEmpty) {
      return false;
    }

    const pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(this)) {
      return false;
    }
    return true;
  }

  bool isEmail() {
    return RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(this);
  }

  bool get isValidPassword {
    final length = this.length;
    final hasLetter = contains(RegExp(r'[a-zA-Z]'));
    final hasNumber = contains(RegExp(r'[0-9]'));
    final isValid = (length >= 8) && hasLetter && hasNumber;
    return isValid;
  }

  bool get isValidStaffPassword {
    final length = this.length;
    final hasLowerCase = contains(RegExp(r'[a-z]'));
    final hasUpperCase = contains(RegExp(r'[A-Z]'));
    final hasSpecialChar = contains(RegExp(r'[.,*?!@#\$&*~]'));
    final isValid =
        (length >= 6) && hasLowerCase && hasUpperCase && hasSpecialChar;
    return isValid;
  }

  bool get isLocalUrl {
    return startsWith('/') ||
        startsWith('file://') ||
        (length > 1 && substring(1).startsWith(':\\'));
  }

  bool get isUrl => Uri.parse(this).isAbsolute;

  Uri get uri => Uri.parse(this);

  String capitalizeFirst() {
    if (isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String capitalizeFirstOfEach() {
    return replaceAllMapped(RegExp(r'[^\s.,;!?":/()\[\]{}|\\]+'), (match) {
      if (match.group(0) == null) {
        return '';
      }
      return '${match.group(0)?.capitalizeFirst()}';
    });
  }

  Duration parseDuration() {
    final duration3Regex = RegExp(r'\d+:\d+:\d+(\.\d+)?');
    final duration2Regex = RegExp(r'\d+:\d+(\.\d+)?');

    var hours = 0;
    var minutes = 0;
    var micros = 0;
    String? formated;
    if (duration3Regex.hasMatch(this)) {
      formated = duration3Regex.firstMatch(this)!.group(0);
    } else if (duration2Regex.hasMatch(this)) {
      formated = duration2Regex.firstMatch(this)!.group(0);
    }
    if (formated.isNullOrEmpty) {
      return Duration.zero;
    }
    final parts = formated!.split(':');
    try {
      if (parts.isNotEmpty) {
        hours = int.parse(parts.first);
      }
      if (parts.length > 1) {
        minutes = int.parse(parts[1]);
      }
      if (parts.length > 2) {
        micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
      }
      return Duration(hours: hours, minutes: minutes, microseconds: micros);
    } catch (_) {
      return Duration.zero;
    }
  }

  /// check if the string is a UUID
  bool get isUUID {
    final uuidRegex = RegExp(
      r'\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89aAbB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}\b',
      caseSensitive: false,
    );

    return uuidRegex.hasMatch(this);
  }
}

extension CoreListExtension<E> on List<E>? {
  E? get firstOrNull {
    if (this?.isNotEmpty == true) {
      return this!.first;
    }
    return null;
  }
}

extension ListExtension<E> on List<E> {
  void addAllUnique(Iterable<E> iterable) {
    for (final element in iterable) {
      if (!contains(element)) {
        add(element);
      }
    }
  }

  bool get validNotNullOrEmpty => every((e) {
    if (e is String) {
      return e.isNotEmpty;
    }
    if (e is Iterable) {
      return e.isNotEmpty;
    }
    return e != null;
  });
}

extension DoubleExt on double? {
  String toStringAsMaxFixed(int fractionDigits) {
    if (this == null) {
      return '--';
    }
    final formatter = NumberFormat('###,###.##')
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = fractionDigits;
    return formatter.format(this);
  }

  String toNumberString() {
    return toString().replaceAll(',', '');
  }

  double toMillion() {
    return (this ?? 0) / 1000000;
  }

  double? toPrecision({int n = 2}) =>
      double.tryParse(this?.toStringAsFixed(n) ?? '');

  double? roundAsFixed(int fractionDigits) {
    final stringValue = toStringAsMaxFixed(fractionDigits);
    return stringValue.doubleNumber;
  }

  bool get isInt {
    if (this == null) {
      return false;
    }
    if (this is int || this == this?.toInt()) {
      return true;
    }
    return false;
  }
}

extension DistanceExt on double? {
  String get metterToKMDisplay {
    if (this == null) {
      return '--';
    }
    return (this! / 1000).toStringAsFixed(1);
  }
}

extension IntFormatter on num? {
  String toFormattedString({String? locale}) {
    final number = this ?? 0;
    final formatter = NumberFormat('#,###', locale);
    return formatter.format(number);
  }
}

extension CurrencyExt on num? {
  String toAppCurrencyString({
    bool isWithSymbol = true,
    String? locale,
    bool withSign = false,
    String symbol = '₫',
    int fractionDigits = 2,
  }) {
    final number = this ?? 0;
    final pattern = '###,###.##${isWithSymbol ? '\u00a4' : ''}';
    final formater =
        NumberFormat.currency(
            locale: locale,
            symbol: isWithSymbol ? symbol : '',
            customPattern: withSign
                ? '''${number > 0 ? '+' : ''}$pattern'''
                : pattern,
          )
          ..maximumFractionDigits = fractionDigits
          ..minimumFractionDigits = 0;
    return formater.format(number);
  }

  String displayMoney() {
    return NumberFormatUtils().displayMoney(this) ?? '--';
  }

  String toAppCurrencyStringWithPrefixSign({
    String? inititalSign,
    bool isWithSymbol = true,
    String? locale,
  }) {
    if (this == null) {
      return '--';
    }
    return NumberFormat.currency(
      locale: locale,
      symbol: isWithSymbol ? 'đ' : '',
      customPattern:
          '''${inititalSign ?? (this! >= 0 ? '+' : '')}#,###${isWithSymbol ? '\u00a4' : ''}''',
    ).format(this ?? 0);
  }
}

extension PhoneNumberExt on String? {
  String displayPhoneNumber([IsoCode code = IsoCode.VN]) {
    if (isNullOrEmpty) {
      return '';
    }
    return PhoneNumberUtils.parse(this!, code)?.national ?? '';
  }

  int? get intNumber {
    return doubleNumber?.toInt();
  }

  double? get doubleNumber {
    return double.tryParse(removeCommaString ?? '');
  }

  String? get removeCommaString {
    return this?.replaceAll(',', '');
  }
}

extension DateOnlyCompare on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isBirthDay(DateTime other) {
    return month == other.month && day == other.day;
  }

  bool isBeforeDate(DateTime other) {
    return !isSameDay(other) && isBefore(other);
  }

  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    bool? isUtc,
  }) {
    return ((isUtc ?? this.isUtc) ? DateTime.utc : DateTime.new)(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
    );
  }

  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  DateTime get middle {
    return DateTime(year, month, day, 12);
  }

  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  DateTime get startThisWeek {
    return subtract(Duration(days: weekday - 1)).startOfDay;
  }

  DateTime get endThisWeek {
    return add(Duration(days: DateTime.daysPerWeek - weekday));
  }

  DateTime get startThisMonth {
    return DateTime(year, month, 1).startOfDay;
  }

  DateTime get endThisMonth {
    return DateTime(year, month + 1, 0).endOfDay;
  }

  DateTime get startPrevWeek {
    return subtract(Duration(days: weekday + 6)).startOfDay;
  }

  DateTime get endPrevWeek {
    return startPrevWeek.add(const Duration(days: 6)).endOfDay;
  }

  DateTime get prevMonth {
    return copyWith(month: month - 1);
  }

  DateTime get startPrevMonth {
    return prevMonth.copyWith(day: 1).startOfDay;
  }

  DateTime get endPrevMonth {
    return startPrevMonth.let(
      (d) => d
          .copyWith(month: d.month + 1)
          .subtract(const Duration(days: 1))
          .endOfDay,
    );
  }

  DateTime get startOfQuarter {
    return DateTime(year, ((month - 1) ~/ 3) * 3 + 1, 1).startOfDay;
  }

  DateTime get endOfQuarter {
    // Add 3 months to the start of the quarter and subtract
    // one day to get the last day of the current quarter
    return startOfQuarter
        .copyWith(month: startOfQuarter.month + 3)
        .subtract(const Duration(days: 1))
        .endOfDay;
  }

  DateTime get startPrevQuarter {
    // Subtract 3 months to get the start of the previous quarter
    var prevQuarterStart = startOfQuarter.copyWith(
      month: startOfQuarter.month - 3,
    );
    if (prevQuarterStart.month <= 0) {
      // Adjust for when subtracting months goes into the previous year
      prevQuarterStart = prevQuarterStart.copyWith(
        year: prevQuarterStart.year - 1,
        month: prevQuarterStart.month + 12,
      );
    }
    return prevQuarterStart.startOfDay;
  }

  DateTime get endPrevQuarter {
    // The end of the previous quarter is the last
    // day before the current quarter
    return startPrevQuarter
        .copyWith(month: startPrevQuarter.month + 3)
        .subtract(const Duration(days: 1))
        .endOfDay;
  }

  DateTime get startOfYear {
    // The start of the year is January 1st
    return DateTime(year, 1, 1).startOfDay;
  }

  DateTime get endOfYear {
    // The end of the year is December 31st at 23:59:59
    return DateTime(year, 12, 31).endOfDay;
  }

  DateTime get startPrevYear => DateTime(year - 1, 1, 1).startOfDay;
  DateTime get endPrevYear => DateTime(year - 1, 12, 31).endOfDay;

  DateTime get startPrev3Days {
    return subtract(const Duration(days: 3));
  }

  DateTime get endPrev3Days {
    return startPrev3Days.add(const Duration(days: 2));
  }

  DateTime get startPrev7Days {
    return subtract(const Duration(days: 7));
  }

  DateTime get endPrev7Days {
    return startPrev7Days.add(const Duration(days: 6));
  }

  DateTime get startPrev30Days {
    return subtract(const Duration(days: 30));
  }

  DateTime get endPrev30Days {
    return startPrev30Days.add(const Duration(days: 30));
  }
}

extension ObjectExt<T> on T {
  R let<R>(R Function(T it) op) => op(this);
}

extension WeightExt on int {
  String formatNumber({String prefix = ''}) {
    const pattern = r'(\d{1,3})(?=(\d{3})+(?!\d))';
    final regExp = RegExp(pattern);
    final mathFunc = (Match match) => '${match[1]},';
    return '${toString().replaceAllMapped(regExp, mathFunc)}$prefix';
  }
}

extension DurationExt on Duration {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String get hhmm {
    final twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    return '${twoDigits(inHours)}:$twoDigitMinutes';
  }

  String get hhmmss {
    return toString().split('.').first.padLeft(8, '0');
  }
}

extension FileSize on int? {
  double get bytesToGB {
    return (this ?? 0) / 1073741824;
  }

  double get bytesToMb {
    return (this ?? 0) / 1048576;
  }

  double get bytesToKb {
    return (this ?? 0) / 1024;
  }
}

extension ColorExt on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an
  /// optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true`
  /// (default is `true`).
  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${a.round().toRadixString(16).padLeft(2, '0')}'
      '${r.round().toRadixString(16).padLeft(2, '0')}'
      '${g.round().toRadixString(16).padLeft(2, '0')}'
      '${b.round().toRadixString(16).padLeft(2, '0')}';
}

String? colorToHex(Color? color) => color?.toHex();
