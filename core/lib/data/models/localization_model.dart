import 'package:json_annotation/json_annotation.dart';

import '../../common/constants/locale/app_locale.dart';
import '../../common/utils.dart';

part 'localization_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LocalizationModel {
  @JsonKey(name: 'th')
  final String? th;
  @JsonKey(name: 'en')
  final String? en;

  const LocalizationModel({
    this.th,
    this.en,
  });

  String? localized(String languageCode) {
    if (languageCode == AppLocale.th.languageCode) {
      return th;
    }
    if (languageCode == AppLocale.en.languageCode) {
      return en;
    }
    return null;
  }

  factory LocalizationModel.fromValue({
    required String value,
  }) {
    return LocalizationModel(
      th: value,
      en: value,
    );
  }

  factory LocalizationModel.fromJson(Map<String, dynamic> json) =>
      _$LocalizationModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocalizationModelToJson(this);

  bool isLike(String text) {
    final keywords = text.removeDiacritic.toLowerCase();
    return (th?.toLowerCase().removeDiacritic.contains(keywords) ?? false) ||
        (en?.toLowerCase().removeDiacritic.contains(keywords) ?? false);
  }
}
