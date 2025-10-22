import 'package:core/data/models/localization_model.dart';

Object? readLocalizationModelValue(Map p1, String p2) {
  final value = p1[p2];
  if (value is Map) {
    return LocalizationModel.fromJson(Map.from(value)).toJson();
  }
  if (value is String) {
    return LocalizationModel.fromValue(value: value).toJson();
  }
  return null;
}
