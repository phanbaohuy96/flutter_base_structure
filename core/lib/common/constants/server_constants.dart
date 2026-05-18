part of '../constants.dart';

class ServerGender {
  static const String male = 'male';
  static const String female = 'female';
}

class ServerErrorCode {
  static const String invalidToken = 'invalid_token';
  static const String userNotFound = 'user_not_found';
}

enum OrderBy {
  desc('desc'),
  descNullsLast('desc_nulls_last'),
  asc('asc'),
  ascNullsFirst('asc_nulls_first'),
  ;

  const OrderBy(this.orderBy);

  final String orderBy;
}
