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
