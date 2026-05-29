import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/app.dart';
import 'package:qadaa_prayer_tracker/di/locator.dart';

void main() {
  testWidgets('App renders onboarding screen', (WidgetTester tester) async {
    await setupDi();
    await tester.pumpWidget(const QadaaApp());
    expect(find.text('التالي'), findsOneWidget);
  });
}
