import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:qadaa_prayer_tracker/ui/features/settings/view_models/settings_view_model.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    databaseFactory = databaseFactoryFfi;
  });

  late SettingsViewModel vm;
  late MockLogRepo logRepo;
  late MockNotificationService notifService;
  late MockDatabaseService db;
  late MockPrayerTimeService prayerTimeService;
  late MockQadaaService qadaaService;
  late MockSupabaseService supabase;
  late MockSupabaseSyncService syncService;
  late MockLocaleNotifier localeNotifier;
  late MockThemeNotifier themeNotifier;

  setUp(() {
    logRepo = MockLogRepo();
    notifService = MockNotificationService();
    db = MockDatabaseService();
    prayerTimeService = MockPrayerTimeService();
    qadaaService = MockQadaaService();
    supabase = MockSupabaseService();
    syncService = MockSupabaseSyncService();
    localeNotifier = MockLocaleNotifier();
    themeNotifier = MockThemeNotifier();
    vm = SettingsViewModel(
      logRepo: logRepo,
      notifService: notifService,
      db: db,
      prayerTimeService: prayerTimeService,
      qadaaService: qadaaService,
      supabase: supabase,
      syncService: syncService,
      localeNotifier: localeNotifier,
      themeNotifier: themeNotifier,
    );
  });

  group('SettingsViewModel', () {
    test('initial state', () {
      expect(vm.loading, isTrue);
      expect(vm.notificationsEnabled, isFalse);
      expect(vm.vibrationEnabled, isTrue);
      expect(vm.city, 'Amman');
      expect(vm.country, 'Jordan');
      expect(vm.method, 3);
      expect(vm.localeCode, 'ar');
      expect(vm.error, isNull);
    });

    test('loadSettings loads saved values', () async {
      await db.setSetting('city', 'Cairo');
      await db.setSetting('country', 'Egypt');
      await db.setSetting('method', '4');
      await db.setSetting('notifications_enabled', 'true');
      await db.setSetting('vibration_enabled', 'false');

      await vm.loadSettings();
      expect(vm.city, 'Cairo');
      expect(vm.country, 'Egypt');
      expect(vm.method, 4);
      expect(vm.notificationsEnabled, isTrue);
      expect(vm.vibrationEnabled, isFalse);
      expect(vm.loading, isFalse);
    });

    test('loadSettings uses defaults when no saved values', () async {
      await vm.loadSettings();
      expect(vm.city, 'Amman');
      expect(vm.country, 'Jordan');
      expect(vm.method, 3);
    });

    test('toggleNotifications enables notifications', () async {
      await vm.loadSettings();
      await vm.toggleNotifications(true);
      expect(vm.notificationsEnabled, isTrue);
      expect(notifService.scheduledTimes, isNotNull);
    });

    test('toggleNotifications disables notifications', () async {
      notifService.scheduledTimes = testTimes;
      await vm.loadSettings();
      await vm.toggleNotifications(false);
      expect(vm.notificationsEnabled, isFalse);
      expect(notifService.didCancelAll, isTrue);
    });

    test('toggleNotifications rolls back on error', () async {
      final failingNotif = MockNotificationService();
      failingNotif.shouldThrowOnSchedule = true;
      vm = SettingsViewModel(
        logRepo: logRepo,
        notifService: failingNotif,
        db: db,
        prayerTimeService: prayerTimeService,
        qadaaService: qadaaService,
        supabase: supabase,
        syncService: syncService,
        localeNotifier: localeNotifier,
        themeNotifier: themeNotifier,
      );
      await vm.loadSettings();
      await vm.toggleNotifications(true);
      expect(vm.notificationsEnabled, isFalse);
      expect(vm.error, isNotNull);
    });

    test('toggleVibration updates state and saves', () async {
      await vm.loadSettings();
      await vm.toggleVibration(false);
      expect(vm.vibrationEnabled, isFalse);
      final saved = await db.getSetting('vibration_enabled');
      expect(saved, 'false');
    });

    test('setLocale updates locale code and notifies', () async {
      await vm.loadSettings();
      await vm.setLocale('en');
      expect(vm.localeCode, 'en');
      expect(localeNotifier.locale.languageCode, 'en');
    });

    test('setLocation updates city and country', () async {
      await vm.loadSettings();
      await vm.setLocation('Dubai', 'UAE');
      expect(vm.city, 'Dubai');
      expect(vm.country, 'UAE');
    });

    test('setMethod updates calculation method', () async {
      await vm.loadSettings();
      await vm.setMethod(2);
      expect(vm.method, 2);
    });

    test('methodName returns correct string', () async {
      await vm.loadSettings();
      await vm.setMethod(1);
      expect(vm.methodName, 'University of Islamic Sciences, Karachi');
    });

    test('locationDisplay returns formatted string', () async {
      await vm.loadSettings();
      await vm.setLocation('Mecca', 'Saudi Arabia');
      expect(vm.locationDisplay, 'Mecca، Saudi Arabia');
    });

    test('qadaaYears returns current years from service', () async {
      await vm.loadSettings();
      expect(vm.qadaaYears, 0);
      await qadaaService.resetFromYears(5);
      expect(vm.qadaaYears, 5);
    });

    test('setQadaaYears updates years via service', () async {
      await vm.loadSettings();
      await vm.setQadaaYears(3);
      expect(vm.qadaaYears, 3);
    });

    test('exportCsv returns CSV header', () async {
      await vm.loadSettings();
      final csv = await vm.exportCsv();
      expect(csv, startsWith('date,prayer_name'));
    });

    test('exportJson returns JSON array', () async {
      await vm.loadSettings();
      final json = await vm.exportJson();
      expect(json, startsWith('['));
      expect(json, endsWith(']'));
    });

    test('resetData clears data and notifications', () async {
      await vm.loadSettings();
      await vm.toggleNotifications(true);
      await vm.resetData();
      expect(vm.notificationsEnabled, isFalse);
      expect(notifService.didCancelAll, isTrue);
    });

    test('setLocation sets error on failure', () async {
      await vm.loadSettings();
      final failingDb = MockDatabaseService();
      failingDb.failOnSetSetting = true;
      vm = SettingsViewModel(
        logRepo: logRepo,
        notifService: notifService,
        db: failingDb,
        prayerTimeService: prayerTimeService,
        qadaaService: qadaaService,
        supabase: supabase,
        syncService: syncService,
        localeNotifier: localeNotifier,
        themeNotifier: themeNotifier,
      );
      await vm.setLocation('X', 'Y');
      expect(vm.error, isNotNull);
    });

    test('notifies listeners on loadSettings', () async {
      int notifyCount = 0;
      vm.addListener(() => notifyCount++);
      await vm.loadSettings();
      expect(notifyCount, greaterThanOrEqualTo(1));
    });
  });
}
