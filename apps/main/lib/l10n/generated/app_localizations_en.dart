// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get poweredByApp => 'Powered by My Flutter Base';

  @override
  String get pleaseSelectARoleBeforeLoginMsg =>
      'Please select a role before logging in.';

  @override
  String get backToHomepage => 'Back to Homepage';

  @override
  String get pageNotFound => '404 - Page Not Found';

  @override
  String get back => 'Back';

  @override
  String get loginFailed => 'Failed to fetch user info';

  @override
  String get thisRoleIsNotSupportedYet => 'This role is not supported yet.';
}
