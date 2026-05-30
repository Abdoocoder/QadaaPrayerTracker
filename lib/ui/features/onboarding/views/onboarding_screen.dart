import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import 'onboarding_years_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  int _currentPage = 0;

  final _pages = [
    _PageData(
      icon: Icons.mosque_rounded,
      title: 'تتبع صلواتك\nالقادئة',
      subtitle: 'سجل وأحص صلواتك الفائتة\nبكل سهولة وانتظام',
      color: AppTheme.primary,
    ),
    _PageData(
      icon: Icons.analytics_rounded,
      title: 'إحصائيات\nدقيقة',
      subtitle: 'تابع تقدمك مع رسوم بيانية\nوإحصائيات يومية وأسبوعية',
      color: AppTheme.secondary,
    ),
    _PageData(
      icon: Icons.notification_add_rounded,
      title: 'تذكيرات\nذكية',
      subtitle: 'احصل على تذكيرات في\nالأوقات المناسبة للقضاء',
      color: AppTheme.primary,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(vsync: this, duration: AppTheme.durationSlow);
    _fadeIn = CurvedAnimation(parent: _animController, curve: AppTheme.smoothEase);
    _animController.forward();
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, a1, a2) => const OnboardingYearsPage(),
        transitionsBuilder: (context, anim, a2, child) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: anim, child: child),
        ),
        transitionDuration: AppTheme.durationSlow,
      ),
    );
  }

  @override
  void dispose() { _pageController.dispose(); _animController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) { setState(() => _currentPage = i); _animController.reset(); _animController.forward(); },
                itemCount: _pages.length,
                itemBuilder: (_, i) {
                  final page = _pages[i];
                  return AnimatedBuilder(
                    animation: _fadeIn,
                    builder: (_, child) {
                      final t = _fadeIn.value;
                      return Opacity(
                        opacity: t,
                        child: Transform.translate(offset: Offset(0, 30 * (1 - t)), child: child),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXxl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 136, height: 136,
                            decoration: BoxDecoration(color: page.color.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: Icon(page.icon, size: 60, color: page.color),
                          ),
                          const SizedBox(height: AppTheme.spaceXxxl),
                          Text(page.title, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 34, fontWeight: FontWeight.w700, color: AppTheme.onSurface, height: 1.15, letterSpacing: -0.5), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 3),
                          const SizedBox(height: AppTheme.spaceXl),
                          Text(page.subtitle, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w400, color: AppTheme.onSurfaceVariant, height: 1.6), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 3),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXxl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) => AnimatedContainer(
                  duration: AppTheme.durationFast,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? AppTheme.primary : AppTheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
            ),
            const SizedBox(height: AppTheme.spaceXxl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXxl),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _currentPage == _pages.length - 1 ? _goToHome : () => _pageController.nextPage(duration: AppTheme.durationBase, curve: AppTheme.smoothEase),
                  child: Text(_currentPage == _pages.length - 1 ? 'ابدأ الآن' : 'التالي'),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            TextButton(
              onPressed: _goToHome,
              child: Text('تخطي', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7))),
            ),
            const SizedBox(height: AppTheme.spaceXxl),
          ],
        ),
      ),
    );
  }
}

class _PageData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _PageData({required this.icon, required this.title, required this.subtitle, required this.color});
}
