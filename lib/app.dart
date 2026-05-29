import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'di/locator.dart';
import 'di/locale_notifier.dart';
import 'ui/features/onboarding/views/onboarding_screen.dart';

class QadaaApp extends StatefulWidget {
  const QadaaApp({super.key});

  @override
  State<QadaaApp> createState() => _QadaaAppState();
}

class _QadaaAppState extends State<QadaaApp> {
  late final LocaleNotifier _localeNotifier = sl<LocaleNotifier>();

  @override
  void initState() {
    super.initState();
    _localeNotifier.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    _localeNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qadaa Prayer Tracker',
      debugShowCheckedModeBanner: false,
      locale: _localeNotifier.locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(),
    );
  }
}
