import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../domain/models/day_log.dart';

class HeroStatsCard extends StatelessWidget {
  final DayLog today;
  final Map<String, int> agg;
  const HeroStatsCard({super.key, required this.today, required this.agg});

  @override
  Widget build(BuildContext context) {
    final done = agg['today_done'] ?? 0;
    final total = agg['today_total'] ?? 5;
    final pct = total > 0 ? (done / total * 100).round() : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceXl, AppTheme.spaceXl, AppTheme.spaceXl, AppTheme.spaceXxl,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF003527)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMd, vertical: AppTheme.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.onPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'اليوم',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            _formatDate(DateTime.now()),
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: AppTheme.onPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            'صلوات اليوم',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppTheme.onPrimary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppTheme.spaceLg),
          Row(
            children: [
              _HeroStat(label: 'مقضية', value: '$done', color: AppTheme.primaryFixed),
              const SizedBox(width: AppTheme.spaceXxl),
              _HeroStat(label: 'متبقية', value: '${total - done}', color: AppTheme.onPrimaryContainer),
              const Spacer(),
              _HeroStat(label: 'الإنجاز', value: '$pct%', color: AppTheme.primaryFixed),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'إبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    final days = [
      'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد',
    ];
    return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _HeroStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
