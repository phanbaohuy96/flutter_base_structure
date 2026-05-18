import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get inform => 'Inform';

  @override
  String get ok => 'Ok';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get skip => 'Skip';

  @override
  String get close => 'Close';

  @override
  String get loginRequired => 'Please login to continue';

  @override
  String get login => 'Login';

  @override
  String get userRole => 'User role';

  @override
  String get poweredByVNS => 'Powered by VNS';

  @override
  String get pleaseSelectARoleBeforeLoginMsg =>
      'Please select a role before logging in.';

  @override
  String get thisRoleIsNotSupportedYet => 'This role is not supported yet.';

  @override
  String get loginFailed => 'Failed to fetch user info';
}
