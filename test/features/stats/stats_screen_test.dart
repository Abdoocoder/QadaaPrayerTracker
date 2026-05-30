import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/di/locator.dart';
import 'package:qadaa_prayer_tracker/domain/models/prayer_name.dart';
import 'package:qadaa_prayer_tracker/ui/features/stats/view_models/stats_view_model.dart';
import 'package:qadaa_prayer_tracker/ui/features/stats/views/stats_screen.dart';
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

  group('StatsScreen', () {
    testWidgets('loads data on init', (tester) async {
      final logRepo = MockLogRepo();
      final vm = StatsViewModel(logRepo: logRepo);
      sl.registerFactory<StatsViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const StatsScreen()));
      await tester.pump();

      expect(find.text('الإحصائيات'), findsOneWidget);
    });

    testWidgets('shows stat cards after load', (tester) async {
      final logRepo = MockLogRepo();
      final vm = StatsViewModel(logRepo: logRepo);
      sl.registerFactory<StatsViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const StatsScreen()));
      await tester.pump();

      expect(find.text('هذا الأسبوع'), findsOneWidget);
      expect(find.text('هذا الشهر'), findsOneWidget);
      expect(find.text('الإجمالي'), findsOneWidget);
      expect(find.text('معدل الإنجاز'), findsOneWidget);
    });

    testWidgets('shows distribution section after load', (tester) async {
      final logRepo = MockLogRepo();
      final vm = StatsViewModel(logRepo: logRepo);
      sl.registerFactory<StatsViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const StatsScreen()));
      await tester.pump();

      expect(find.text('توزيع الصلوات'), findsOneWidget);
    });

    testWidgets('shows weekly chart section after load', (tester) async {
      final logRepo = MockLogRepo();
      final vm = StatsViewModel(logRepo: logRepo);
      sl.registerFactory<StatsViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const StatsScreen()));
      await tester.pump();

      expect(find.text('آخر ٧ أيام'), findsOneWidget);
    });

    testWidgets('shows error state when load fails', (tester) async {
      final failingLogRepo = MockLogRepo();
      failingLogRepo.failOnGetDayLog = true;
      final vm = StatsViewModel(logRepo: failingLogRepo);
      sl.registerFactory<StatsViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const StatsScreen()));
      await tester.pump();

      expect(find.text('تعذر تحميل الإحصائيات'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });

    testWidgets('shows null state when data missing', (tester) async {
      final logRepo = MockLogRepo();
      final vm = StatsViewModel(logRepo: logRepo);
      sl.registerFactory<StatsViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const StatsScreen()));
      await tester.pump();

      vm.agg = null;
      vm.dist = null;
      vm.weekLogs = null;
      vm.notifyListeners();
      await tester.pump();

      expect(find.text('لا توجد بيانات'), findsOneWidget);
    });

    testWidgets('shows prayer distribution bars', (tester) async {
      final logRepo = MockLogRepo();
      final vm = StatsViewModel(logRepo: logRepo);
      sl.registerFactory<StatsViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const StatsScreen()));
      await tester.pump();

      for (final p in allPrayers) {
        expect(find.text(p.arName), findsWidgets);
      }
    });

    testWidgets('shows stat values', (tester) async {
      final logRepo = MockLogRepo();
      final vm = StatsViewModel(logRepo: logRepo);
      sl.registerFactory<StatsViewModel>(() => vm);

      await tester.pumpWidget(wrapApp(const StatsScreen()));
      await tester.pump();

      expect(find.text('12'), findsAtLeastNWidgets(1));
      expect(find.text('45'), findsAtLeastNWidgets(1));
      expect(find.text('200'), findsAtLeastNWidgets(1));
    });
  });
}
