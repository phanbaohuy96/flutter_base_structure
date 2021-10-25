part of '../utils.dart';

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

extension PhoneNumberStringExt on String {
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

  bool validVNPhoneNumber() {
    final format = formatVNPhoneNumber();
    return format.length == 12 || format.length == 13;
  }

  bool isEmail() {
    return RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(this);
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
