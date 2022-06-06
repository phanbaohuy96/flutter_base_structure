part of '../constants.dart';

class ServerGender {
  static const String male = 'Male';
  static const String female = 'Female';
  static const String other = 'Other';
}

class ServerScanStatus {
  static const String scanSuccess = 'scan-success';
  static const String scanFailed = 'scan-failed';
}

class ServerNotification {
  static const String manualType = 'manual';
  static const String newsType = 'news';
}

class ServerNotificationManual {
  static const String point = 'point';
  static const String reminder = 'reminder';
  static const String scan = 'scan';
  static const String upgrade = 'upgrade';
}

class ServerErrorCode {
  static const String invalidToken = 'invalid_token';
  static const String userNotFound = 'user_not_found';
}

class SystemRole {
  static const String daikinDealerID = 'f55d5990-bea4-4331-9d58-6e223e58f54a';
  static const String subDealerID = '472cc1cc-a082-4c99-82e3-e58ab27248c3';
  static const String daikinDealerAlias = 'daikin_dealer';
  static const String subDealerAlias = 'sub_dealer';
  static const String freelancerAlias = 'freelancer';
  static const String guestAlias = 'guest';
}

class UpgradeStatus {
  static const String done = 'done';
  static const String requesting = 'requesting';
  static const String approve = 'approve';
  static const String rejected = 'rejected';
  static const String pending = 'pending';
}

class PointStatus {
  static const String earn = 'earn';
  static const String redeem = 'redeem';
  static const String expired = 'expired';
}

class Status {
  static const String active = 'active';
}

class PointType {
  static const String point = 'point';
  static const String money = 'money';
}

class RewardType {
  static const String static = 'static';
  static const String dynamic = 'dynamic';
}

class ScanProductMode {
  static const String qrCode = 'qrCode';
  static const String barCode = 'barCode';
  static const String all = 'all';
}
