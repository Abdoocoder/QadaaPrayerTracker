import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/app.dart';
import 'helpers/test_setup.dart';

void main() {
  setUpAll(() async {
    await testSetupDi();
  });

  testWidgets('App renders onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(const QadaaApp());
    expect(find.text('التالي'), findsOneWidget);
  });
}
