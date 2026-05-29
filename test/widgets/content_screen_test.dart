import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/ui/features/content/views/content_screen.dart';

Widget wrapApp(Widget w) => MaterialApp(home: Scaffold(body: w));

void main() {
  group('ContentScreen', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(wrapApp(const ContentScreen()));
      expect(find.text('المحتوى الشرعي'), findsOneWidget);
      expect(find.textContaining('أذكار وأدعية'), findsOneWidget);
    });

    testWidgets('renders all four cards', (tester) async {
      await tester.pumpWidget(wrapApp(const ContentScreen()));
      expect(find.text('أدعية'), findsOneWidget);
      expect(find.text('آيات وأحاديث'), findsOneWidget);
      expect(find.text('نصائح'), findsOneWidget);
      expect(find.text('أذكار'), findsOneWidget);
    });

    testWidgets('renders card titles', (tester) async {
      await tester.pumpWidget(wrapApp(const ContentScreen()));
      expect(find.text('دعاء قضاء الصلاة الفائتة'), findsOneWidget);
      expect(find.text('فضل المحافظة على الصلوات'), findsOneWidget);
      expect(find.text('كيف تبدأ في قضاء صلواتك'), findsOneWidget);
      expect(find.text('أذكار الصباح والمساء'), findsOneWidget);
    });
  });
}
