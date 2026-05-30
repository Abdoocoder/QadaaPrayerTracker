import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('ar'),
    Locale('en'),
  ];

  /// App title
  ///
  /// In en, this message translates to:
  /// **'Qadaa Prayer Tracker'**
  String get appTitle;

  /// Bottom nav: home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav: statistics tab
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get navStats;

  /// Bottom nav: content tab
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get navContent;

  /// Bottom nav: settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Home greeting header
  ///
  /// In en, this message translates to:
  /// **'Assalamu Alaikum'**
  String get greeting;

  /// Default user display name
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userName;

  /// Hero card today badge
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// Hero card subtitle
  ///
  /// In en, this message translates to:
  /// **'Today\'\'s prayers'**
  String get todayPrayers;

  /// Hero stat: completed count
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statsCompleted;

  /// Hero stat: remaining count
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get statsRemaining;

  /// Hero stat: completion rate
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get statsRate;

  /// Section header for prayer grid
  ///
  /// In en, this message translates to:
  /// **'Today\'\'s Prayers'**
  String get prayerSectionTitle;

  /// Section action button
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get prayerSectionAction;

  /// Section header for reminders
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminderSectionTitle;

  /// Section action button
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get reminderSectionAction;

  /// When all prayers are done
  ///
  /// In en, this message translates to:
  /// **'All of today\'\'s prayers are completed, well done!'**
  String get allDone;

  /// Reminder list title
  ///
  /// In en, this message translates to:
  /// **'{prayerName} Prayer'**
  String reminderTitle(String prayerName);

  /// Reminder list subtitle
  ///
  /// In en, this message translates to:
  /// **'You haven\'\'t completed this prayer yet'**
  String get reminderSubtitle;

  /// Reminder action button text
  ///
  /// In en, this message translates to:
  /// **'Make Up'**
  String get reminderAction;

  /// Prayer name: Fajr
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerNameFajr;

  /// Prayer name: Dhuhr
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerNameDhuhr;

  /// Prayer name: Asr
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerNameAsr;

  /// Prayer name: Maghrib
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerNameMaghrib;

  /// Prayer name: Isha
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerNameIsha;

  /// Prayer management screen title
  ///
  /// In en, this message translates to:
  /// **'Prayer Management'**
  String get manageTitle;

  /// Manage screen instruction
  ///
  /// In en, this message translates to:
  /// **'Select the prayers you have completed'**
  String get manageSubtitle;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get manageSave;

  /// Date strip: today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get manageToday;

  /// Date strip: yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get manageYesterday;

  /// Day name
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// Day name
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// Day name
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// Day name
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// Day name
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// Day name
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// Day name
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// Day abbreviation
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get dayAbbrSun;

  /// Day abbreviation
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get dayAbbrMon;

  /// Day abbreviation
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get dayAbbrTue;

  /// Day abbreviation
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get dayAbbrWed;

  /// Day abbreviation
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get dayAbbrThu;

  /// Day abbreviation
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get dayAbbrFri;

  /// Day abbreviation
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get dayAbbrSat;

  /// Stats screen title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// Stat card label
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get statThisWeek;

  /// Stat card label
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get statThisMonth;

  /// Stat card label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get statTotal;

  /// Stat card label
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get statRate;

  /// Unit: prayer (singular context)
  ///
  /// In en, this message translates to:
  /// **'prayer'**
  String get statPrayer;

  /// Stat card subtitle
  ///
  /// In en, this message translates to:
  /// **'Progress Rate'**
  String get statProgressRate;

  /// Distribution section title
  ///
  /// In en, this message translates to:
  /// **'Prayer Distribution'**
  String get distributionTitle;

  /// Week chart section title
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get weekChartTitle;

  /// Content screen title
  ///
  /// In en, this message translates to:
  /// **'Islamic Content'**
  String get contentTitle;

  /// Content screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Remembrances and supplications to help you make up your prayers'**
  String get contentSubtitle;

  /// Content tag
  ///
  /// In en, this message translates to:
  /// **'Supplications'**
  String get tagDua;

  /// Content tag
  ///
  /// In en, this message translates to:
  /// **'Verses & Hadith'**
  String get tagVerses;

  /// Content tag
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tagTips;

  /// Content tag
  ///
  /// In en, this message translates to:
  /// **'Remembrances'**
  String get tagAdhkar;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Notifications & Settings'**
  String get settingsTitle;

  /// Settings group header
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get settingsGroupNotifications;

  /// Settings group header
  ///
  /// In en, this message translates to:
  /// **'GENERAL SETTINGS'**
  String get settingsGroupGeneral;

  /// Settings group header
  ///
  /// In en, this message translates to:
  /// **'DATA'**
  String get settingsGroupData;

  /// Setting toggle
  ///
  /// In en, this message translates to:
  /// **'Prayer Reminders'**
  String get settingPrayerReminder;

  /// Setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Daily reminder for make-up prayer times'**
  String get settingPrayerReminderSub;

  /// Setting toggle
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingVibration;

  /// Setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Enable vibration with notifications'**
  String get settingVibrationSub;

  /// Setting nav
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingLanguage;

  /// Setting value
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get settingLanguageValue;

  /// Setting nav
  ///
  /// In en, this message translates to:
  /// **'Calendar Calculation'**
  String get settingCalendar;

  /// Setting value
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura Calendar'**
  String get settingCalendarValue;

  /// Setting nav
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get settingLocation;

  /// Setting value
  ///
  /// In en, this message translates to:
  /// **'Amman, Jordan'**
  String get settingLocationValue;

  /// Setting nav
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get settingExport;

  /// Setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Keep a copy of your statistics'**
  String get settingExportSub;

  /// Setting nav
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingReset;

  /// Setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Clear all data and start fresh'**
  String get settingResetSub;

  /// Reset dialog title
  ///
  /// In en, this message translates to:
  /// **'Reset Data'**
  String get resetTitle;

  /// Reset dialog body
  ///
  /// In en, this message translates to:
  /// **'Are you sure? All prayer data will be deleted.'**
  String get resetBody;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get resetCancel;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get resetConfirm;

  /// Reset success snackbar
  ///
  /// In en, this message translates to:
  /// **'All data cleared'**
  String get resetSnackbar;

  /// Footer version text
  ///
  /// In en, this message translates to:
  /// **'Qadaa Prayer Tracker  ·  1.0.0'**
  String get versionText;

  /// Onboarding page 1 title
  ///
  /// In en, this message translates to:
  /// **'Track Your Missed\nPrayers'**
  String get onboardingTrackTitle;

  /// Onboarding page 1 subtitle
  ///
  /// In en, this message translates to:
  /// **'Record and count your missed prayers\neasily and regularly'**
  String get onboardingTrackSub;

  /// Onboarding page 2 title
  ///
  /// In en, this message translates to:
  /// **'Accurate\nStatistics'**
  String get onboardingStatsTitle;

  /// Onboarding page 2 subtitle
  ///
  /// In en, this message translates to:
  /// **'Track your progress with charts\nand daily & weekly statistics'**
  String get onboardingStatsSub;

  /// Onboarding page 3 title
  ///
  /// In en, this message translates to:
  /// **'Smart\nReminders'**
  String get onboardingSmartTitle;

  /// Onboarding page 3 subtitle
  ///
  /// In en, this message translates to:
  /// **'Get reminders at the\nright times for make-up prayers'**
  String get onboardingSmartSub;

  /// Final page button
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get onboardingStart;

  /// Non-final page button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Notification channel name
  ///
  /// In en, this message translates to:
  /// **'Prayer Reminders'**
  String get notifChannelName;

  /// Notification channel description
  ///
  /// In en, this message translates to:
  /// **'Reminders for make-up prayer times'**
  String get notifChannelDesc;

  /// Notification title
  ///
  /// In en, this message translates to:
  /// **'{prayerName} Prayer Reminder'**
  String notifTitle(String prayerName);

  /// Notification body
  ///
  /// In en, this message translates to:
  /// **'It\'\'s time to make up the {prayerName} prayer'**
  String notifBody(String prayerName);

  /// Qadaa tracker screen title
  ///
  /// In en, this message translates to:
  /// **'Qadaa Progress'**
  String get qadaaTrackerTitle;

  /// Current prayer time banner
  ///
  /// In en, this message translates to:
  /// **'Now: {prayerName} time'**
  String qadaaTodayBanner(String prayerName);

  /// Log dialog hint
  ///
  /// In en, this message translates to:
  /// **'Enter count'**
  String get qadaaEnterCount;

  /// Log dialog validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number greater than zero'**
  String get qadaaEnterValidNumber;

  /// Log action button
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get qadaaLogButton;

  /// Log list section title
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get qadaaRecentActivity;

  /// Prayer fully completed
  ///
  /// In en, this message translates to:
  /// **'All made up!'**
  String get qadaaFullyComplete;

  /// Footer total
  ///
  /// In en, this message translates to:
  /// **'Total made up: {count}'**
  String qadaaTotalMadeUp(int count);

  /// Plural log entry
  ///
  /// In en, this message translates to:
  /// **'{prayerName} made up {count} rakah'**
  String qadaaPrayerMadeUp(String prayerName, int count);

  /// Plural log entry
  ///
  /// In en, this message translates to:
  /// **'{prayerName} made up {count} rakahs'**
  String qadaaPrayerMadeUp_plural(String prayerName, int count);

  /// Settings years label
  ///
  /// In en, this message translates to:
  /// **'Missed Years'**
  String get qadaaYearsLabel;

  /// Settings years subtitle
  ///
  /// In en, this message translates to:
  /// **'Years of missed prayers'**
  String get qadaaYearsSubtitle;

  /// Years edit dialog title
  ///
  /// In en, this message translates to:
  /// **'Missed Years'**
  String get qadaaYearsDialogTitle;

  /// Years edit hint
  ///
  /// In en, this message translates to:
  /// **'Enter number of years'**
  String get qadaaYearsDialogHint;

  /// Years dialog save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get qadaaYearsDialogSave;

  /// Years change warning
  ///
  /// In en, this message translates to:
  /// **'Changing years will reset your current progress.'**
  String get qadaaYearsResetWarning;

  /// Settings group header
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get settingsGroupAccount;

  /// Setting nav
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get settingSignIn;

  /// Setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your data'**
  String get settingSignInSub;

  /// Setting nav
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get settingSignUp;

  /// Setting nav
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingSignOut;

  /// Setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get settingSignOutSub;

  /// Signed in status
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String settingSignedInAs(String email);

  /// Auth dialog title
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authDialogTitle;

  /// Auth dialog email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authDialogEmail;

  /// Auth dialog password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authDialogPassword;

  /// Auth dialog sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authDialogSignIn;

  /// Auth dialog sign up button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authDialogSignUp;

  /// Auth dialog cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get authDialogCancel;

  /// Auth error snackbar
  ///
  /// In en, this message translates to:
  /// **'Authentication error: {error}'**
  String authError(String error);

  /// Sign out success snackbar
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully'**
  String get authSignedOut;

  /// Sign in success snackbar
  ///
  /// In en, this message translates to:
  /// **'Signed in successfully'**
  String get authSignedIn;

  /// Sign up success snackbar
  ///
  /// In en, this message translates to:
  /// **'Verification link sent to your email'**
  String get authSignedUp;

  /// Sign in error
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get authSignInErrorInvalidCredentials;

  /// Sign up error
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get authSignUpErrorAlreadyRegistered;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error, please check your connection and try again'**
  String get authErrorNetwork;

  /// Rate limit error message
  ///
  /// In en, this message translates to:
  /// **'Too many requests, please try again later'**
  String get authErrorRateLimit;

  /// Onboarding years question
  ///
  /// In en, this message translates to:
  /// **'How many years of prayers did you miss?'**
  String get onboardingYearsTitle;

  /// Onboarding years subtitle
  ///
  /// In en, this message translates to:
  /// **'This will help us calculate your progress'**
  String get onboardingYearsSub;

  /// Onboarding years input hint
  ///
  /// In en, this message translates to:
  /// **'Enter number of years'**
  String get onboardingYearsHint;

  /// Onboarding years save button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingYearsSave;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
