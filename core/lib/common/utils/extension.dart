import 'package:diacritic/diacritic.dart';

extension DiacriticsAwareString on String {
  String get removeDiacritic => removeDiacritics(this);
}

extension DiacriticsAwareNullableStringExtension on String? {
  bool isLike(String other) =>
      this?.toLowerCase().removeDiacritic.contains(other) == true;
}

extension StringHardcode on String {
  String get hardcode => this;
}

/// Extension for formatting file sizes
extension FileSizeExtension on int {
  /// Formats bytes to human-readable string (B, KB, MB, GB)
  String get formatFileSize {
    if (this < 1024) {
      return '$this B';
    }
    if (this < 1024 * 1024) {
      return '${(this / 1024).toStringAsFixed(1)} KB';
    }
    if (this < 1024 * 1024 * 1024) {
      return '${(this / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
