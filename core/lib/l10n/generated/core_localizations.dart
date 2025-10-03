import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'core_localizations_en.dart';
import 'core_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CoreLocalizations
/// returned by `CoreLocalizations.of(context)`.
///
/// Applications need to include `CoreLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/core_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CoreLocalizations.localizationsDelegates,
///   supportedLocales: CoreLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the CoreLocalizations.supportedLocales
/// property.
abstract class CoreLocalizations {
  CoreLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CoreLocalizations? of(BuildContext context) {
    return Localizations.of<CoreLocalizations>(context, CoreLocalizations);
  }

  static const LocalizationsDelegate<CoreLocalizations> delegate =
      _CoreLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th')
  ];

  /// No description provided for @inform.
  ///
  /// In en, this message translates to:
  /// **'Inform'**
  String get inform;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'Connection errors.\nPlease check your network connection and try again'**
  String get noInternet;

  /// No description provided for @technicalIssues.
  ///
  /// In en, this message translates to:
  /// **'Oops! .There seems to be a technical problem.\nPlease check your connection or try again later'**
  String get technicalIssues;

  /// No description provided for @requestRestricted.
  ///
  /// In en, this message translates to:
  /// **'Request sent too many times\nPlease wait a moment and try again.'**
  String get requestRestricted;

  /// No description provided for @serverMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Server is unavailable at this time. Please try again later.'**
  String get serverMaintenance;

  /// No description provided for @connectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out.'**
  String get connectionTimeout;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.\nPlease try again later'**
  String get unknownError;

  /// No description provided for @dataParsingError.
  ///
  /// In en, this message translates to:
  /// **'Data parsing error, please try again later'**
  String get dataParsingError;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session is expired. Please log in again!'**
  String get sessionExpired;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @haveNoPermission.
  ///
  /// In en, this message translates to:
  /// **'No access. Please go to settings and grant permission to the app to continue.'**
  String get haveNoPermission;

  /// No description provided for @openSetting.
  ///
  /// In en, this message translates to:
  /// **'Open Setting'**
  String get openSetting;

  /// No description provided for @openInExternalBrowser.
  ///
  /// In en, this message translates to:
  /// **'External Browser'**
  String get openInExternalBrowser;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @featureUnderDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Feature under development'**
  String get featureUnderDevelopment;

  /// No description provided for @requestPermission.
  ///
  /// In en, this message translates to:
  /// **'Request permission'**
  String get requestPermission;

  /// No description provided for @firebaseAuthExceptionTypeAccountExistsWithDifferentCredential.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while signing in.'**
  String get firebaseAuthExceptionTypeAccountExistsWithDifferentCredential;

  /// No description provided for @firebaseAuthExceptionTypeInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while signing in.'**
  String get firebaseAuthExceptionTypeInvalidCredential;

  /// No description provided for @firebaseAuthExceptionTypeOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while signing in.'**
  String get firebaseAuthExceptionTypeOperationNotAllowed;

  /// No description provided for @firebaseAuthExceptionTypeUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'The user associated with this credential has been disabled.'**
  String get firebaseAuthExceptionTypeUserDisabled;

  /// No description provided for @firebaseAuthExceptionTypeUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found. Please check your credentials and try again.'**
  String get firebaseAuthExceptionTypeUserNotFound;

  /// No description provided for @firebaseAuthExceptionTypeInvalidVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code.'**
  String get firebaseAuthExceptionTypeInvalidVerificationCode;

  /// No description provided for @firebaseAuthExceptionTypeInvalidVerificationId.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification ID.'**
  String get firebaseAuthExceptionTypeInvalidVerificationId;

  /// No description provided for @firebaseAuthExceptionTypeWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password. Please check your credentials and try again.'**
  String get firebaseAuthExceptionTypeWrongPassword;

  /// No description provided for @firebaseAuthExceptionTypeUnknown.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while signing in.'**
  String get firebaseAuthExceptionTypeUnknown;

  /// No description provided for @firebaseAuthExceptionSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'The OTP has expired. Please re-send the new OTP to try again.'**
  String get firebaseAuthExceptionSessionExpired;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @weekAgo.
  ///
  /// In en, this message translates to:
  /// **'Week ago'**
  String get weekAgo;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @monthAgo.
  ///
  /// In en, this message translates to:
  /// **'Month ago'**
  String get monthAgo;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get toDate;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @threeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'3 days ago'**
  String get threeDaysAgo;

  /// No description provided for @sevenDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'7 days ago'**
  String get sevenDaysAgo;

  /// No description provided for @thirtyDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'30 days ago'**
  String get thirtyDaysAgo;

  /// No description provided for @thisQuarter.
  ///
  /// In en, this message translates to:
  /// **'This quarter'**
  String get thisQuarter;

  /// No description provided for @quarterAgo.
  ///
  /// In en, this message translates to:
  /// **'Quarter ago'**
  String get quarterAgo;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get thisYear;

  /// No description provided for @yearAgo.
  ///
  /// In en, this message translates to:
  /// **'Year ago'**
  String get yearAgo;

  /// No description provided for @selectTimePeriod.
  ///
  /// In en, this message translates to:
  /// **'Select time period'**
  String get selectTimePeriod;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get viewMore;

  /// No description provided for @seeLess.
  ///
  /// In en, this message translates to:
  /// **'See less'**
  String get seeLess;

  /// No description provided for @fullTime.
  ///
  /// In en, this message translates to:
  /// **'Full time'**
  String get fullTime;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Select photo'**
  String get choosePhoto;

  /// No description provided for @choosePhotoOrVideo.
  ///
  /// In en, this message translates to:
  /// **'Select media'**
  String get choosePhotoOrVideo;

  /// No description provided for @chooseVideo.
  ///
  /// In en, this message translates to:
  /// **'Select video'**
  String get chooseVideo;

  /// No description provided for @pleaseEnableGPS.
  ///
  /// In en, this message translates to:
  /// **'Please enable location to continue the experience'**
  String get pleaseEnableGPS;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @fileSizeOverXMB.
  ///
  /// In en, this message translates to:
  /// **'The file is too large. Maximum allowed size is {x}MB.'**
  String fileSizeOverXMB(Object x);

  /// No description provided for @errorWhenUploading.
  ///
  /// In en, this message translates to:
  /// **'An error occurred when uploading'**
  String get errorWhenUploading;

  /// No description provided for @onlyImageAllowed.
  ///
  /// In en, this message translates to:
  /// **'Only image files are allowed.'**
  String get onlyImageAllowed;

  /// No description provided for @onlyVideoAllowed.
  ///
  /// In en, this message translates to:
  /// **'Only video files are allowed.'**
  String get onlyVideoAllowed;

  /// No description provided for @onlyImageOrVideoAllowed.
  ///
  /// In en, this message translates to:
  /// **'Only image or video files are allowed.'**
  String get onlyImageOrVideoAllowed;
}

class _CoreLocalizationsDelegate
    extends LocalizationsDelegate<CoreLocalizations> {
  const _CoreLocalizationsDelegate();

  @override
  Future<CoreLocalizations> load(Locale locale) {
    return SynchronousFuture<CoreLocalizations>(
        lookupCoreLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_CoreLocalizationsDelegate old) => false;
}

CoreLocalizations lookupCoreLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return CoreLocalizationsEn();
    case 'th':
      return CoreLocalizationsTh();
  }

  throw FlutterError(
      'CoreLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
