import 'package:flutter/foundation.dart';

import 'extensions.dart';

T? asOrNull<T>(dynamic value, [T? defaultValue]) {
  if (value is T) {
    return value;
  }
  if (value != null) {
    try {
      final tType = T.toString();
      if (tType == 'List<String>') {
        return value.cast<String>();
      }
      if (tType == 'List<double>') {
        return value.cast<double>();
      }
      if (tType == 'List<int>') {
        return value.cast<int>();
      }
      if (tType == 'String' && value is String) {
        return value as T;
      }
      if (tType == 'DateTime' && value is String) {
        return DateTime.tryParse(value)?.toLocal() as T?;
      }
      if (value is num) {
        if (tType == 'double') {
          return value.toDouble() as T;
        }
        if (tType == 'int') {
          return value.toInt() as T;
        }
      }
      if (tType == 'Duration' && value is String) {
        return value.parseDuration() as T;
      }
      if (tType == 'Color' && value is String) {
        return ColorExt.fromHex(value) as T;
      }
    } catch (e, stackTrace) {
      debugPrint('asOrNullTest: $e $stackTrace');
      if (kDebugMode) {
        rethrow;
      }
    }
  }
  return defaultValue;
}

String? parseDuration(Duration? duration) {
  return duration?.hhmmss;
}
