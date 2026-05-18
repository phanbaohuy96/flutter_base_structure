import 'package:flutter/material.dart';

import 'custom_picker_model.dart';
import 'flutter_datetime_picker/flutter_datetime_picker.dart';

Future<DateTime?> showMyCustomDatePicker(
  BuildContext context, {
  DateTime? initialDateTime,
  Function(DateTime?)? onConfirmed,
  Function(DateTime?)? onChanged,
  DateTime? maxDate,
  DateTime? minDate,
}) {
  final languageCode = Localizations.localeOf(context).languageCode;
  final locale = LocaleType.values.firstWhere(
    (element) => element.name == languageCode,
    orElse: () => LocaleType.vi,
  );
  return DatePicker().showPicker(
    context,
    showTitleActions: true,
    onChanged: onChanged,
    onConfirm: onConfirmed,
    locale: locale,
    datePickerTheme: CustomDatePickerTheme(
      theme: Theme.of(context),
    ),
    pickerModel: DateDDMMYYYModel(
      minTime: minDate,
      maxTime: maxDate,
      currentTime: initialDateTime,
      locale: locale,
    ),
  );
}

Future<dynamic> showMyCustomMonthPicker(
  BuildContext context, {
  DateTime? initialDateTime,
  Function(DateTime?)? onConfirmed,
  Function(DateTime?)? onChanged,
  DateTime? maxDate,
  DateTime? minDate,
}) {
  final languageCode = Localizations.localeOf(context).languageCode;
  final locale = LocaleType.values.firstWhere(
    (element) => element.name == languageCode,
    orElse: () => LocaleType.vi,
  );
  return DatePicker().showPicker(
    context,
    showTitleActions: true,
    onChanged: onChanged,
    onConfirm: onConfirmed,
    locale: locale,
    datePickerTheme: CustomDatePickerTheme(
      theme: Theme.of(context),
    ),
    pickerModel: DateMMYYYModel(
      minTime: minDate,
      maxTime: maxDate,
      currentTime: initialDateTime,
      locale: locale,
    ),
  );
}

Future<dynamic> showMyTimePicker(
  BuildContext context, {
  DateTime? initialDateTime,
  Function(DateTime?)? onConfirmed,
  Function(DateTime?)? onChanged,
  DateTime? maxTime,
  DateTime? minTime,
  bool showSecondsColumn = true,
}) {
  final languageCode = Localizations.localeOf(context).languageCode;
  final locale = LocaleType.values.firstWhere(
    (element) => element.name == languageCode,
    orElse: () => LocaleType.vi,
  );
  return DatePicker().showPicker(
    context,
    showTitleActions: true,
    onChanged: onChanged,
    onConfirm: onConfirmed,
    locale: locale,
    datePickerTheme: CustomDatePickerTheme(
      theme: Theme.of(context),
    ),
    pickerModel: MyTimePickerModel(
      showSecondsColumn: showSecondsColumn,
      locale: locale,
      minTime: minTime,
      maxTime: maxTime,
    ),
  );
}
