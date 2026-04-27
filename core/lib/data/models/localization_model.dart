import 'package:json_annotation/json_annotation.dart';

import '../../common/constants/locale/app_locale.dart';
import '../../common/utils.dart';

part 'localization_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LocalizationModel {
  @JsonKey(name: 'vi')
  final String? vi;
  @JsonKey(name: 'en')
  final String? en;

  const LocalizationModel({this.vi, this.en});

  String? localized(String languageCode) {
    if (languageCode == AppLocale.vi.languageCode) {
      return vi;
    }
    if (languageCode == AppLocale.en.languageCode) {
      return en;
    }
    return null;
  }

  factory LocalizationModel.fromValue({required String value}) {
    return LocalizationModel(vi: value, en: value);
  }

  factory LocalizationModel.fromJson(Map<String, dynamic> json) =>
      _$LocalizationModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocalizationModelToJson(this);

  bool isLike(String text) {
    final keywords = text.removeDiacritic.toLowerCase();
    return (vi?.toLowerCase().removeDiacritic.contains(keywords) ?? false) ||
        (en?.toLowerCase().removeDiacritic.contains(keywords) ?? false);
  }
}
