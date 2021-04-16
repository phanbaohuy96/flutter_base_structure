part of '../utils.dart';

class Debouncer<T> {
  final Duration duration;
  final void Function(T? value) onValue;

  Debouncer(this.duration, this.onValue);

  T? _value;
  Timer? _timer;

  T? get value => _value;

  set value(T? val) {
    _value = val;
    _timer?.cancel();
    _timer = Timer(duration, () => onValue(_value));
  }
}
