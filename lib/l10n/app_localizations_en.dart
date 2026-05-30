// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Qadaa Prayer Tracker';

  @override
  String get navHome => 'Home';

  @override
  String get navStats => 'Statistics';

  @override
  String get navContent => 'Content';

  @override
  String get navSettings => 'Settings';

  @override
  String get greeting => 'Assalamu Alaikum';

  @override
  String get userName => 'User';

  @override
  String get todayLabel => 'Today';

  @override
  String get todayPrayers => 'Today\'s prayers';

  @override
  String get statsCompleted => 'Completed';

  @override
  String get statsRemaining => 'Remaining';

  @override
  String get statsRate => 'Rate';

  @override
  String get prayerSectionTitle => 'Today\'s Prayers';

  @override
  String get prayerSectionAction => 'Manage';

  @override
  String get reminderSectionTitle => 'Reminders';

  @override
  String get reminderSectionAction => 'View All';

  @override
  String get allDone => 'All of today\'s prayers are completed, well done!';

  @override
  String reminderTitle(String prayerName) {
    return '$prayerName Prayer';
  }

  @override
  String get reminderSubtitle => 'You haven\'t completed this prayer yet';

  @override
  String get reminderAction => 'Make Up';

  @override
  String get prayerNameFajr => 'Fajr';

  @override
  String get prayerNameDhuhr => 'Dhuhr';

  @override
  String get prayerNameAsr => 'Asr';

  @override
  String get prayerNameMaghrib => 'Maghrib';

  @override
  String get prayerNameIsha => 'Isha';

  @override
  String get manageTitle => 'Prayer Management';

  @override
  String get manageSubtitle => 'Select the prayers you have completed';

  @override
  String get manageSave => 'Save';

  @override
  String get manageToday => 'Today';

  @override
  String get manageYesterday => 'Yesterday';

  @override
  String get daySunday => 'Sunday';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get dayFriday => 'Friday';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get dayAbbrSun => 'S';

  @override
  String get dayAbbrMon => 'M';

  @override
  String get dayAbbrTue => 'T';

  @override
  String get dayAbbrWed => 'W';

  @override
  String get dayAbbrThu => 'T';

  @override
  String get dayAbbrFri => 'F';

  @override
  String get dayAbbrSat => 'S';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statThisWeek => 'This Week';

  @override
  String get statThisMonth => 'This Month';

  @override
  String get statTotal => 'Total';

  @override
  String get statRate => 'Completion Rate';

  @override
  String get statPrayer => 'prayer';

  @override
  String get statProgressRate => 'Progress Rate';

  @override
  String get distributionTitle => 'Prayer Distribution';

  @override
  String get weekChartTitle => 'Last 7 Days';

  @override
  String get contentTitle => 'Islamic Content';

  @override
  String get contentSubtitle =>
      'Remembrances and supplications to help you make up your prayers';

  @override
  String get tagDua => 'Supplications';

  @override
  String get tagVerses => 'Verses & Hadith';

  @override
  String get tagTips => 'Tips';

  @override
  String get tagAdhkar => 'Remembrances';

  @override
  String get settingsTitle => 'Notifications & Settings';

  @override
  String get settingsGroupNotifications => 'NOTIFICATIONS';

  @override
  String get settingsGroupGeneral => 'GENERAL SETTINGS';

  @override
  String get settingsGroupData => 'DATA';

  @override
  String get settingPrayerReminder => 'Prayer Reminders';

  @override
  String get settingPrayerReminderSub =>
      'Daily reminder for make-up prayer times';

  @override
  String get settingVibration => 'Vibration';

  @override
  String get settingVibrationSub => 'Enable vibration with notifications';

  @override
  String get settingLanguage => 'Language';

  @override
  String get settingLanguageValue => 'Arabic';

  @override
  String get settingCalendar => 'Calendar Calculation';

  @override
  String get settingCalendarValue => 'Umm al-Qura Calendar';

  @override
  String get settingLocation => 'My Location';

  @override
  String get settingLocationValue => 'Amman, Jordan';

  @override
  String get settingExport => 'Export Data';

  @override
  String get settingExportSub => 'Keep a copy of your statistics';

  @override
  String get settingReset => 'Reset';

  @override
  String get settingResetSub => 'Clear all data and start fresh';

  @override
  String get resetTitle => 'Reset Data';

  @override
  String get resetBody => 'Are you sure? All prayer data will be deleted.';

  @override
  String get resetCancel => 'Cancel';

  @override
  String get resetConfirm => 'Confirm';

  @override
  String get resetSnackbar => 'All data cleared';

  @override
  String get versionText => 'Qadaa Prayer Tracker  ·  1.0.0';

  @override
  String get onboardingTrackTitle => 'Track Your Missed\nPrayers';

  @override
  String get onboardingTrackSub =>
      'Record and count your missed prayers\neasily and regularly';

  @override
  String get onboardingStatsTitle => 'Accurate\nStatistics';

  @override
  String get onboardingStatsSub =>
      'Track your progress with charts\nand daily & weekly statistics';

  @override
  String get onboardingSmartTitle => 'Smart\nReminders';

  @override
  String get onboardingSmartSub =>
      'Get reminders at the\nright times for make-up prayers';

  @override
  String get onboardingStart => 'Start Now';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get notifChannelName => 'Prayer Reminders';

  @override
  String get notifChannelDesc => 'Reminders for make-up prayer times';

  @override
  String notifTitle(String prayerName) {
    return '$prayerName Prayer Reminder';
  }

  @override
  String notifBody(String prayerName) {
    return 'It\'s time to make up the $prayerName prayer';
  }

  @override
  String get qadaaTrackerTitle => 'Qadaa Progress';

  @override
  String qadaaTodayBanner(String prayerName) {
    return 'Now: $prayerName time';
  }

  @override
  String get qadaaEnterCount => 'Enter count';

  @override
  String get qadaaEnterValidNumber =>
      'Please enter a valid number greater than zero';

  @override
  String get qadaaLogButton => 'Log';

  @override
  String get qadaaRecentActivity => 'Recent Activity';

  @override
  String get qadaaFullyComplete => 'All made up!';

  @override
  String qadaaTotalMadeUp(int count) {
    return 'Total made up: $count';
  }

  @override
  String qadaaPrayerMadeUp(String prayerName, int count) {
    return '$prayerName made up $count rakah';
  }

  @override
  String qadaaPrayerMadeUp_plural(String prayerName, int count) {
    return '$prayerName made up $count rakahs';
  }

  @override
  String get qadaaYearsLabel => 'Missed Years';

  @override
  String get qadaaYearsSubtitle => 'Years of missed prayers';

  @override
  String get qadaaYearsDialogTitle => 'Missed Years';

  @override
  String get qadaaYearsDialogHint => 'Enter number of years';

  @override
  String get qadaaYearsDialogSave => 'Save';

  @override
  String get qadaaYearsResetWarning =>
      'Changing years will reset your current progress.';

  @override
  String get settingsGroupAccount => 'ACCOUNT';

  @override
  String get settingSignIn => 'Sign In';

  @override
  String get settingSignInSub => 'Sign in to sync your data';

  @override
  String get settingSignUp => 'Sign Up';

  @override
  String get settingSignOut => 'Sign Out';

  @override
  String get settingSignOutSub => 'Sign out of your account';

  @override
  String settingSignedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get authDialogTitle => 'Sign In';

  @override
  String get authDialogEmail => 'Email';

  @override
  String get authDialogPassword => 'Password';

  @override
  String get authDialogSignIn => 'Sign In';

  @override
  String get authDialogSignUp => 'Sign Up';

  @override
  String get authDialogCancel => 'Cancel';

  @override
  String authError(String error) {
    return 'Authentication error: $error';
  }

  @override
  String get authSignedOut => 'Signed out successfully';

  @override
  String get authSignedIn => 'Signed in successfully';

  @override
  String get authSignedUp => 'Verification link sent to your email';

  @override
  String get authSignInErrorInvalidCredentials => 'Invalid email or password';

  @override
  String get authSignUpErrorAlreadyRegistered =>
      'This email is already registered';

  @override
  String get authErrorNetwork =>
      'Network error, please check your connection and try again';

  @override
  String get authErrorRateLimit => 'Too many requests, please try again later';

  @override
  String get onboardingYearsTitle => 'How many years of prayers did you miss?';

  @override
  String get onboardingYearsSub => 'This will help us calculate your progress';

  @override
  String get onboardingYearsHint => 'Enter number of years';

  @override
  String get onboardingYearsSave => 'Continue';
}
