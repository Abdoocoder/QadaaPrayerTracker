import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../di/locator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../services/qadaa_service.dart';
import '../../../../theme/app_theme.dart';
import '../../home/views/home_screen.dart';

class OnboardingYearsPage extends StatefulWidget {
  const OnboardingYearsPage({super.key});

  @override
  State<OnboardingYearsPage> createState() => _OnboardingYearsPageState();
}

class _OnboardingYearsPageState extends State<OnboardingYearsPage> {
  final _controller = TextEditingController();
  final _qadaaService = sl<QadaaService>();

  void _save() {
    final text = _controller.text.trim();
    final years = int.tryParse(text);
    if (years == null || years <= 0) return;

    _qadaaService.initYears(years);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, a1, a2) => const HomeScreen(),
        transitionsBuilder: (context, anim, a2, child) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: anim, child: child),
        ),
        transitionDuration: AppTheme.durationSlow,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 136,
                height: 136,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 60,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: AppTheme.spaceXxxl),
              Text(
                loc.onboardingYearsTitle,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spaceLg),
              Text(
                loc.onboardingYearsSub,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.onSurfaceVariant,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spaceXxxl),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 3,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: loc.onboardingYearsHint,
                  filled: true,
                  fillColor: AppTheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceLg,
                    vertical: AppTheme.spaceLg,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: AppTheme.spaceXxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(loc.onboardingYearsSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
