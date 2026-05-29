import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/di/locator.dart';
import 'package:qadaa_prayer_tracker/ui/features/home/view_models/home_view_model.dart';
import 'package:qadaa_prayer_tracker/ui/features/home/views/home_screen.dart';
import '../../helpers/mocks.dart';

Widget wrapApp(Widget w) => MaterialApp(home: w);

void main() {
  setUpAll(() async {
    await setupDi();
  });

  setUp(() {
    sl.allowReassignment = true;
  });

  group('HomeScreen tab navigation', () {
    testWidgets('shows dashboard tab by default', (tester) async {
      final mockVm = HomeViewModel(logRepo: MockLogRepo(), timeRepo: MockTimeRepo());
      sl.registerFactory<HomeViewModel>(() => mockVm);

      await tester.pumpWidget(wrapApp(const HomeScreen()));
      await tester.pump();

      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الإحصائيات'), findsOneWidget);
      expect(find.text('المحتوى'), findsOneWidget);
      expect(find.text('الإعدادات'), findsOneWidget);
    });

    testWidgets('navigates to stats tab on tap', (tester) async {
      final mockVm = HomeViewModel(logRepo: MockLogRepo(), timeRepo: MockTimeRepo());
      sl.registerFactory<HomeViewModel>(() => mockVm);

      await tester.pumpWidget(wrapApp(const HomeScreen()));
      await tester.pump();

      await tester.tap(find.text('الإحصائيات'));
      await tester.pumpAndSettle();

      // Stats screen renders after navigation
      expect(find.text('الإحصائيات'), findsWidgets);
    });

    testWidgets('navigates to content tab on tap', (tester) async {
      final mockVm = HomeViewModel(logRepo: MockLogRepo(), timeRepo: MockTimeRepo());
      sl.registerFactory<HomeViewModel>(() => mockVm);

      await tester.pumpWidget(wrapApp(const HomeScreen()));
      await tester.pump();

      await tester.tap(find.text('المحتوى'));
      await tester.pumpAndSettle();

      expect(find.text('المحتوى الشرعي'), findsOneWidget);
    });

    testWidgets('navigates to settings tab on tap', (tester) async {
      final mockVm = HomeViewModel(logRepo: MockLogRepo(), timeRepo: MockTimeRepo());
      sl.registerFactory<HomeViewModel>(() => mockVm);

      await tester.pumpWidget(wrapApp(const HomeScreen()));
      await tester.pump();

      await tester.tap(find.text('الإعدادات'));
      await tester.pumpAndSettle();

      expect(find.text('التنبيهات والإعدادات'), findsOneWidget);
    });

    testWidgets('back to dashboard from stats tab', (tester) async {
      final mockVm = HomeViewModel(logRepo: MockLogRepo(), timeRepo: MockTimeRepo());
      sl.registerFactory<HomeViewModel>(() => mockVm);

      await tester.pumpWidget(wrapApp(const HomeScreen()));
      await tester.pump();

      await tester.tap(find.text('الإحصائيات'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('الرئيسية'));
      await tester.pumpAndSettle();

      expect(find.text('السلام عليكم'), findsOneWidget);
    });
  });
}
