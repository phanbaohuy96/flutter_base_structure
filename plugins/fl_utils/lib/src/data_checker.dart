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
      // Dart issue: https://github.com/dart-lang/sdk/issues/46373
      if (tType == 'DateTime') {
        if (value is String) {
          return DateTime.tryParse(value)?.toLocal() as T?;
        }

        if (value is num) {
          return DateTime.fromMillisecondsSinceEpoch((value * 1000).toInt())
              as T?;
        }
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

T? asDateOrNull<T>(dynamic value, [T? defaultValue]) {
  if (value is T) {
    return value;
  }
  if (value != null) {
    try {
      if (value is String) {
        return DateTime.tryParse(value)?.toLocal() as T?;
      }

      if (value is num) {
        return DateTime.fromMillisecondsSinceEpoch((value * 1000).toInt())
            as T?;
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

Object? readAsMapOrNull(Map p1, String p2) {
  if (p1[p2] is Map) {
    return p1[p2];
  }
  return null;
}

String? parseDuration(Duration? duration) {
  return duration?.hhmmss;
}
