import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/widgets.dart';

import '../common_widget/unsupported_page.dart';

export 'package:fl_navigation/fl_navigation.dart';

/// Builds a route widget only when [extra] matches the required type.
Widget buildRequiredRouteExtra<T>(
  Object? extra,
  Widget Function(T extra) builder,
) {
  final value = asOrNull<T>(extra);
  if (value == null) {
    return const UnsupportedPage();
  }
  return builder(value);
}
