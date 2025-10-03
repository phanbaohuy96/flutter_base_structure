import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'fl_media_localizations_en.dart';
import 'fl_media_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FlMediaLocalizations
/// returned by `FlMediaLocalizations.of(context)`.
///
/// Applications need to include `FlMediaLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/fl_media_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FlMediaLocalizations.localizationsDelegates,
///   supportedLocales: FlMediaLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the FlMediaLocalizations.supportedLocales
/// property.
abstract class FlMediaLocalizations {
  FlMediaLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FlMediaLocalizations? of(BuildContext context) {
    return Localizations.of<FlMediaLocalizations>(
        context, FlMediaLocalizations);
  }

  static const LocalizationsDelegate<FlMediaLocalizations> delegate =
      _FlMediaLocalizationsDelegate();

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

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Select image'**
  String get choosePhoto;

  /// No description provided for @choosePhotoOrVideo.
  ///
  /// In en, this message translates to:
  /// **'Select image or video'**
  String get choosePhotoOrVideo;

  /// No description provided for @chooseVideo.
  ///
  /// In en, this message translates to:
  /// **'Select video'**
  String get chooseVideo;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @selectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Select photo'**
  String get selectPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;
}

class _FlMediaLocalizationsDelegate
    extends LocalizationsDelegate<FlMediaLocalizations> {
  const _FlMediaLocalizationsDelegate();

  @override
  Future<FlMediaLocalizations> load(Locale locale) {
    return SynchronousFuture<FlMediaLocalizations>(
        lookupFlMediaLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_FlMediaLocalizationsDelegate old) => false;
}

FlMediaLocalizations lookupFlMediaLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return FlMediaLocalizationsEn();
    case 'th':
      return FlMediaLocalizationsTh();
  }

  throw FlutterError(
      'FlMediaLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
