import 'package:dartx/dartx.dart';
import 'package:intl/intl.dart';

import '../utils.dart';
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
}

extension StringExt on String {
  String formatVNPhoneNumber() {
    if (startsWith('0')) {
      return replaceFirst('0', '+84');
    } else if (startsWith('84')) {
      return '+$this';
    } else if (startsWith('+')) {
      return this;
    } else {
      return '+84$this';
    }
  }

  String displayPhoneNumber() {
    return PhoneNumberUtils.parse(this)?.national ?? '';
  }

  bool validVNPhoneNumber() {
    if (isValidPhoneNumber(this) == false) {
      return false;
    }
    final format = formatVNPhoneNumber();
    return format.length == 12;
  }

  bool isValidPhoneNumber(String? string) {
    if (string == null || string.isEmpty) {
      return false;
    }

    const pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(string)) {
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

  bool get isLocalUrl {
    return startsWith('/') ||
        startsWith('file://') ||
        (length > 1 && substring(1).startsWith(':\\'));
  }

  bool get isUrl => Uri.parse(this).isAbsolute;

  String capitalizeFisrt() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String capitalizeFirstofEach() {
    return split(' ').map((str) => str.capitalizeFisrt()).join(' ');
  }
}

extension ListExtension<E> on List<E>? {
  E? get firstOrNull {
    if (this?.isNotEmpty == true) {
      return this!.first;
    }
    return null;
  }
}

extension DoubleExt on double {
  String toStringAsMaxFixed(int fractionDigits) {
    final formatter = NumberFormat()
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = fractionDigits;
    return formatter.format(this);
  }
}

extension DateTimeConverter on int? {
  String toFullDateTime() {
    if (this == null) {
      return '';
    }
    final dt = DateTime.fromMillisecondsSinceEpoch(this!);
    return dt.serverToNormalFullFormat();
  }

  String toCurrencyString({bool isWithSymbol = true}) {
    return NumberFormat.currency(
      locale: 'Vi',
      symbol: isWithSymbol ? 'đ' : '',
      customPattern: '#,###${isWithSymbol ? ' \u00a4' : ''}',
    ).format(
      this ?? 0,
    );
  }
}

extension DateConverter on String? {
  String toDisplayNormalDate() {
    if (this == null || this?.isEmpty == true) {
      return '';
    }
    final dt = DateTime.parse(this!);
    return dt.serverToNormalDateFormat();
  }
}

extension PhoneNumberExt on String? {
  String displayPhoneNumber() {
    if (isNullOrEmpty) {
      return '';
    }
    return PhoneNumberUtils.parse(this!)?.national ?? '';
  }
}

extension CurrencyExt on double? {
  String displayMoney() {
    return NumberFormatUtils.displayMoney(this) ?? '--';
  }
}
