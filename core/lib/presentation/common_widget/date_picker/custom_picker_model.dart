import 'dart:math';

import '../../../common/utils.dart';
import 'flutter_datetime_picker/flutter_datetime_picker.dart';
import 'flutter_datetime_picker/src/date_format.dart';

class DateDDMMYYYModel extends CommonPickerModel {
  late DateTime maxTime;
  late DateTime minTime;

  DateDDMMYYYModel({
    DateTime? currentTime,
    DateTime? maxTime,
    DateTime? minTime,
    LocaleType? locale,
  }) : super(locale: locale) {
    this.maxTime = maxTime ?? DateTime(2099, 12, 31);
    this.minTime = minTime ?? DateTime(1900, 1, 1);

    currentTime = currentTime ?? DateTime.now();
    if (currentTime.compareTo(this.maxTime) > 0) {
      currentTime = this.maxTime;
    } else if (currentTime.compareTo(this.minTime) < 0) {
      currentTime = this.minTime;
    }
    this.currentTime = currentTime;

    _fillLeftLists();
    _fillMiddleLists();
    _fillRightLists();
    final minMonth = _minMonthOfCurrentYear();
    final minDay = _minDayOfCurrentMonth();
    setLeftIndex(this.currentTime.day - minDay);
    setMiddleIndex(this.currentTime.month - minMonth);
    setRightIndex(this.currentTime.year - this.minTime.year);
  }

  void _fillLeftLists() {
    final maxDay = _maxDayOfCurrentMonth();
    final minDay = _minDayOfCurrentMonth();
    leftList = List.generate(maxDay - minDay + 1, (int index) {
      return '${minDay + index}${_localeDay()}';
    });
  }

  int _maxMonthOfCurrentYear() {
    return currentTime.year == maxTime.year ? maxTime.month : 12;
  }

  int _minMonthOfCurrentYear() {
    return currentTime.year == minTime.year ? minTime.month : 1;
  }

  int _maxDayOfCurrentMonth() {
    final dayCount = _calcDateCount(currentTime.year, currentTime.month);
    return currentTime.year == maxTime.year &&
            currentTime.month == maxTime.month
        ? maxTime.day
        : dayCount;
  }

  int _minDayOfCurrentMonth() {
    return currentTime.year == minTime.year &&
            currentTime.month == minTime.month
        ? minTime.day
        : 1;
  }

  void _fillMiddleLists() {
    final minMonth = _minMonthOfCurrentYear();
    final maxMonth = _maxMonthOfCurrentYear();

    middleList = List.generate(maxMonth - minMonth + 1, (int index) {
      return '${_localeMonth(minMonth + index)}';
    });
  }

  void _fillRightLists() {
    rightList = List.generate(maxTime.year - minTime.year + 1, (int index) {
      // print('LEFT LIST... ${minTime.year + index}${_localeYear()}');
      return '${minTime.year + index}${_localeYear()}';
    });
  }

  @override
  void setLeftIndex(int index) {
    super.setLeftIndex(index);
    final minDay = _minDayOfCurrentMonth();
    currentTime = currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            currentTime.month,
            minDay + index,
          )
        : DateTime(
            currentTime.year,
            currentTime.month,
            minDay + index,
          );
  }

  @override
  void setMiddleIndex(int index) {
    super.setMiddleIndex(index);
    //adjust right
    final minMonth = _minMonthOfCurrentYear();
    final destMonth = minMonth + index;
    DateTime newTime;
    //change date time
    final dayCount = _calcDateCount(currentTime.year, destMonth);
    newTime = currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            destMonth,
            currentTime.day <= dayCount ? currentTime.day : dayCount,
          )
        : DateTime(
            currentTime.year,
            destMonth,
            currentTime.day <= dayCount ? currentTime.day : dayCount,
          );
    //min/max check
    if (newTime.isAfter(maxTime)) {
      currentTime = maxTime;
    } else if (newTime.isBefore(minTime)) {
      currentTime = minTime;
    } else {
      currentTime = newTime;
    }

    _fillLeftLists();
    // _fillRightLists();
    final minDay = _minDayOfCurrentMonth();
    setLeftIndex(currentTime.day - minDay);
    // _currentRightIndex = currentTime.day - minDay;
  }

  @override
  void setRightIndex(int index) {
    super.setRightIndex(index);
    //adjust middle
    final destYear = index + minTime.year;
    DateTime newTime;
    //change date time
    if (currentTime.month == 2 && currentTime.day == 29) {
      newTime = currentTime.isUtc
          ? DateTime.utc(
              destYear,
              currentTime.month,
              _calcDateCount(destYear, 2),
            )
          : DateTime(
              destYear,
              currentTime.month,
              _calcDateCount(destYear, 2),
            );
    } else {
      newTime = currentTime.isUtc
          ? DateTime.utc(
              destYear,
              currentTime.month,
              currentTime.day,
            )
          : DateTime(
              destYear,
              currentTime.month,
              currentTime.day,
            );
    }
    //min/max check
    if (newTime.isAfter(maxTime)) {
      currentTime = maxTime;
    } else if (newTime.isBefore(minTime)) {
      currentTime = minTime;
    } else {
      currentTime = newTime;
    }

    _fillMiddleLists();
    _fillLeftLists();
    // _fillRightLists();
    final minMonth = _minMonthOfCurrentYear();
    final minDay = _minDayOfCurrentMonth();
    setMiddleIndex(currentTime.month - minMonth);
    setLeftIndex(currentTime.day - minDay);
    // _currentMiddleIndex = currentTime.month - minMonth;
    // _currentRightIndex = currentTime.day - minDay;
  }

  @override
  String? leftStringAtIndex(int index) {
    if (index >= 0 && index < leftList.length) {
      return leftList[index];
    } else {
      return null;
    }
  }

  @override
  String? middleStringAtIndex(int index) {
    if (index >= 0 && index < middleList.length) {
      return middleList[index];
    } else {
      return null;
    }
  }

  @override
  String? rightStringAtIndex(int index) {
    if (index >= 0 && index < rightList.length) {
      return rightList[index];
    } else {
      return null;
    }
  }

  String _localeYear() {
    if (locale == LocaleType.zh) {
      return '年';
    } else if (locale == LocaleType.ko) {
      return '년';
    } else {
      return '';
    }
  }

  String _localeMonth(int month) {
    if (locale == LocaleType.zh) {
      return '$month月';
    } else if (locale == LocaleType.ko) {
      return '$month월';
    } else {
      final monthStrings = i18nObjInLocale(locale)['monthLong'] as List;
      return monthStrings[month - 1];
    }
  }

  String _localeDay() {
    if (locale == LocaleType.zh) {
      return '日';
    } else if (locale == LocaleType.ko) {
      return '일';
    } else {
      return '';
    }
  }

  @override
  DateTime finalTime() {
    return currentTime;
  }
}

List<int> _leapYearMonths = const <int>[1, 3, 5, 7, 8, 10, 12];

int _calcDateCount(int year, int month) {
  if (_leapYearMonths.contains(month)) {
    return 31;
  } else if (month == 2) {
    if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
      return 29;
    }
    return 28;
  }
  return 30;
}

class DateMMYYYModel extends CommonPickerModel {
  late DateTime maxTime;
  late DateTime minTime;

  DateMMYYYModel({
    DateTime? currentTime,
    DateTime? maxTime,
    DateTime? minTime,
    LocaleType? locale,
  }) : super(locale: locale) {
    this.maxTime = maxTime ?? DateTime(2099, 12, 31);
    this.minTime = minTime ?? DateTime(1900, 1, 1);

    currentTime = currentTime ?? DateTime.now();
    if (currentTime.compareTo(this.maxTime) > 0) {
      currentTime = this.maxTime;
    } else if (currentTime.compareTo(this.minTime) < 0) {
      currentTime = this.minTime;
    }
    this.currentTime = currentTime;

    _fillLeftLists();
    _fillMiddleLists();
    _fillRightLists();
    final minMonth = _minMonthOfCurrentYear();
    final minDay = _minDayOfCurrentMonth();
    setLeftIndex(this.currentTime.day - minDay);
    setMiddleIndex(this.currentTime.month - minMonth);
    setRightIndex(this.currentTime.year - this.minTime.year);
  }

  void _fillLeftLists() {
    final maxDay = _maxDayOfCurrentMonth();
    final minDay = _minDayOfCurrentMonth();
    leftList = List.generate(maxDay - minDay + 1, (int index) {
      return '${minDay + index}${_localeDay()}';
    });
  }

  int _maxMonthOfCurrentYear() {
    return currentTime.year == maxTime.year ? maxTime.month : 12;
  }

  int _minMonthOfCurrentYear() {
    return currentTime.year == minTime.year ? minTime.month : 1;
  }

  int _maxDayOfCurrentMonth() {
    final dayCount = _calcDateCount(currentTime.year, currentTime.month);
    return currentTime.year == maxTime.year &&
            currentTime.month == maxTime.month
        ? maxTime.day
        : dayCount;
  }

  int _minDayOfCurrentMonth() {
    return currentTime.year == minTime.year &&
            currentTime.month == minTime.month
        ? minTime.day
        : 1;
  }

  void _fillMiddleLists() {
    final minMonth = _minMonthOfCurrentYear();
    final maxMonth = _maxMonthOfCurrentYear();

    middleList = List.generate(maxMonth - minMonth + 1, (int index) {
      return '${_localeMonth(minMonth + index)}';
    });
  }

  void _fillRightLists() {
    rightList = List.generate(maxTime.year - minTime.year + 1, (int index) {
      // print('LEFT LIST... ${minTime.year + index}${_localeYear()}');
      return '${minTime.year + index}${_localeYear()}';
    });
  }

  @override
  void setLeftIndex(int index) {
    super.setLeftIndex(index);
    final minDay = _minDayOfCurrentMonth();
    currentTime = currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            currentTime.month,
            minDay + index,
          )
        : DateTime(
            currentTime.year,
            currentTime.month,
            minDay + index,
          );
  }

  @override
  void setMiddleIndex(int index) {
    super.setMiddleIndex(index);
    //adjust right
    final minMonth = _minMonthOfCurrentYear();
    final destMonth = minMonth + index;
    DateTime newTime;
    //change date time
    final dayCount = _calcDateCount(currentTime.year, destMonth);
    newTime = currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            destMonth,
            currentTime.day <= dayCount ? currentTime.day : dayCount,
          )
        : DateTime(
            currentTime.year,
            destMonth,
            currentTime.day <= dayCount ? currentTime.day : dayCount,
          );
    //min/max check
    if (newTime.isAfter(maxTime)) {
      currentTime = maxTime;
    } else if (newTime.isBefore(minTime)) {
      currentTime = minTime;
    } else {
      currentTime = newTime;
    }

    _fillLeftLists();
    // _fillRightLists();
    final minDay = _minDayOfCurrentMonth();
    setLeftIndex(currentTime.day - minDay);
    // _currentRightIndex = currentTime.day - minDay;
  }

  @override
  List<int> layoutProportions() {
    return [0, 1, 1];
  }

  @override
  void setRightIndex(int index) {
    super.setRightIndex(index);
    //adjust middle
    final destYear = index + minTime.year;
    DateTime newTime;
    //change date time
    if (currentTime.month == 2 && currentTime.day == 29) {
      newTime = currentTime.isUtc
          ? DateTime.utc(
              destYear,
              currentTime.month,
              _calcDateCount(destYear, 2),
            )
          : DateTime(
              destYear,
              currentTime.month,
              _calcDateCount(destYear, 2),
            );
    } else {
      newTime = currentTime.isUtc
          ? DateTime.utc(
              destYear,
              currentTime.month,
              currentTime.day,
            )
          : DateTime(
              destYear,
              currentTime.month,
              currentTime.day,
            );
    }
    //min/max check
    if (newTime.isAfter(maxTime)) {
      currentTime = maxTime;
    } else if (newTime.isBefore(minTime)) {
      currentTime = minTime;
    } else {
      currentTime = newTime;
    }

    _fillMiddleLists();
    _fillLeftLists();
    // _fillRightLists();
    final minMonth = _minMonthOfCurrentYear();
    final minDay = _minDayOfCurrentMonth();
    setMiddleIndex(currentTime.month - minMonth);
    setLeftIndex(currentTime.day - minDay);
    // _currentMiddleIndex = currentTime.month - minMonth;
    // _currentRightIndex = currentTime.day - minDay;
  }

  @override
  String? leftStringAtIndex(int index) {
    if (index >= 0 && index < leftList.length) {
      return leftList[index];
    } else {
      return null;
    }
  }

  @override
  String? middleStringAtIndex(int index) {
    if (index >= 0 && index < middleList.length) {
      return middleList[index];
    } else {
      return null;
    }
  }

  @override
  String? rightStringAtIndex(int index) {
    if (index >= 0 && index < rightList.length) {
      return rightList[index];
    } else {
      return null;
    }
  }

  String _localeYear() {
    if (locale == LocaleType.zh) {
      return '年';
    } else if (locale == LocaleType.ko) {
      return '년';
    } else {
      return '';
    }
  }

  String _localeMonth(int month) {
    if (locale == LocaleType.zh) {
      return '$month月';
    } else if (locale == LocaleType.ko) {
      return '$month월';
    } else {
      final monthStrings = i18nObjInLocale(locale)['monthLong'] as List;
      return monthStrings[month - 1];
    }
  }

  String _localeDay() {
    if (locale == LocaleType.zh) {
      return '日';
    } else if (locale == LocaleType.ko) {
      return '일';
    } else {
      return '';
    }
  }

  @override
  DateTime finalTime() {
    return currentTime;
  }
}

class MyTimePickerModel extends CommonPickerModel {
  bool showSecondsColumn;
  final DateTime? minTime;
  final DateTime? maxTime;

  Duration get minD =>
      minTime?.let(
        (it) => Duration(
          hours: it.hour,
          minutes: it.minute,
          seconds: it.second,
        ),
      ) ??
      Duration.zero;

  Duration get maxD =>
      maxTime?.let(
        (it) => Duration(
          hours: it.hour,
          minutes: it.minute,
          seconds: it.second,
        ),
      ) ??
      const Duration(hours: 23, minutes: 59, seconds: 59);
  int get minInSec => minD.inSeconds;
  int get maxInSec => maxD.inSeconds;

  MyTimePickerModel({
    DateTime? currentTime,
    LocaleType? locale,
    this.showSecondsColumn = true,
    this.minTime,
    this.maxTime,
  }) : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();

    final initialInSec = Duration(
      hours: this.currentTime.hour,
      minutes: this.currentTime.minute,
      seconds: this.currentTime.second,
    ).inSeconds;

    if (initialInSec < minInSec) {
      this.currentTime = this.currentTime.startOfDay.add(minD);
    } else if (initialInSec > maxInSec) {
      this.currentTime = this.currentTime.startOfDay.add(maxD);
    }

    setLeftIndex(this.currentTime.hour);
    setMiddleIndex(this.currentTime.minute);
    setRightIndex(this.currentTime.second);
  }

  Duration get currentDuration => Duration(
        hours: currentLeftIndex(),
        minutes: currentMiddleIndex(),
        seconds: currentRightIndex(),
      );

  @override
  String? leftStringAtIndex(int index) {
    final leftInSec = Duration(
      hours: min(24, max(index, 0)),
      minutes: currentMiddleIndex(),
      seconds: currentRightIndex(),
    ).inSeconds;

    if (index >= 0 &&
        index < 24 &&
        leftInSec >= minInSec &&
        leftInSec <= maxInSec) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String? middleStringAtIndex(int index) {
    final middleInSec = Duration(
      hours: currentLeftIndex(),
      minutes: min(60, max(index, 0)),
      seconds: currentRightIndex(),
    ).inSeconds;
    if (index >= 0 &&
        index < 60 &&
        middleInSec >= minInSec &&
        middleInSec <= maxInSec) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String? rightStringAtIndex(int index) {
    final rightInSec = Duration(
      hours: currentLeftIndex(),
      minutes: currentMiddleIndex(),
      seconds: min(60, max(index, 0)),
    ).inSeconds;
    if (index >= 0 &&
        index < 60 &&
        rightInSec >= minInSec &&
        rightInSec <= maxInSec) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String leftDivider() {
    return ':';
  }

  @override
  String rightDivider() {
    if (showSecondsColumn) {
      return ':';
    } else {
      return '';
    }
  }

  @override
  List<int> layoutProportions() {
    if (showSecondsColumn) {
      return [1, 1, 1];
    } else {
      return [1, 1, 0];
    }
  }

  @override
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            currentLeftIndex(),
            currentMiddleIndex(),
            currentRightIndex(),
          )
        : DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            currentLeftIndex(),
            currentMiddleIndex(),
            currentRightIndex(),
          );
  }
}
