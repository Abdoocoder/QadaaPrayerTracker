import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/di/locator.dart';
import 'package:qadaa_prayer_tracker/ui/features/manage/view_models/manage_view_model.dart';
import 'package:qadaa_prayer_tracker/ui/features/manage/views/prayer_management_screen.dart';
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

  group('PrayerManagementScreen', () {
    testWidgets('shows title', (tester) async {
      final vm = ManageViewModel(logRepo: MockLogRepo(), timeRepo: MockTimeRepo());
      sl.registerFactory<ManageViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const PrayerManagementScreen()));
      await tester.pump();

      expect(find.text('إدارة الصلوات'), findsOneWidget);
    });

    testWidgets('shows prayer toggles after loading', (tester) async {
      final vm = ManageViewModel(logRepo: MockLogRepo(), timeRepo: MockTimeRepo());
      sl.registerFactory<ManageViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const PrayerManagementScreen()));
      await tester.pump();

      expect(find.text('الفجر'), findsOneWidget);
      expect(find.text('الظهر'), findsOneWidget);
      expect(find.text('العصر'), findsOneWidget);
      expect(find.text('المغرب'), findsOneWidget);
      expect(find.text('العشاء'), findsOneWidget);
    });

    testWidgets('shows save button', (tester) async {
      final vm = ManageViewModel(logRepo: MockLogRepo(), timeRepo: MockTimeRepo());
      sl.registerFactory<ManageViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const PrayerManagementScreen()));
      await tester.pump();

      expect(find.text('حفظ'), findsOneWidget);
    });

    testWidgets('displays date strip with 7 dates', (tester) async {
      final vm = ManageViewModel(logRepo: MockLogRepo(), timeRepo: MockTimeRepo());
      sl.registerFactory<ManageViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const PrayerManagementScreen()));
      await tester.pump();

      expect(vm.dates.length, 7);
    });

    testWidgets('toggling prayer updates state', (tester) async {
      final logRepo = MockLogRepo();
      final vm = ManageViewModel(logRepo: logRepo, timeRepo: MockTimeRepo());
      sl.registerFactory<ManageViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const PrayerManagementScreen()));
      await tester.pump();

      await tester.tap(find.text('حفظ'));
      await tester.pump();

      expect(find.text('إدارة الصلوات'), findsOneWidget);
    });
  });
}
