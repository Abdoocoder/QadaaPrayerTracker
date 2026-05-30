import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/di/locator.dart';
import 'package:qadaa_prayer_tracker/ui/features/settings/view_models/settings_view_model.dart';
import 'package:qadaa_prayer_tracker/ui/features/settings/views/settings_screen.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

Widget wrapApp(Widget w) => MaterialApp(home: Scaffold(body: w));

void main() {
  setUpAll(() async {
    await testSetupDi();
  });

  setUp(() {
    sl.allowReassignment = true;
  });

  group('SettingsScreen', () {
    testWidgets('loads data on init', (tester) async {
      final vm = SettingsViewModel(
        logRepo: MockLogRepo(),
        notifService: MockNotificationService(),
        db: MockDatabaseService(),
        prayerTimeService: MockPrayerTimeService(),
        localeNotifier: MockLocaleNotifier(),
        themeNotifier: MockThemeNotifier(),
      );
      sl.registerFactory<SettingsViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const SettingsScreen()));
      await tester.pump();

      expect(find.text('التنبيهات والإعدادات'), findsOneWidget);
    });

    testWidgets('shows notification switches after load', (tester) async {
      final vm = SettingsViewModel(
        logRepo: MockLogRepo(),
        notifService: MockNotificationService(),
        db: MockDatabaseService(),
        prayerTimeService: MockPrayerTimeService(),
        localeNotifier: MockLocaleNotifier(),
        themeNotifier: MockThemeNotifier(),
      );
      sl.registerFactory<SettingsViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const SettingsScreen()));
      await tester.pump();

      expect(find.text('تذكير بالصلوات القادئة'), findsOneWidget);
      expect(find.text('اهتزاز'), findsOneWidget);
    });

    testWidgets('shows general settings nav items', (tester) async {
      final vm = SettingsViewModel(
        logRepo: MockLogRepo(),
        notifService: MockNotificationService(),
        db: MockDatabaseService(),
        prayerTimeService: MockPrayerTimeService(),
        localeNotifier: MockLocaleNotifier(),
        themeNotifier: MockThemeNotifier(),
      );
      sl.registerFactory<SettingsViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const SettingsScreen()));
      await tester.pump();

      expect(find.text('اللغة'), findsOneWidget);
      expect(find.text('حساب التاريخ'), findsOneWidget);
      expect(find.text('موقعي'), findsOneWidget);
    });

    testWidgets('shows data section nav items', (tester) async {
      final vm = SettingsViewModel(
        logRepo: MockLogRepo(),
        notifService: MockNotificationService(),
        db: MockDatabaseService(),
        prayerTimeService: MockPrayerTimeService(),
        localeNotifier: MockLocaleNotifier(),
        themeNotifier: MockThemeNotifier(),
      );
      sl.registerFactory<SettingsViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const SettingsScreen()));
      await tester.pump();

      expect(find.text('تصدير البيانات'), findsOneWidget);
      expect(find.text('إعادة تعيين'), findsOneWidget);
    });

    testWidgets('shows version info', (tester) async {
      final vm = SettingsViewModel(
        logRepo: MockLogRepo(),
        notifService: MockNotificationService(),
        db: MockDatabaseService(),
        prayerTimeService: MockPrayerTimeService(),
        localeNotifier: MockLocaleNotifier(),
        themeNotifier: MockThemeNotifier(),
      );
      sl.registerFactory<SettingsViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const SettingsScreen()));
      await tester.pump();

      expect(find.textContaining('Qadaa Prayer Tracker'), findsOneWidget);
    });

    testWidgets('shows location display', (tester) async {
      final db = MockDatabaseService();
      final vm = SettingsViewModel(
        logRepo: MockLogRepo(),
        notifService: MockNotificationService(),
        db: db,
        prayerTimeService: MockPrayerTimeService(),
        localeNotifier: MockLocaleNotifier(),
        themeNotifier: MockThemeNotifier(),
      );
      sl.registerFactory<SettingsViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const SettingsScreen()));
      await db.setSetting('city', 'Cairo');
      await db.setSetting('country', 'Egypt');
      await vm.loadSettings();
      await tester.pump();

      expect(find.text('Cairo، Egypt'), findsOneWidget);
    });

    testWidgets('language tap opens dialog', (tester) async {
      final vm = SettingsViewModel(
        logRepo: MockLogRepo(),
        notifService: MockNotificationService(),
        db: MockDatabaseService(),
        prayerTimeService: MockPrayerTimeService(),
        localeNotifier: MockLocaleNotifier(),
        themeNotifier: MockThemeNotifier(),
      );
      sl.registerFactory<SettingsViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const SettingsScreen()));
      await tester.pump();

      await tester.tap(find.text('اللغة'));
      await tester.pumpAndSettle();

      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('export data tap opens dialog', (tester) async {
      final notifService = MockNotificationService();
      final db = MockDatabaseService();
      final vm = SettingsViewModel(
        logRepo: MockLogRepo(),
        notifService: notifService,
        db: db,
        prayerTimeService: MockPrayerTimeService(),
        localeNotifier: MockLocaleNotifier(),
        themeNotifier: MockThemeNotifier(),
      );
      sl.registerFactory<SettingsViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const SettingsScreen()));
      await tester.pump();

      final exportTile = find.byWidgetPredicate(
        (w) => w is ListTile && w.title != null &&
          w.title is Text && (w.title as Text).data == 'تصدير البيانات',
      );
      await tester.ensureVisible(exportTile);
      await tester.pump();
      await tester.tap(exportTile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('CSV'), findsOneWidget);
      expect(find.text('JSON'), findsOneWidget);
    });
  });
}
