import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/di/locator.dart';
import 'package:qadaa_prayer_tracker/domain/models/prayer_name.dart';
import 'package:qadaa_prayer_tracker/domain/models/day_log.dart';
import 'package:qadaa_prayer_tracker/ui/features/home/views/hero_stats_card.dart';
import 'package:qadaa_prayer_tracker/ui/features/home/views/reminder_list.dart';
import 'package:qadaa_prayer_tracker/ui/features/stats/views/weekly_chart.dart';

Widget wrapApp(Widget w) => MaterialApp(home: Scaffold(body: w));

final _allFalse = {for (final p in allPrayers) p: false};
final _oneDone = {for (final p in allPrayers) p: p == PrayerName.fajr};

final _dayLog = DayLog(date: DateTime(2026, 5, 29), prayers: _allFalse);
final _todayOneDone = DayLog(date: DateTime(2026, 5, 29), prayers: _oneDone);

void main() {
  group('HeroStatsCard', () {
    testWidgets('shows today stats with zero progress', (tester) async {
      await tester.pumpWidget(wrapApp(HeroStatsCard(
        today: _dayLog,
        agg: const {'today_done': 0, 'today_total': 5},
      )));
      expect(find.text('0'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows today stats with partial progress', (tester) async {
      await tester.pumpWidget(wrapApp(HeroStatsCard(
        today: _todayOneDone,
        agg: const {'today_done': 1, 'today_total': 5},
      )));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('displays Arabic date', (tester) async {
      await tester.pumpWidget(wrapApp(HeroStatsCard(
        today: _dayLog,
        agg: const {'today_done': 0, 'today_total': 5},
      )));
      expect(find.textContaining('مايو'), findsOneWidget);
    });
  });

  group('WeeklyChart', () {
    testWidgets('renders bars for each day', (tester) async {
      final logs = List.generate(7, (i) => _dayLog);
      await tester.pumpWidget(wrapApp(WeeklyChart(weekLogs: logs)));
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('shows day labels', (tester) async {
      final logs = List.generate(7, (i) => _dayLog);
      await tester.pumpWidget(wrapApp(WeeklyChart(weekLogs: logs)));
      expect(find.text('س'), findsWidgets);
    });
  });

  group('ReminderList', () {
    testWidgets('shows completion message when all done', (tester) async {
      final allDone = DayLog(
        date: DateTime(2026, 5, 29),
        prayers: {for (final p in allPrayers) p: true},
      );
      await tester.pumpWidget(wrapApp(ReminderList(today: allDone)));
      expect(find.text('جميع صلوات اليوم مقضية، أحسنت!'), findsOneWidget);
    });

    testWidgets('shows undone prayers as reminders', (tester) async {
      await tester.pumpWidget(wrapApp(ReminderList(today: _dayLog)));
      expect(find.text('صلاة الفجر'), findsOneWidget);
    });

    testWidgets('shows each prayer only once', (tester) async {
      await tester.pumpWidget(wrapApp(ReminderList(today: _dayLog)));
      for (final p in allPrayers) {
        expect(find.text('صلاة ${p.arName}'), findsOneWidget);
      }
    });

    testWidgets('shows fewer reminders when some done', (tester) async {
      await tester.pumpWidget(wrapApp(ReminderList(today: _todayOneDone)));
      expect(find.text('صلاة الظهر'), findsOneWidget);
    });

    testWidgets('قضاء button navigates to manage screen', (tester) async {
      await setupDi();
      await tester.pumpWidget(wrapApp(ReminderList(today: _dayLog)));
      await tester.tap(find.text('قضاء').first);
      await tester.pumpAndSettle();
      expect(find.text('إدارة الصلوات'), findsOneWidget);
    });
  });
}
