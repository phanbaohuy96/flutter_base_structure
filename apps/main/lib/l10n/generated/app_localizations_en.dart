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
  String get poweredByApp => 'Powered by My Flutter Base';

  @override
  String get backToHomepage => 'Back to Homepage';

  @override
  String get pageNotFound => '404 - Page Not Found';

  @override
  String get back => 'Back';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get password => 'Password';

  @override
  String get phoneNumberHint => 'Enter your phone number';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get loginFailed => 'Invalid phone or password';
}
