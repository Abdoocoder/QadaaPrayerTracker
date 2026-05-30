import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/theme/app_theme.dart';
import 'package:qadaa_prayer_tracker/ui/core/widgets/stat_card.dart';
import 'package:qadaa_prayer_tracker/ui/core/widgets/section_header.dart';
import 'package:qadaa_prayer_tracker/ui/features/manage/views/toggle_tile.dart';
import 'package:qadaa_prayer_tracker/ui/features/manage/views/date_strip.dart';

Widget wrapApp(Widget w) => MaterialApp(home: Scaffold(body: w));

void main() {
  group('StatCard', () {
    testWidgets('renders label, value, and sub text', (tester) async {
      await tester.pumpWidget(wrapApp(const StatCard(
        label: 'هذا الأسبوع', value: '12',
        sub: 'صلاة مقضية', icon: Icons.date_range_rounded,
        color: AppTheme.primary,
      )));
      expect(find.text('هذا الأسبوع'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('صلاة مقضية'), findsOneWidget);
    });

    testWidgets('renders with different color', (tester) async {
      await tester.pumpWidget(wrapApp(const StatCard(
        label: 'test', value: '5', sub: 'items',
        icon: Icons.star, color: AppTheme.secondary,
      )));
      expect(find.text('5'), findsOneWidget);
    });
  });

  group('SectionHeader', () {
    testWidgets('renders title without action', (tester) async {
      await tester.pumpWidget(wrapApp(const SectionHeader(title: 'صلوات اليوم')));
      expect(find.text('صلوات اليوم'), findsOneWidget);
    });

    testWidgets('renders title with action button', (tester) async {
      await tester.pumpWidget(wrapApp(const SectionHeader(
        title: 'تذكيرات', action: 'عرض الكل',
      )));
      expect(find.text('تذكيرات'), findsOneWidget);
      expect(find.text('عرض الكل'), findsOneWidget);
    });

    testWidgets('fires onAction when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrapApp(SectionHeader(
        title: 'العنوان', action: 'إجراء',
        onAction: () => tapped = true,
      )));
      await tester.tap(find.text('إجراء'));
      expect(tapped, isTrue);
    });
  });

  group('ToggleTile', () {
    testWidgets('renders prayer name and time', (tester) async {
      await tester.pumpWidget(wrapApp(ToggleTile(
        name: 'الفجر', time: '04:30',
        completed: false,
        onToggle: () {},
      )));
      expect(find.text('الفجر'), findsOneWidget);
      expect(find.text('04:30'), findsOneWidget);
    });

    testWidgets('shows strikethrough when completed', (tester) async {
      await tester.pumpWidget(wrapApp(ToggleTile(
        name: 'المغرب', time: '18:45',
        completed: true,
        onToggle: () {},
      )));
      expect(find.text('المغرب'), findsOneWidget);
    });

    testWidgets('fires onToggle on tap', (tester) async {
      var toggled = false;
      await tester.pumpWidget(wrapApp(ToggleTile(
        name: 'العشاء', time: '20:00',
        completed: false,
        onToggle: () => toggled = true,
      )));
      await tester.tap(find.text('العشاء'));
      expect(toggled, isTrue);
    });
  });

  group('DateStrip', () {
    final dates = List.generate(7, (i) => DateTime(2026, 5, 29 - i));

    testWidgets('renders 7 date labels', (tester) async {
      await tester.pumpWidget(wrapApp(DateStrip(
        selected: 0, dates: dates,
        onSelect: (_) {},
      )));
      expect(find.text('اليوم'), findsOneWidget);
    });

    testWidgets('highlights selected day', (tester) async {
      await tester.pumpWidget(wrapApp(DateStrip(
        selected: 0, dates: dates,
        onSelect: (_) {},
      )));
      final today = find.text('اليوم');
      expect(today, findsOneWidget);
    });

    testWidgets('fires onSelect with index', (tester) async {
      var selected = -1;
      await tester.pumpWidget(wrapApp(DateStrip(
        selected: 0, dates: dates,
        onSelect: (i) => selected = i,
      )));
      await tester.tap(find.text('أمس'));
      expect(selected, 1);
    });
  });
}
