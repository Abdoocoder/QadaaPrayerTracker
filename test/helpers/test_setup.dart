import 'package:shared_preferences/shared_preferences.dart';
import 'package:qadaa_prayer_tracker/di/locator.dart';

Future<void> testSetupDi() async {
  SharedPreferences.setMockInitialValues({});
  await setupDi();
}
