import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../fl_utils.dart';

class CommonFunction {
  void hideKeyBoard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  String prettyJsonStr(Map<dynamic, dynamic> json) {
    final encoder = JsonEncoder.withIndent('  ', (data) => data.toString());
    return encoder.convert(json);
  }

  List<DateTime> getRangeFromStartEnd({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final range = <DateTime>[];
    final numberOfDays = endDate.difference(startDate).inDays;
    for (var i = 0; i <= numberOfDays; i++) {
      range.add(startDate.add(Duration(days: i)).startOfDay);
    }
    return range;
  }

  int calculateAge(DateTime birthDate) {
    final currentDate = DateTime.now();
    var age = currentDate.year - birthDate.year;
    final month1 = currentDate.month;
    final month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      final day1 = currentDate.day;
      final day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  bool shouldUpdateApp(String currentVersion, String newVersion) {
    if (newVersion.isEmpty) {
      return false;
    }
    return _compareVersionNames(currentVersion, newVersion) < 0;
  }

  bool compare(String currentVersion, String newVersion) {
    if (newVersion.isEmpty) {
      return false;
    }
    return _compareVersionNames(currentVersion, newVersion) == 0;
  }

  int compareVersionNames(
    String oldVersionName,
    String newVersionName,
  ) =>
      _compareVersionNames(oldVersionName, newVersionName);

  int _compareVersionNames(
    String oldVersionName,
    String newVersionName,
  ) {
    var res = 0;

    final oldNumbers = oldVersionName.split('.');
    final newNumbers = newVersionName.split('.');

    // To avoid IndexOutOfBounds
    final maxIndex = min(oldNumbers.length, newNumbers.length);

    for (final i in List.generate(maxIndex, (index) => index)) {
      final oldVersionPart = int.tryParse(oldNumbers[i]);
      final newVersionPart = int.tryParse(newNumbers[i]);

      if (newVersionPart == null || oldVersionPart == null) {
        break;
      }

      if (oldVersionPart < newVersionPart) {
        res = -1;
        break;
      } else if (oldVersionPart > newVersionPart) {
        res = 1;
        break;
      }
    }

    // If versions are the same so far, but they have different length...
    if (res == 0 && oldNumbers.length != newNumbers.length) {
      res = oldNumbers.length > newNumbers.length ? 1 : -1;
    }
    return res;
  }

  String randomString(int length) {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final _rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(
          _rnd.nextInt(_chars.length),
        ),
      ),
    );
  }
}
