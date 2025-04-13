import 'package:date_format/date_format.dart' as date_format;

class AppDateLocale extends date_format.DateLocale {
  @override
  final String am;
  @override
  final List<String> daysLong;
  @override
  final List<String> daysShort;
  @override
  final List<String> monthsLong;
  @override
  final List<String> monthsShort;
  @override
  final String pm;

  AppDateLocale({
    required this.am,
    required this.daysLong,
    required this.daysShort,
    required this.monthsLong,
    required this.monthsShort,
    required this.pm,
  });
}

abstract class DateLocale {
  List<String> get monthsShort;

  List<String> get monthsLong;

  List<String> get daysShort;

  List<String> get daysLong;

  String get am;

  String get pm;

  AppDateLocale get toAppDateLocale => AppDateLocale(
        am: am,
        pm: pm,
        daysLong: daysLong,
        daysShort: daysShort,
        monthsLong: monthsLong,
        monthsShort: monthsShort,
      );
}
