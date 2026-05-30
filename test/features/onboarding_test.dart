import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:qadaa_prayer_tracker/app.dart';
import '../helpers/test_setup.dart';

void main() {
  setUpAll(() async {
    databaseFactory = databaseFactoryFfi;
    await testSetupDi();
  });

  group('OnboardingScreen', () {
    testWidgets('renders first page with تخطي and التالي buttons',
        (tester) async {
      await tester.pumpWidget(const QadaaApp());
      await tester.pump();
      expect(find.text('التالي'), findsOneWidget);
      expect(find.text('تخطي'), findsOneWidget);
    });

    testWidgets('shows page indicator dots', (tester) async {
      await tester.pumpWidget(const QadaaApp());
      await tester.pump();
      // 3 dots rendered by AnimatedContainer for 3 pages
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('التالي navigates to second page showing إحصائيات',
        (tester) async {
      await tester.pumpWidget(const QadaaApp());
      await tester.pump();
      await tester.tap(find.text('التالي'));
      await tester.pumpAndSettle();
      // Second page title contains "إحصائيات"
      expect(find.textContaining('إحصائيات'), findsWidgets);
    });

    testWidgets('third page shows ابدأ الآن', (tester) async {
      await tester.pumpWidget(const QadaaApp());
      await tester.pump();

      await tester.tap(find.text('التالي'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('التالي'));
      await tester.pumpAndSettle();

      expect(find.text('ابدأ الآن'), findsOneWidget);
    });

    testWidgets('تخطي navigates to years input page', (tester) async {
      await tester.pumpWidget(const QadaaApp());
      await tester.pump();
      await tester.tap(find.text('تخطي'));
      await tester.pumpAndSettle();
      // After skip, we should see the years input page
      expect(find.textContaining('سنوات'), findsWidgets);
    });

    testWidgets('years page save navigates to HomeScreen', (tester) async {
      await tester.pumpWidget(const QadaaApp());
      await tester.pump();
      await tester.tap(find.text('تخطي'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.text('متابعة'));
      await tester.pumpAndSettle();

      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الإحصائيات'), findsOneWidget);
      expect(find.text('المحتوى'), findsOneWidget);
      expect(find.text('الإعدادات'), findsOneWidget);
    });
  });
}
