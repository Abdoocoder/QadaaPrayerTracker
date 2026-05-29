import 'package:flutter/material.dart';
import 'di/locator.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDi();
  runApp(const QadaaApp());
}
