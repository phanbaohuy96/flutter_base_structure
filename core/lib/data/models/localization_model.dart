import 'package:json_annotation/json_annotation.dart';

import '../../common/constants/locale/app_locale.dart';

part 'localization_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LocalizationModel {
  @JsonKey(name: 'th')
  String? th;
  @JsonKey(name: 'en')
  String? en;

  LocalizationModel({
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
}
