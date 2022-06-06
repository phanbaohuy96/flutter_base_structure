class ClientInfo {
  static String model = '';
  static String osversion = '';
  static String appVersionName = '1.0.0';
  static String appVersionCode = '1';
  static String get appVersion => '$appVersionName($appVersionCode)';
  static String? identifier;
  static String languageCode = '';
}
