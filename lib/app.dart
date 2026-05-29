import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'di/locator.dart';
import 'di/locale_notifier.dart';
import 'di/theme_notifier.dart';
import 'ui/features/onboarding/views/onboarding_screen.dart';

class QadaaApp extends StatefulWidget {
  const QadaaApp({super.key});

  @override
  State<QadaaApp> createState() => _QadaaAppState();
}

class _QadaaAppState extends State<QadaaApp> {
  late final LocaleNotifier _localeNotifier = sl<LocaleNotifier>();
  late final ThemeNotifier _themeNotifier = sl<ThemeNotifier>();

  @override
  void initState() {
    super.initState();
    _localeNotifier.addListener(_onChanged);
    _themeNotifier.addListener(_onChanged);
  }

  @override
  void dispose() {
    _localeNotifier.removeListener(_onChanged);
    _themeNotifier.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qadaa Prayer Tracker',
      debugShowCheckedModeBanner: false,
      locale: _localeNotifier.locale,
      themeMode: _themeNotifier.themeMode,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const OnboardingScreen(),
    );
  }
}
