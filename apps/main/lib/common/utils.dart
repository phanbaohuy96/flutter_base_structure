import 'package:core/core.dart';

Object? dateTimeToTimestamp(DateTime? value) {
  return value?.let((e) => e.toUtc().millisecondsSinceEpoch ~/ 1000);
}
