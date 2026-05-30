// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Qadaa Prayer Tracker';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navStats => 'الإحصائيات';

  @override
  String get navContent => 'المحتوى';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get greeting => 'السلام عليكم';

  @override
  String get userName => 'عبد الله';

  @override
  String get todayLabel => 'اليوم';

  @override
  String get todayPrayers => 'صلوات اليوم';

  @override
  String get statsCompleted => 'مقضية';

  @override
  String get statsRemaining => 'متبقية';

  @override
  String get statsRate => 'الإنجاز';

  @override
  String get prayerSectionTitle => 'صلوات اليوم';

  @override
  String get prayerSectionAction => 'إدارة';

  @override
  String get reminderSectionTitle => 'تذكيرات';

  @override
  String get reminderSectionAction => 'عرض الكل';

  @override
  String get allDone => 'جميع صلوات اليوم مقضية، أحسنت!';

  @override
  String reminderTitle(String prayerName) {
    return 'صلاة $prayerName';
  }

  @override
  String get reminderSubtitle => 'لم تقض هذه الصلاة بعد';

  @override
  String get reminderAction => 'قضاء';

  @override
  String get prayerNameFajr => 'الفجر';

  @override
  String get prayerNameDhuhr => 'الظهر';

  @override
  String get prayerNameAsr => 'العصر';

  @override
  String get prayerNameMaghrib => 'المغرب';

  @override
  String get prayerNameIsha => 'العشاء';

  @override
  String get manageTitle => 'إدارة الصلوات';

  @override
  String get manageSubtitle => 'اختر الصلوات التي قضيتها';

  @override
  String get manageSave => 'حفظ';

  @override
  String get manageToday => 'اليوم';

  @override
  String get manageYesterday => 'أمس';

  @override
  String get daySunday => 'الأحد';

  @override
  String get dayMonday => 'الاثنين';

  @override
  String get dayTuesday => 'الثلاثاء';

  @override
  String get dayWednesday => 'الأربعاء';

  @override
  String get dayThursday => 'الخميس';

  @override
  String get dayFriday => 'الجمعة';

  @override
  String get daySaturday => 'السبت';

  @override
  String get dayAbbrSun => 'س';

  @override
  String get dayAbbrMon => 'ن';

  @override
  String get dayAbbrTue => 'ث';

  @override
  String get dayAbbrWed => 'ر';

  @override
  String get dayAbbrThu => 'خ';

  @override
  String get dayAbbrFri => 'ج';

  @override
  String get dayAbbrSat => 'س';

  @override
  String get statsTitle => 'الإحصائيات';

  @override
  String get statThisWeek => 'هذا الأسبوع';

  @override
  String get statThisMonth => 'هذا الشهر';

  @override
  String get statTotal => 'الإجمالي';

  @override
  String get statRate => 'معدل الإنجاز';

  @override
  String get statPrayer => 'صلاة مقضية';

  @override
  String get statProgressRate => 'نسبة التقدم';

  @override
  String get distributionTitle => 'توزيع الصلوات';

  @override
  String get weekChartTitle => 'آخر ٧ أيام';

  @override
  String get contentTitle => 'المحتوى الشرعي';

  @override
  String get contentSubtitle => 'أذكار وأدعية لتكون عوناً لك في قضاء الصلوات';

  @override
  String get tagDua => 'أدعية';

  @override
  String get tagVerses => 'آيات وأحاديث';

  @override
  String get tagTips => 'نصائح';

  @override
  String get tagAdhkar => 'أذكار';

  @override
  String get settingsTitle => 'التنبيهات والإعدادات';

  @override
  String get settingsGroupNotifications => 'التنبيهات';

  @override
  String get settingsGroupGeneral => 'الإعدادات العامة';

  @override
  String get settingsGroupData => 'البيانات';

  @override
  String get settingPrayerReminder => 'تذكير بالصلوات القادئة';

  @override
  String get settingPrayerReminderSub => 'تنبيه يومي لأوقات القضاء';

  @override
  String get settingVibration => 'اهتزاز';

  @override
  String get settingVibrationSub => 'تفعيل الاهتزاز مع التنبيهات';

  @override
  String get settingLanguage => 'اللغة';

  @override
  String get settingLanguageValue => 'العربية';

  @override
  String get settingCalendar => 'حساب التاريخ';

  @override
  String get settingCalendarValue => 'تقويم أم القرى';

  @override
  String get settingLocation => 'موقعي';

  @override
  String get settingLocationValue => 'عمان، الأردن';

  @override
  String get settingExport => 'تصدير البيانات';

  @override
  String get settingExportSub => 'احتفظ بنسخة من إحصائياتك';

  @override
  String get settingReset => 'إعادة تعيين';

  @override
  String get settingResetSub => 'مسح جميع البيانات والبدء من جديد';

  @override
  String get resetTitle => 'إعادة تعيين البيانات';

  @override
  String get resetBody => 'هل أنت متأكد؟ سيتم مسح جميع بيانات الصلوات المسجلة.';

  @override
  String get resetCancel => 'إلغاء';

  @override
  String get resetConfirm => 'تأكيد';

  @override
  String get resetSnackbar => 'تم مسح جميع البيانات';

  @override
  String get versionText => 'Qadaa Prayer Tracker  ·  1.0.0';

  @override
  String get onboardingTrackTitle => 'تتبع صلواتك\nالقادئة';

  @override
  String get onboardingTrackSub => 'سجل وأحص صلواتك الفائتة\nبكل سهولة وانتظام';

  @override
  String get onboardingStatsTitle => 'إحصائيات\nدقيقة';

  @override
  String get onboardingStatsSub =>
      'تابع تقدمك مع رسوم بيانية\nوإحصائيات يومية وأسبوعية';

  @override
  String get onboardingSmartTitle => 'تذكيرات\nذكية';

  @override
  String get onboardingSmartSub =>
      'احصل على تذكيرات في\nالأوقات المناسبة للقضاء';

  @override
  String get onboardingStart => 'ابدأ الآن';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get notifChannelName => 'تذكيرات الصلاة';

  @override
  String get notifChannelDesc => 'تذكيرات بأوقات قضاء الصلوات';

  @override
  String notifTitle(String prayerName) {
    return 'تذكير بصلاة $prayerName';
  }

  @override
  String notifBody(String prayerName) {
    return 'حان وقت قضاء صلاة $prayerName';
  }

  @override
  String get qadaaTrackerTitle => 'تقدم القضاء';

  @override
  String qadaaTodayBanner(String prayerName) {
    return 'الآن: وقت $prayerName';
  }

  @override
  String get qadaaEnterCount => 'أدخل العدد';

  @override
  String get qadaaEnterValidNumber => 'يرجى إدخال عدد صحيح أكبر من صفر';

  @override
  String get qadaaLogButton => 'تسجيل';

  @override
  String get qadaaRecentActivity => 'آخر الأنشطة';

  @override
  String get qadaaFullyComplete => 'تم القضاء بالكامل!';

  @override
  String qadaaTotalMadeUp(int count) {
    return 'إجمالي المقضي: $count';
  }

  @override
  String qadaaPrayerMadeUp(String prayerName, int count) {
    return '$prayerName أقضيت $count ركعة';
  }

  @override
  String qadaaPrayerMadeUp_plural(String prayerName, int count) {
    return '$prayerName أقضيت $count ركعات';
  }

  @override
  String get qadaaYearsLabel => 'السنوات الفائتة';

  @override
  String get qadaaYearsSubtitle => 'سنوات الصلوات الفائتة';

  @override
  String get qadaaYearsDialogTitle => 'السنوات الفائتة';

  @override
  String get qadaaYearsDialogHint => 'أدخل عدد السنوات';

  @override
  String get qadaaYearsDialogSave => 'حفظ';

  @override
  String get qadaaYearsResetWarning =>
      'تغيير السنوات سيعيد تعيين تقدمك الحالي.';

  @override
  String get settingsGroupAccount => 'الحساب';

  @override
  String get settingSignIn => 'تسجيل الدخول';

  @override
  String get settingSignInSub => 'سجل دخولك لمزامنة بياناتك';

  @override
  String get settingSignUp => 'إنشاء حساب';

  @override
  String get settingSignOut => 'تسجيل الخروج';

  @override
  String get settingSignOutSub => 'تسجيل الخروج من حسابك';

  @override
  String settingSignedInAs(String email) {
    return 'مسجل الدخول باسم $email';
  }

  @override
  String get authDialogTitle => 'تسجيل الدخول';

  @override
  String get authDialogEmail => 'البريد الإلكتروني';

  @override
  String get authDialogPassword => 'كلمة المرور';

  @override
  String get authDialogSignIn => 'تسجيل الدخول';

  @override
  String get authDialogSignUp => 'إنشاء حساب';

  @override
  String get authDialogCancel => 'إلغاء';

  @override
  String authError(String error) {
    return 'خطأ في المصادقة: $error';
  }

  @override
  String get authSignedOut => 'تم تسجيل الخروج بنجاح';

  @override
  String get authSignedIn => 'تم تسجيل الدخول بنجاح';

  @override
  String get authSignedUp => 'تم إرسال رابط التفعيل إلى بريدك الإلكتروني';

  @override
  String get authSignInErrorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get authSignUpErrorAlreadyRegistered =>
      'هذا البريد الإلكتروني مسجل مسبقاً';

  @override
  String get authErrorNetwork =>
      'خطأ في الاتصال بالشبكة، تحقق من اتصالك وحاول مرة أخرى';

  @override
  String get authErrorRateLimit => 'طلبات كثيرة جداً، حاول بعد قليل';

  @override
  String get onboardingYearsTitle => 'كم سنة فاتتك من الصلوات؟';

  @override
  String get onboardingYearsSub => 'سيساعدنا هذا في حساب تقدمك بدقة';

  @override
  String get onboardingYearsHint => 'أدخل عدد السنوات';

  @override
  String get onboardingYearsSave => 'متابعة';
}
