import 'package:fl_utils/fl_utils.dart';

extension NumberExtensions on num? {
  /// Format large numbers (e.g. 1.2K, 15K).
  /// < 1,000 → show full number (eg. 532)
  /// ≥ 1,000 and < 1,000,000 → format as K (eg. 1,200 → 1.2K OR 15,000 → 15K)
  /// ≥ 1,000,000 → format as M (eg. 1,200,000 → 1.2M)
  /// Round to 1 decimal only when needed (eg. 1,050 → 1.1K)
  /// and remove trailing .0 (eg. 2.0K → 2K)
  String get compactString {
    if (this == null || this == 0) {
      return '0';
    }

    final number = this!;
    if (number < 1000) {
      return number.toInt().toString();
    } else if (number < 1000000) {
      final divided = number / 1000.0;
      // Truncate to 1 decimal place (not round)
      final truncated = (divided * 10).truncate() / 10;
      // Format and remove trailing .0
      final formatted = truncated.toStringAsMaxFixed(1);
      return '''${formatted}K''';
    } else {
      final divided = number / 1000000.0;
      // Truncate to 1 decimal place (not round)
      final truncated = (divided * 10).truncate() / 10;
      // Format and remove trailing .0
      final formatted = truncated.toStringAsMaxFixed(1);
      return '''${formatted}M''';
    }
  }
}
