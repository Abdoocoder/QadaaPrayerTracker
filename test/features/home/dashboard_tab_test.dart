import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/di/locator.dart';
import 'package:qadaa_prayer_tracker/ui/features/home/view_models/home_view_model.dart';
import 'package:qadaa_prayer_tracker/ui/features/home/views/dashboard_tab.dart';
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

  group('DashboardTab', () {
    testWidgets('shows data after load completes', (tester) async {
      final vm = HomeViewModel(logRepo: MockLogRepo(), timeRepo: MockTimeRepo());
      sl.registerFactory<HomeViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const DashboardTab()));
      await tester.pump();

      expect(vm.loading, isFalse);
      expect(vm.today, isNotNull);
    });

    testWidgets('shows greeting after loading', (tester) async {
      final logRepo = MockLogRepo();
      final timeRepo = MockTimeRepo();
      final vm = HomeViewModel(logRepo: logRepo, timeRepo: timeRepo);
      sl.registerFactory<HomeViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const DashboardTab()));
      await tester.pump();

      expect(find.text('السلام عليكم'), findsOneWidget);
      expect(find.text('عبد الله'), findsOneWidget);
    });

    testWidgets('shows hero stats after loading', (tester) async {
      final logRepo = MockLogRepo();
      final timeRepo = MockTimeRepo();
      final vm = HomeViewModel(logRepo: logRepo, timeRepo: timeRepo);
      sl.registerFactory<HomeViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const DashboardTab()));
      await tester.pump();

      expect(find.text('مقضية'), findsOneWidget);
      expect(find.text('متبقية'), findsOneWidget);
      expect(find.text('الإنجاز'), findsOneWidget);
    });

    testWidgets('shows prayer grid after loading', (tester) async {
      final logRepo = MockLogRepo();
      final timeRepo = MockTimeRepo();
      final vm = HomeViewModel(logRepo: logRepo, timeRepo: timeRepo);
      sl.registerFactory<HomeViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const DashboardTab()));
      await tester.pump();

      expect(find.text('الفجر'), findsOneWidget);
      expect(find.text('04:30'), findsOneWidget);
    });

    testWidgets('shows reminders section after loading', (tester) async {
      final logRepo = MockLogRepo();
      final timeRepo = MockTimeRepo();
      final vm = HomeViewModel(logRepo: logRepo, timeRepo: timeRepo);
      sl.registerFactory<HomeViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const DashboardTab()));
      await tester.pump();

      expect(find.text('تذكيرات'), findsOneWidget);
      expect(find.text('عرض الكل'), findsOneWidget);
    });

    testWidgets('shows error state when load fails', (tester) async {
      final failingLogRepo = MockLogRepo();
      failingLogRepo.failOnGetDayLog = true;
      final vm = HomeViewModel(logRepo: failingLogRepo, timeRepo: MockTimeRepo());
      sl.registerFactory<HomeViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const DashboardTab()));
      await tester.pump();

      expect(find.text('تعذر تحميل البيانات'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });

    testWidgets('error state has retry button', (tester) async {
      final failingLogRepo = MockLogRepo();
      failingLogRepo.failOnGetDayLog = true;
      final vm = HomeViewModel(logRepo: failingLogRepo, timeRepo: MockTimeRepo());
      sl.registerFactory<HomeViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const DashboardTab()));
      await tester.pump();

      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });

    testWidgets('shows null state when data is null', (tester) async {
      final logRepo = MockLogRepo();
      final timeRepo = MockTimeRepo();
      final vm = HomeViewModel(logRepo: logRepo, timeRepo: timeRepo);
      sl.registerFactory<HomeViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const DashboardTab()));
      await tester.pump();

      vm.today = null;
      vm.agg = null;
      vm.times = null;
      vm.notifyListeners();
      await tester.pump();

      expect(find.text('لا توجد بيانات'), findsOneWidget);
    });
  });
}
