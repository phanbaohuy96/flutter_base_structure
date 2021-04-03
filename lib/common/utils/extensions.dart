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
}
